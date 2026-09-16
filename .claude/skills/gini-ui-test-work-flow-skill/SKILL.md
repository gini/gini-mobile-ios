---
name: gini-ui-test-work-flow-skill
description: Xray manual test case tooling. Two opposite jobs — EXPORT the cases of an existing Xray Test Set to CSV, with their step text (Xray Cloud itself cannot do this), or GENERATE brand new manual test cases from a ticket, spec or acceptance criteria as a CSV ready to import into Xray. Use when asked to "export the test cases", "get the Xray test cases as CSV", "make a CSV of the <feature> test cases", "generate/create/write Xray test cases", or anything else involving Xray test cases and a CSV.
---

# Which job is this? — decide before doing anything

The two jobs run in **opposite directions**. Picking the wrong one silently
produces the wrong file, so decide first and say which you picked.

| Do the cases already exist in Xray? | Direction | Do this |
|---|---|---|
| **Yes** — there is a Test Set, or you were given test keys | read **out of** Xray | Run `xray_export_testset_csv.py` (below). Do **not** write the CSV by hand. |
| **No** — you are creating cases from a ticket, spec or AC | write **into** Xray | Read `generate-xray-tests.md` in this directory and follow it. |

If you cannot tell, **ask**. The giveaway is whether a Test Set exists for the feature.

`references/example-tests.csv` belongs to the **generate** job only. It is a style
example for cases you are about to import. It is **not** a source of test data and
must never be used to answer an export request — its rows are examples, not this
project's real test cases.

## Export: the cases already exist in Xray

Xray Cloud has no CSV export that carries step text, so the API is the only route.
Run the script — never hand-write or reconstruct the file:

```bash
python3 .claude/skills/gini-ui-test-work-flow-skill/xray_export_testset_csv.py \
  --test-set <TEST-SET-KEY> --prefix <feature> --out-dir <dir>
```

Scope with `--test-set`. `--jql` exists for when no Test Set exists yet, but a text
search pulls in retired cases and cases owned by other features.

It reads credentials from `~/.config/gini/xray.env`. Read the module docstring for
the columns it writes, the `--no-split` behaviour, and why there is no
`Preconditions` column. Report the paths it prints and its case and row counts; if
`Fetched: N of M` shows two different numbers, something was dropped — say so.

If you were given test keys but no Test Set, ask for the Test Set rather than
searching, then export that.

## Generate: the cases do not exist yet

Read `generate-xray-tests.md` in full and follow it. The output is for a human to
review and import — **never automate or trust a case you generated in the same run**,
because nobody has checked it yet.
