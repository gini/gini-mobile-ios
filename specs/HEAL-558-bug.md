# HEAL-558: [iOS] PaymentReview document preview shows pages in random order (regression from 5.5.2)

Status: fixed
Ticket: https://ginis.atlassian.net/browse/HEAL-558

## Symptom

When the Payment Review screen renders a multi-page PDF, its document preview
displays the pages in an arbitrary order, and the order changes on every
re-open of the screen. Expected behavior is the original PDF page order
(1, 2, …, N), stable across re-opens.

The mixed-readability reproduction (one Gini-readable page + one or more
raster-scan pages) makes it visible because the readable page's preview
generation path has meaningfully different latency from the raster-scan ones —
the completion order visibly races the intended order.

Introduced in `GiniHealthSDK;6.0.0` (SwiftUI migration of PaymentReview).
Present in `GiniHealthSDK;6.1.0`. Last known good: `GiniHealthSDK;5.5.2`.

## Reproduction

Failing unit test in
`GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/PaymentReviewModelTests.swift`
(the fetchImages MARK section):

1. Stub `PaymentReviewProtocol.preview(for:pageNumber:completion:)` to return a
   distinct payload per page with staggered delays that invert the natural
   order — e.g. page 1 slowest, page N fastest.
2. `await model.fetchImages()`.
3. `#expect` that `model.cellViewModels` at index `i` corresponds to page
   `i + 1` (by identifying each cell's `preview` image against the input
   payload).

Before the fix the test fails because `cellViewModels` reflects completion
order, not page order.

Manual repro on the example app (only if the unit test is disputed): upload a
PDF with one readable + one or more non-readable pages, open Pay receipt,
observe the carousel; dismiss and re-open — the order changes again.

## Root cause

File: `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/PaymentReview/PaymentReviewModel.swift`,
`fetchImages()` at lines 259–281.

```swift
let viewModels = await withTaskGroup(of: PageCollectionCellViewModel?.self) { group in
    for page in 1 ... document.pageCount {
        group.addTask {
            await self.buildCellViewModel(documentId: documentId, pageNumber: page)
        }
    }
    return await group.reduce(into: [PageCollectionCellViewModel]()) { result, cellViewModel in
        guard let cellViewModel else { return }
        result.append(cellViewModel)   // appended in COMPLETION order
    }
}
```

Mechanism:

- `withTaskGroup` yields child-task results as each finishes, not in
  submission order.
- The child task only returns `PageCollectionCellViewModel?` — the `page`
  index used to launch the task is dropped on the floor.
- `reduce(into:)` appends each result in completion order, so `viewModels`
  reflects the race between the N `preview(for:pageNumber:)` calls.
- Every re-open re-races them → new arbitrary order.

Pre-migration (`GiniHealthSDK;5.5.2`, `GiniComponents/GiniInternalPaymentSDK/…/PaymentReviewModel.swift`,
`fetchImages()` ≈ L231) serialised the work behind a `DispatchSemaphore`, so
pages arrived deterministically in order. The SwiftUI migration in commit
`62c1058b9` (branch `HEAL-92-migrate-document-preview`) correctly parallelised
the work but dropped the page-index/order correlation.

`PaymentReviewObservableModel.fetchImages()` (line 118) just delegates to
`PaymentReviewModel.fetchImages()`, and mirrors `cellViewModels` in the
`onPreviewImagesFetched` callback (line 220–223) — so fixing ordering on the
underlying model fixes both.

## Proposed fix

Keep the concurrency; re-impose the order by writing into a pre-sized buffer
indexed by page number, then compact to drop nil (failed) pages. Rewrite the
body of `fetchImages()`:

```swift
var buffer: [PageCollectionCellViewModel?] =
    Array(repeating: nil, count: document.pageCount)

await withTaskGroup(of: (Int, PageCollectionCellViewModel?).self) { group in
    for page in 1 ... document.pageCount {
        group.addTask {
            let cellVM = await self.buildCellViewModel(documentId: documentId,
                                                       pageNumber: page)
            return (page - 1, cellVM)
        }
    }

    for await (index, cellVM) in group {
        buffer[index] = cellVM
    }
}

isImagesLoading = false
cellViewModels.append(contentsOf: buffer.compactMap { $0 })
onPreviewImagesFetched?()
```

Change is confined to the body of `PaymentReviewModel.fetchImages()`.

**Public API impact:** none. `PaymentReviewModel.fetchImages()` is `internal`,
`cellViewModels` is `internal`, `PageCollectionCellViewModel` is unchanged.

**Release target:** `release/GiniBankSDK_4.6.0` (per user confirmation).

## Regression test plan

Framework: Swift Testing (`@Suite`, `@Test`, `#expect`) — matches the existing
`PaymentReviewModelTests` (`@Suite("PaymentReviewModel")`, `@MainActor`).

**Mock change** — extend `MockPaymentReviewDelegate` in
`GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/PaymentTestMocks.swift`
to support per-page delayed and per-page distinct preview responses:

- New property `previewDelaysByPage: [Int: Duration] = [:]` (or
  `TimeInterval`) — sleep the configured duration inside `preview(for:pageNumber:completion:)`
  before invoking the completion. Missing entries mean no delay (default;
  keeps existing tests passing).
- New property `previewDataByPage: [Int: Data] = [:]` — override `previewResult`
  per page. Missing entries fall back to the existing `previewResult`.

Both defaults preserve current behavior, so no other test suite needs changes.

**New test** in `PaymentReviewModelTests.swift`, appended to the `fetchImages`
MARK section:

- `@Test("fetchImages preserves page order regardless of preview completion timing")`
  — configure `previewDelaysByPage` so page 1 is slowest and page N is
  fastest, configure `previewDataByPage` so each page's `Data` decodes to a
  distinguishable `UIImage` (e.g. a solid color per page). `await
  model.fetchImages()`, then `#expect` each `model.cellViewModels[i].preview`
  matches the input for page `i + 1`.

**Existing test guard:** the existing
`"fetchImages sets isImagesLoading and calls onPreviewImagesFetched"` test
(uses `MockPaymentReviewDelegate` with default zero delays) must still pass —
mock defaults ensure it does.

Rough test count added: 1 new test in `PaymentReviewModelTests`; no new
suite.

### Not tested

- `PaymentReviewObservableModel.fetchImages()` (wrapper, one-line delegation) —
  covered transitively by the underlying model's test.
- Behavior of `PaymentReviewProtocol.preview` on the real Gini API — that's a
  network integration concern, not a fetchImages ordering concern.

## Out of scope

- `cellViewModels.append(contentsOf: viewModels)` accumulation (repeated
  `fetchImages()` calls stack pages). The observed bug is per-instance and the
  screen is reopened with a fresh model, so this doesn't fire in practice.
  File a follow-up ticket if a caller path is identified that reuses the
  model.
- Refactoring `fetchPreview`/`buildCellViewModel` to drop the
  `withCheckedThrowingContinuation` shim — the delegate API is completion-based
  and out of the fix's blast radius.

## Open questions

None.
