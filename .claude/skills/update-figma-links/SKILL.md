---
name: update-figma-links
description: >-
  Update the Figma design links on the iOS Gini Bank SDK "Figma Links in
  public documentation" Confluence page to a new UI-customisation guide (new SDK
  version). Verifies every node-id actually resolves to the CORRECT screen in the
  new Figma file (not just that it exists), handles all three Confluence embed
  formats, strips share tokens, and writes back safely with a post-write diff.
  Use when migrating that iOS page from one SDK version's Figma file to a
  newer one — e.g. 4.3 → 4.4.
---

# Update Figma links on a Confluence documentation page

Migrate all Figma links on a Confluence page from an old Figma file/version to a
new one, correctly and safely. This encodes a process that was validated by hand;
follow it in order and do not skip the verification or sign-off steps.

## When to use

The user wants to point the iOS Gini Bank SDK "Figma Links" documentation
page at a newer Figma UI-customisation guide (new SDK version). The page contains
many Figma links, one per screen/section.

## How to run

Type `/update-figma-links` and paste the new Figma guide URL, or just say in
plain words: *"update the iOS Figma links to this new guide: <URL>"*.

You normally provide **only the new Figma guide URL** — the Confluence page is
already known (see Repo defaults). Example:

```
/update-figma-links https://www.figma.com/design/<NEW_KEY>/iOS-Gini-Bank-SDK-<version>-UI-Customisation
```

What happens next: it reads the page, verifies each screen's node-id in the new
file, shows you a ✅/❌ table, and **pauses for your sign-off** (and asks you to
paste the correct link for any screen that moved) before writing. You approve; it
writes and then diffs to confirm. Nothing is written without your OK.

## Repo defaults (iOS)

This skill targets the **iOS** Gini Bank SDK documentation. Use these unless
the user overrides them:

- **Confluence page:** "Figma Links in public documentation" — page ID `432504845`
  (`https://gini.atlassian.net/wiki/spaces/IBSV/pages/432504845/Figma+Links+in+public+documentation`)
- **Confluence site:** `gini.atlassian.net` — pass this as the `cloudId` argument to
  the Atlassian MCP tools (they accept a site hostname, so the literal cloudId UUID
  is not needed here).
- **Guide name pattern:** `iOS-Gini-Bank-SDK-<version>-UI-Customisation`
- **Current file (as of writing):** version `4.3`, file key `sBYNr8jV6zSncRjKJPyIOz`
  (`https://www.figma.com/design/sBYNr8jV6zSncRjKJPyIOz/iOS-Gini-Bank-SDK-4.3-UI-Customisation`).
  This is illustrative — always auto-detect the *current* key/version from the page.

Because the page is already known, the user normally only needs to paste the
**new** Figma guide URL. Still confirm the page + old→new versions back to the
user before writing.

---

## STEP 0 — Inputs (accept plain pasted URLs; STOP only if genuinely missing)

Users think in URLs, not in file keys. Ask for / accept these as **whole pasted
links** — never make the user type a cryptic file key or a separate version:

1. **Confluence page** — paste the page URL (or ID). Extract the numeric page ID,
   e.g. `.../pages/432504845/...` → `432504845`.
2. **New Figma customisation guide** — paste the WHOLE Figma URL of the new file.
   Derive from it (do NOT ask separately):
   - **new file key** = the segment right after `/design/`
     (e.g. `https://www.figma.com/design/sBYNr8jV6zSncRjKJPyIOz/...` → `sBYNr8jV6zSncRjKJPyIOz`)
   - **new version label** = the number in
     `iOS-Gini-Bank-SDK-<version>-UI-Customisation` (e.g. `4.4`).
     Only if the pasted URL has no version in its name, ask the user for the version.

Do **not** proceed if the page or the new Figma URL is missing — editing the
wrong page or wrong file is hard to undo and outward-facing. But once you have
those two pasted links, derive everything else; don't demand more typing.

**Auto-detected (do NOT ask):** the *old* Figma file key and version — read them
from the page's existing links. After detecting, confirm back, e.g.
"This page currently points to the 4.3 file (`sBYNr8jV6zSncRjKJPyIOz`) →
migrating to 4.4 (`<NEW_KEY>`). Proceeding."

**Optional inputs:** per-screen node-id overrides (for moved screens — see Step 3,
and the user may simply paste a screen's Figma link).

**Format policy (DEFAULT: standardise every link to the embed preview).** This
page should show one uniform **live Figma preview per section**, like the
**Colors** section. So by default convert every link — plain link boxes
(`block-card`) and "Figma for Confluence" plugin boxes — into the same
`embed-card` format (see Step 2, `--to-embed`). Only skip standardising if the
user explicitly says to keep the existing formats.

---

## Key facts you must know

**Three embed formats** appear on these pages; all three contain the same
`figma.com` URL text, so a whole-page string substitution covers all of them.
You only need the formats to *verify* afterward and to not miss any:

| Format | Where the URL lives | Looks like on the page |
|---|---|---|
| `block-card` | `data-url` + `<a href>` + visible text (3 copies) | a plain clickable link box |
| `embed-card` | `<iframe src>` | a live Figma preview window |
| plugin extension (`figma-for-confluence-lite`) | inside the `data-parameters` JSON (`url` field, `&quot;`-encoded) | a "Figma for Confluence LITE" box |

**The `t=` token** — the trailing `&t=...` on a Figma URL is a per-session share
token, not needed for the link to work. Strip it from every link. (Tell-tale
sign the links were bulk-copied: they all share the same token.)

**node-id caveat (the important one)** — a `node-id` from the old file does **not**
reliably point to the same screen in the new file. Some screens move, get
renamed, or are new. You MUST verify each one (Step 3). Blindly swapping the file
key can silently send a link to the wrong screen.

**Frame-name caveat** — in these files, many big container frames are generically
named "Onboarding - Light Mode" even when they contain Review/Help/etc. So a
name check alone is unreliable — confirm ambiguous ones with a screenshot.

**inline-comment / `data-local-id` risk** — the MCP write replaces the whole page
body and drops the invisible `data-local-id` tags that anchor **inline comments**.
Harmless on pages with no inline comments; on pages that HAVE them it can detach
them. Step 5 checks for this before writing.

---

## STEP 1 — Read the page and enumerate the links

1. `mcp__claude_ai_Atlassian__getConfluencePage` with `contentFormat: "html"` and
   the page ID. (Load Atlassian MCP tools via ToolSearch if deferred.)
2. Save the returned `body` HTML to a working file, e.g.
   `<scratchpad>/page_before.html`.
3. Enumerate every `figma.com` link with its section heading and `node-id`.
   Detect the old file key + version from these URLs and confirm to the user.

## STEP 2 — Compute the proposed new links (deterministic)

**Never hardcode a version.** The old version/key are auto-detected from the page;
the new version/key come from the Figma URL the user pasted. Any `4.3`/`4.4`
elsewhere in this skill are illustrative examples only — always use the detected
and pasted values.

Use the helper script (avoids hand-retyping the large body):

```
python3 <skill-dir>/transform_links.py \
  --in <scratchpad>/page_before.html \
  --out <scratchpad>/page_after.html \
  --old-key <DETECTED_OLD_KEY> --new-key <NEW_KEY_FROM_PASTED_URL> \
  --old-version <DETECTED_OLD_VERSION> --new-version <NEW_VERSION_FROM_PASTED_URL> \
  --strip-token \
  --to-embed \
  [--map OLD_NODEID=NEW_NODEID ...]
```

It swaps the file key, swaps the version in the file-name segment, strips `t=`
tokens, applies any node-id overrides, and prints a before→after audit of every
Figma URL. Review that audit.

**`--to-embed` (default policy)** additionally standardises every link into the
uniform live-preview format used by the Colors section:
`<div data-type="embed-card" data-layout="center" data-width="100"><iframe src="URL"></iframe></div>`
It converts `block-card` link boxes and "Figma for Confluence" plugin boxes into
this format and leaves any non-Figma element untouched. Omit `--to-embed` only if
the user asked to keep each link's existing format (then links are re-pointed in
place).

## STEP 3 — Verify every node-id in the NEW file (REQUIRED — do not skip)

Verification is judgment, not string work. Delegate it to a subagent so the heavy
Figma metadata output stays out of the main context:

- Give the subagent the NEW file key and the list of `section → node-id`.
- It calls `mcp__claude_ai_Figma__get_metadata` (fileKey + nodeId) for each and
  reports: exists? / the node's name / whether it matches the section.
- For any it flags as a mismatch, or any ambiguous generic name, **confirm
  visually** with `mcp__claude_ai_Figma__get_screenshot` (small `maxDimension`).
- Produce a table: ✅ safe (correct screen) vs ❌ needs a corrected node-id.

### Step 3b — Handling a wrong or moved screen (the important case)

A node-id from the old file may resolve, in the NEW file, to a **different** screen
(e.g. the old "Onboarding" node = Typography in 4.4) or to a generic container.
When verification flags a link ❌, resolve it like this — never write it unresolved:

1. **Try to auto-locate the correct screen** in the new file:
   - Call `get_metadata` on the new file with **no nodeId** to list top-level pages,
     and/or scan frames whose name matches the section (e.g. "Onboarding",
     "Document Import").
   - Screenshot the best candidate with `get_screenshot` and confirm its content
     matches the section.
2. If a confident match is found → show the user the screenshot and propose it;
   on approval, record it as a `--map OLD=NEW` override.
3. If **not** found confidently → **STOP and ask the user to paste that ONE
   screen's Figma link** from the new file. Extract the node-id from the pasted
   URL and use it as the override.
4. A flagged link stays ❌ (excluded from the write) until resolved. Never write a
   link whose target screen you could not confirm.

After resolving overrides, re-run Step 2 with the `--map` values.

## STEP 4 — Human sign-off gate (REQUIRED)

Show the user the final table (every link: old URL → new URL, with ✅/❌ status).
**Do not write** until the user confirms, and until every ❌ is resolved to a ✅
via an override. Never write a link you could not verify.

## STEP 5 — Write back safely (MCP method + inline-comment check)

1. **Inline-comment check:** call
   `mcp__claude_ai_Atlassian__getConfluencePageInlineComments` for the page.
   - If it returns any inline comments → **STOP**. Warn the user that the
     whole-body write would drop their anchors, and offer the REST-API mode
     (below) or manual editing. Do not write.
   - If none → proceed.
2. Write with `mcp__claude_ai_Atlassian__updateConfluencePage`,
   `contentFormat: "html"`, body = the reviewed `page_after.html` contents,
   and a clear `versionMessage` (e.g. "Migrate Figma links 4.3 → 4.4").

## STEP 6 — Verify the write (REQUIRED)

1. Re-fetch the page (`getConfluencePage`, html).
2. Diff it against `page_before.html`. Confirm that the ONLY differences are the
   intended Figma URLs (file key, version, stripped token, overridden node-ids)
   — plus the harmless `data-local-id` normalisation. Nothing else — no headings,
   other links, or macros changed.
3. Report the result to the user. Everything is versioned/undoable via page history.

---

## Optional: REST-API mode (loss-free, for pages WITH inline comments)

Only needed when Step 5 finds inline comments and the user still wants automation.
Requires an Atlassian API token (do not hard-code it):

- Auth: `curl -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN"`.
- `GET /wiki/rest/api/content/<id>?expand=body.storage,version` → transform the
  `body.storage.value` with `transform_links.py` → `PUT` the new storage value
  with `version.number + 1`. Storage format round-trips `data-local-id`, so
  inline-comment anchors survive.

## Two body representations — pick the transform to match (IMPORTANT)

The same page has two very different serialisations, and `transform_links.py`
only understands one of them:

- **ADF-html** (what the Atlassian MCP `getConfluencePage`/`updateConfluencePage`
  return/accept with `contentFormat: "html"`). Figma links appear as
  `data-type="block-card" | "embed-card" | "extension"` wrappers. **This is what
  `transform_links.py` targets.** Prefer this path — it round-trips cleanly.
- **Storage format** (`body.storage.value` from the REST API). The
  "Figma for Confluence LITE" plugin appears here as an `<ac:adf-extension>`
  Forge node, NOT as a `data-type` wrapper. Running `transform_links.py` on a
  storage body finds **zero** matches and leaves it unchanged — safe, but a no-op.

**If the page uses the Figma-for-Confluence plugin (storage `<ac:adf-extension>`
nodes) and you are on the REST path**, use the storage-format conversion below
instead of `transform_links.py`.

### Storage-format mode — plugin macro → native embed (validated on the iOS page)

Observed on the iOS page (432504845): all Figma links were third-party
`figma-for-confluence-lite` Forge extensions. When that plugin fails to load the
page shows **"Error loading the extension!"**. The fix is to convert each
extension to a **native Confluence Smart-Link embed**, the same format the Android
page uses:

```
<a href="<FIGMA_URL>" data-layout="center" data-width="100.00" data-card-appearance="embed"><FIGMA_URL></a>
```

Procedure (all read-only until the final PUT, which needs sign-off):

1. `GET /wiki/rest/api/content/<id>?expand=body.storage,version` (authenticated).
2. **Balanced-tag scan** for each top-level `<ac:adf-extension>…</ac:adf-extension>`
   block (these nodes nest — the Figma URL appears twice per block, once in the
   real `key="url"` param and once in embedded serialized context — so a naive
   non-greedy regex is wrong; walk open/close tags to find true boundaries).
3. For each figma block, read the `<ac:adf-parameter key="url">` value, strip the
   `t=` share token, and replace the whole block with the native embed anchor above.
4. Verify BEFORE writing: N blocks in == N anchors out, 0 `<ac:adf-extension>`
   remain, all URLs still on the intended file key/version, 0 share tokens, and
   the body OUTSIDE the replaced blocks is byte-for-byte unchanged.
5. Inline-comment check (Step 5), then `PUT` with `version.number + 1` and a clear
   message. Re-fetch and diff (Step 6).

### Rendering caveats (native embeds)

Native Figma embeds render honestly against the file's real permissions — unlike
the plugin, which proxied through its own auth. So after converting:

- **The Figma file must be link-shared "Anyone with the link → can view"** for
  logged-out / incognito / external readers to see anything. If it is not, the
  embed loads the file chrome (page selector, zoom controls) but shows a **blank
  canvas** — this looks like a broken embed but is actually a sharing setting.
- **Many embeds per page render lazily**; off-screen iframes are throttled and can
  stay blank until scrolled into view or clicked. Expect "some look blank" on long
  pages — this is not a data problem.
- Confirm both by comparing against a known-good page (e.g. the Android page) in
  the same viewing context (incognito vs signed-in).

## Guardrails recap

- Mandatory inputs, or STOP (Step 0).
- Verify every node-id resolves to the CORRECT screen, or STOP (Step 3).
- Human sign-off before writing, all ❌ resolved (Step 4).
- Inline-comment check before writing (Step 5).
- Post-write diff to confirm only intended changes (Step 6).
