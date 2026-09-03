#!/usr/bin/env python3
"""
transform_links.py — re-point (and optionally reformat) Figma links in a
Confluence page body for the iOS Gini Bank SDK docs.

Two things it can do:

1) RE-POINT (default): swap every figma.com URL from the old file/version to the
   new one, in place, keeping each link's existing wrapper. Applies:
     - old file key   -> new file key
     - old version     -> new version  (in the iOS-Gini-Bank-SDK-<v>-UI-Customisation name)
     - strips the &t=... share token (with --strip-token)
     - optional per-node-id remap (--map OLD=NEW) for screens that moved

2) STANDARDISE TO EMBED (--to-embed): in addition to re-pointing, rewrite EVERY
   Figma link into the same live-preview format as the Colors section, i.e.
     <div data-type="embed-card" data-layout="center" data-width="100"><iframe src="URL"></iframe></div>
   This converts block-card link boxes and "Figma for Confluence" plugin boxes
   (and normalises existing embed-cards) into one uniform full-width, centered
   preview per section.

The re-point pass covers all wrapper formats because it substitutes over the raw
URL text. The --to-embed pass replaces the wrapper element itself. "&amp;"-encoded
ampersands are handled. This script never touches Confluence — the skill fetches
the body (MCP), runs this, writes it back (MCP), and diffs to verify.

Usage (re-point only):
  python3 transform_links.py --in before.html --out after.html \
      --new-key NEWKEY --old-version 4.3 --new-version 4.4 --strip-token [--map OLD=NEW ...]

Usage (re-point + standardise to embed previews):
  python3 transform_links.py --in before.html --out after.html \
      --new-key NEWKEY --old-version 4.3 --new-version 4.4 --strip-token --to-embed [--map ...]
"""
import argparse
import re
import sys

# Stops at whitespace / real quotes / < > AND at an encoded quote `&quot;` (the JSON
# string delimiter inside the plugin extension), while still keeping `&amp;` — the
# real param separator inside the URL.
FIGMA_URL_RE = re.compile(r'https://www\.figma\.com/(?:(?!&quot;)[^\s"\'<>])+')

# Uniform preview wrapper, matching the Colors section (centered, full width).
EMBED_TMPL = ('<div data-type="embed-card" data-layout="center" data-width="100">'
              '<iframe src="{url}"></iframe></div>')

# Whole link-wrapper elements (none of these contain nested <div>, so .*?</div>
# closes at the element's own </div>).
BLOCK_RE = re.compile(r'<div\s+data-type="block-card"[^>]*>.*?</div>', re.DOTALL)
EMBED_RE = re.compile(r'<div\s+data-type="embed-card"[^>]*>.*?</div>', re.DOTALL)
EXT_RE = re.compile(r'<div\s+data-type="extension"[^>]*>.*?</div>', re.DOTALL)

DATA_URL_RE = re.compile(r'data-url="([^"]+)"')
IFRAME_SRC_RE = re.compile(r'<iframe[^>]*\bsrc="([^"]+)"')
EXT_URL_RE = re.compile(r'&quot;url&quot;:&quot;(.*?)&quot;')


def strip_share_token(url: str) -> str:
    url = re.sub(r'(?:&amp;|&)t=[^&"\'<>]*', '', url)
    url = re.sub(r'\?t=[^&"\'<>]*(?:&amp;|&)?', '?', url)
    return url.replace('?&amp;', '?').replace('?&', '?').rstrip('?&')


def transform_value(url, args, node_map):
    """Apply key/version/node-id/token changes to a single URL string."""
    if args.old_key and args.new_key:
        url = url.replace(args.old_key, args.new_key)
    if args.old_version and args.new_version:
        url = url.replace(
            f'iOS-Gini-Bank-SDK-{args.old_version}-UI-Customisation',
            f'iOS-Gini-Bank-SDK-{args.new_version}-UI-Customisation')
    # Single-pass, anchored node-id remap: the capture group matches a WHOLE
    # node-id (stops at & " ' < or whitespace), so a mapped id that is a prefix
    # of another id can't corrupt the longer one; and each id is looked up in the
    # map exactly once, so sequential entries never chain (a->b, b->c).
    if node_map:
        url = re.sub(r'node-id=([^&"\'\s<]+)',
                     lambda m: f'node-id={node_map.get(m.group(1), m.group(1))}', url)
    if args.strip_token:
        url = strip_share_token(url)
    return url


def make_wrapper_converter(args, node_map, report):
    def convert(match, kind):
        block = match.group(0)
        if kind == 'block':
            m = DATA_URL_RE.search(block) or FIGMA_URL_RE.search(block)
            url = m.group(1) if m and m.re is DATA_URL_RE else (m.group(0) if m else None)
        elif kind == 'embed':
            m = IFRAME_SRC_RE.search(block)
            url = m.group(1) if m else None
        else:  # extension
            m = EXT_URL_RE.search(block)
            url = m.group(1) if m else None
        if not url or 'figma.com' not in url:
            return block  # not a Figma link wrapper — leave untouched
        new_url = transform_value(url, args, node_map)
        report.append((url, new_url, kind))
        return EMBED_TMPL.format(url=new_url)
    return convert


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--in', dest='infile', required=True)
    p.add_argument('--out', dest='outfile', required=True)
    p.add_argument('--old-key', help='old Figma file key (auto-detected if omitted)')
    p.add_argument('--new-key', required=True, help='new Figma file key')
    p.add_argument('--old-version', help='old version label, e.g. 4.3')
    p.add_argument('--new-version', help='new version label, e.g. 4.4')
    p.add_argument('--strip-token', action='store_true')
    p.add_argument('--to-embed', action='store_true',
                   help='standardise every link to the embed-card preview format')
    p.add_argument('--map', action='append', default=[], metavar='OLD=NEW')
    args = p.parse_args()

    node_map = {}
    for m in args.map:
        if '=' not in m:
            print(f'ERROR: bad --map value {m!r}, expected OLD=NEW', file=sys.stderr)
            return 2
        old, new = m.split('=', 1)
        node_map[old.strip()] = new.strip()

    with open(args.infile, encoding='utf-8') as f:
        body = f.read()

    if args.old_key is None:
        keys = re.findall(r'figma\.com/design/([A-Za-z0-9]+)', body)
        if keys:
            args.old_key = max(set(keys), key=keys.count)
            print(f'[auto-detected old key] {args.old_key}')

    all_urls_before = FIGMA_URL_RE.findall(body)
    report = []

    if args.to_embed:
        conv = make_wrapper_converter(args, node_map, report)
        # Re-point existing embed-cards FIRST, so embeds created from block/ext
        # below are not re-scanned (keeps the report accurate, output unchanged).
        body = EMBED_RE.sub(lambda m: conv(m, 'embed'), body)
        body = BLOCK_RE.sub(lambda m: conv(m, 'block'), body)
        body = EXT_RE.sub(lambda m: conv(m, 'extension'), body)
        # Catch inline / straggler Figma links that are NOT inside the three
        # wrappers (e.g. a plain <a href> in a paragraph) — otherwise they would
        # silently keep the old file key and never appear in the audit.
        # GUARD: only touch URLs that still contain the OLD key, so URLs already
        # converted by the wrapper passes (new key) are skipped entirely. This is
        # essential: re-running the remap over converted URLs could otherwise
        # re-apply a map entry and re-introduce the chaining bug.
        def catch(mo):
            before = mo.group(0)
            if not args.old_key or args.old_key not in before:
                return before
            after = transform_value(before, args, node_map)
            if after != before:
                report.append((before, after, 'inline'))
            return after
        body = FIGMA_URL_RE.sub(catch, body)
        mode = 'STANDARDISE TO EMBED (+ re-point)'
    else:
        def repoint(mo):
            before = mo.group(0)
            after = transform_value(before, args, node_map)
            if after != before:
                report.append((before, after, 'url'))
            return after
        body = FIGMA_URL_RE.sub(repoint, body)
        mode = 'RE-POINT (in place)'

    with open(args.outfile, 'w', encoding='utf-8') as f:
        f.write(body)

    print(f'\nMode: {mode}')
    print(f'Figma links found: {len(all_urls_before)}   changed: {len(report)}\n')
    for i, (before, after, kind) in enumerate(report, 1):
        print(f'{i:>2}. [{kind}]')
        print(f'    BEFORE: {before}')
        print(f'    AFTER : {after}\n')
    print(f'Wrote: {args.outfile}')
    print('Next: verify node-ids in the NEW file, get sign-off, then write back and diff.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
