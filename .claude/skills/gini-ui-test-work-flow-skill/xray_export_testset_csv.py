#!/usr/bin/env python3
"""
Export Xray Cloud manual test cases to CSV, one row per test STEP.

Writes UP TO two files:

    <prefix>.csv                 functional tests
    <prefix>-accessibility.csv   accessibility tests

Splitting into the two is the default. A group with no matching tests is skipped
rather than written empty, so a Test Set with no accessibility cases produces one
file, not two -- do not assume both paths exist. --no-split writes every test to
<prefix>.csv instead and never writes the accessibility file at all. The script
prints the path of each file it actually wrote; rely on that, not on the names.

Columns:

    Issue Id,Summary,Test Type,Step,Data,Expected Result,Jira Key,Total Steps

The first six are the Xray Test Case Importer layout, in its original order, so
an existing importer column-mapping still works.

Rows sharing an Issue Id (TC-001, TC-002, ...) form one test case.

Jira Key is repeated on EVERY row of a test, so the file stays sortable and
filterable in a spreadsheet -- every row says which ticket it belongs to.
Summary and Total Steps appear only on the test's FIRST row. Per-step values
(Step, Data, Expected Result) appear on every row.

There is deliberately NO Preconditions column. Xray Cloud's importer expects a
"Precondition" column to hold an existing Precondition issue KEY, and free text
there fails the import with "Precondition type and test type mismatch". This
script still READS preconditions and prints a warning naming any test that has
one, so nothing is lost silently -- but they stay out of the file.

Step and result text is written EXACTLY as Xray holds it, with no escaping beyond
normal CSV quoting. A field that begins with "=", "+", "@" or "-" is therefore
treated as a formula by Excel and Google Sheets. That is deliberate: prefixing
such fields to defuse them would corrupt the file for re-import into Xray, and
step text legitimately starts with "-" (dash-bulleted expected results). Treat
the output as data exported from Xray rather than as a trusted spreadsheet, and
if you need a spreadsheet-safe copy, sanitise it downstream instead of here.

Credentials are read from a file (never passed on the command line, so they do
not land in shell history). Default location: ~/.config/gini/xray.env

    XRAY_CLIENT_ID=...
    XRAY_CLIENT_SECRET=...
    # optional, defaults to the EU region:
    # XRAY_BASE_URL=https://eu.xray.cloud.getxray.app

Usage:
    python3 xray_export_testset_csv.py --test-set PP-3483 --out-dir ./out
"""

import argparse
import csv
import json
import os
import re
import sys
import urllib.error
import urllib.request

DEFAULT_BASE_URL = "https://eu.xray.cloud.getxray.app"
DEFAULT_CREDS = os.path.expanduser("~/.config/gini/xray.env")


CSV_HEADER = [
    "Issue Id",
    "Summary",
    "Test Type",
    "Step",
    "Data",
    "Expected Result",
    "Jira Key",
    "Total Steps",
]

GRAPHQL_QUERY = """
query GetTests($jql: String!, $limit: Int!, $start: Int!) {
  getTests(jql: $jql, limit: $limit, start: $start) {
    total
    start
    limit
    results {
      issueId
      testType { name }
      jira(fields: ["key", "summary", "labels"])
      steps { id action data result }
      preconditions(limit: 20) {
        total
        results {
          definition
          jira(fields: ["key", "summary"])
        }
      }
    }
  }
}
"""


def load_credentials(path):
    if not os.path.exists(path):
        sys.exit(
            "Credentials file not found: %s\n"
            "Create it with:\n"
            "  XRAY_CLIENT_ID=...\n"
            "  XRAY_CLIENT_SECRET=...\n" % path
        )
    env = {}
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            env[key.strip()] = value.strip().strip('"').strip("'")

    missing = [k for k in ("XRAY_CLIENT_ID", "XRAY_CLIENT_SECRET") if not env.get(k)]
    if missing:
        sys.exit("%s is missing: %s" % (path, ", ".join(missing)))
    return env


def post_json(url, payload, headers=None):
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", "application/json")
    for key, value in (headers or {}).items():
        req.add_header(key, value)
    try:
        with urllib.request.urlopen(req, timeout=90) as resp:
            return resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")[:800]
        sys.exit("HTTP %s from %s\n%s" % (exc.code, url, detail))
    except urllib.error.URLError as exc:
        sys.exit("Could not reach %s: %s" % (url, exc.reason))


def authenticate(base_url, client_id, client_secret):
    raw = post_json(
        base_url + "/api/v2/authenticate",
        {"client_id": client_id, "client_secret": client_secret},
    )
    # The endpoint returns the JWT as a bare JSON string, i.e. "eyJ...".
    return json.loads(raw)


def fetch_tests(base_url, token, jql):
    tests, start, limit = [], 0, 100
    while True:
        raw = post_json(
            base_url + "/api/v2/graphql",
            {"query": GRAPHQL_QUERY, "variables": {"jql": jql, "limit": limit, "start": start}},
            headers={"Authorization": "Bearer " + token},
        )
        payload = json.loads(raw)
        if payload.get("errors"):
            sys.exit("GraphQL errors:\n" + json.dumps(payload["errors"], indent=2)[:2000])

        block = payload["data"]["getTests"]
        results = block.get("results") or []
        tests.extend(results)
        total = block.get("total") or 0
        start += limit
        if start >= total or not results:
            return tests, total


def jira_field(test, name, default=""):
    jira = test.get("jira") or {}
    value = jira.get(name)
    return value if value is not None else default


def sort_key(test):
    key = jira_field(test, "key", "")
    match = re.match(r"([A-Z]+)-(\d+)$", key)
    return (match.group(1), int(match.group(2))) if match else (key, 0)


def precondition_text(test):
    """Xray preconditions are separate issues, not steps -- collect their text.

    The Xray Cloud REST /steps endpoint omits these entirely, so anything built
    on it drops preconditions silently. GraphQL returns them, so we keep them.
    """
    block = test.get("preconditions") or {}
    parts = []
    for pre in (block.get("results") or []):
        key = ((pre.get("jira") or {}).get("key")) or ""
        definition = (pre.get("definition") or "").strip()
        summary = ((pre.get("jira") or {}).get("summary")) or ""
        label = " ".join(x for x in (key, summary) if x).strip()
        parts.append("%s: %s" % (label, definition) if definition else label)
    return " | ".join(p for p in parts if p)


def is_accessibility(test):
    summary = (jira_field(test, "summary") or "").lower()
    labels = [str(l).lower() for l in (jira_field(test, "labels", []) or [])]
    return (
        summary.startswith("accessibility")
        or "accessibility" in summary
        or "voiceover" in summary
        or "talkback" in summary
        or "accessibility" in labels
    )


def write_csv(path, tests):
    """Write one CSV. Per-test columns are filled on each test's first row only."""
    rows_written = 0
    # newline="" + \r\n matches the existing files' line endings.
    with open(path, "w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh, quoting=csv.QUOTE_MINIMAL, lineterminator="\r\n")
        writer.writerow(CSV_HEADER)
        for index, test in enumerate(tests, start=1):
            tc_id = "TC-%03d" % index
            summary = jira_field(test, "summary")
            test_type = ((test.get("testType") or {}).get("name")) or "Manual"
            jira_key = jira_field(test, "key")
            steps = test.get("steps") or []

            if not steps:
                writer.writerow(
                    [tc_id, summary, test_type, "", "", "", jira_key, 0]
                )
                rows_written += 1
                continue

            for step_index, step in enumerate(steps):
                first = step_index == 0
                writer.writerow([
                    tc_id,
                    summary if first else "",
                    test_type,
                    (step.get("action") or "").strip(),
                    (step.get("data") or "").strip(),
                    (step.get("result") or "").strip(),
                    jira_key,
                    len(steps) if first else "",
                ])
                rows_written += 1
    return rows_written


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--creds", default=DEFAULT_CREDS, help="credentials file (default: %s)" % DEFAULT_CREDS)
    parser.add_argument("--out-dir", default=".", help="directory to write the CSVs into")
    parser.add_argument("--prefix", default="credit-note", help="output filename prefix")
    parser.add_argument("--test-set", default=None, help="Test Set issue key, e.g. PP-3483 (the normal way to scope this)")
    parser.add_argument("--jql", default=None, help="raw JQL, for the rare case a Test Set does not exist yet")
    parser.add_argument("--no-split", action="store_true", help="write a single CSV instead of functional + accessibility")
    args = parser.parse_args()

    env = load_credentials(args.creds)
    base_url = (env.get("XRAY_BASE_URL") or DEFAULT_BASE_URL).rstrip("/")
    if args.test_set:
        jql = 'issue in testSetTests("%s")' % args.test_set
    elif args.jql:
        jql = args.jql
    else:
        sys.exit("Pass --test-set <KEY> (preferred) or --jql. A Test Set is the "
                 "curated scope; a raw JQL search will pull in retired cases.")

    print("Region   : %s" % base_url)
    print("JQL      : %s" % (jql[:120] + ("..." if len(jql) > 120 else "")))

    token = authenticate(base_url, env["XRAY_CLIENT_ID"], env["XRAY_CLIENT_SECRET"])
    print("Auth     : ok")

    tests, total = fetch_tests(base_url, token, jql)
    tests.sort(key=sort_key)
    print("Fetched  : %d of %d test(s) reported by Xray" % (len(tests), total))

    no_steps = [jira_field(t, "key") for t in tests if not (t.get("steps") or [])]
    if no_steps:
        print("WARNING  : no steps returned for: %s" % ", ".join(no_steps))

    with_pre = [jira_field(t, "key") for t in tests if precondition_text(t)]
    if with_pre:
        print("WARNING  : %d test(s) have Xray Preconditions, which are NOT written to\n"
              "           the CSV (see the module docstring for why). Read them in Xray\n"
              "           before automating: %s" % (len(with_pre), ", ".join(with_pre)))
    else:
        print("Note     : no test has Xray Preconditions, so nothing is left out.")

    if os.path.exists(args.out_dir) and not os.path.isdir(args.out_dir):
        sys.exit("--out-dir is not a directory: %s" % args.out_dir)
    os.makedirs(args.out_dir, exist_ok=True)

    if args.no_split:
        groups = [("", tests)]
    else:
        groups = [
            ("", [t for t in tests if not is_accessibility(t)]),
            ("-accessibility", [t for t in tests if is_accessibility(t)]),
        ]

    for suffix, group in groups:
        if not group:
            continue
        path = os.path.join(args.out_dir, "%s%s.csv" % (args.prefix, suffix))
        rows = write_csv(path, group)
        print("Wrote    : %s  (%d tests, %d step rows)" % (path, len(group), rows))


if __name__ == "__main__":
    main()
