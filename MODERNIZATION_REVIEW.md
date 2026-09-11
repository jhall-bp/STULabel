# STULabel modernization: review and completion tracker

This document is the durable handoff, task memory, and completion record for the modernization review. Agents should update it as they implement and validate each task. It records findings; it is not evidence that fixes have already been made.

## Review snapshot and scope

- Review date: 2026-09-09.
- Repository: `/Users/jessehalley/Developer/STULabel`.
- Reviewed branch: `uitextinput`, through `a58a1f3` (`begin removing no-arc`), plus the uncommitted worktree at review time.
- Requested comparison: `main`. This checkout had no local or remote `main`; the default branch was `master` (`origin/HEAD -> origin/master`).
- Actual comparison base: `ee77790abf583b4de46ff022e4d2a011b66ca6dc`, also the merge base with `master`. There were 68 commits between that base and the reviewed HEAD.
- Scope: a cohesive iOS 26 modernization, UI/component changes, CocoaPods-to-SPM migration, and current ARC/ownership work.
- The review was read-only. Existing source edits and known test failures were left untouched.
- Source links and line numbers below refer to the review snapshot. Recheck current implementations before acting; use the named symbols when lines move.

### Validation already performed

| Check | Result and limits |
| --- | --- |
| Package build-for-testing | Passed using Xcode 27 Beta 6 with an iPhone 17 Pro / iOS 26.2 destination selected. This was not an Xcode 26 toolchain check. |
| Package Mac Catalyst build | Passed. |
| Focused runtime probes | Executed through Xcode's snippet runner. The runner actually used iOS 27 (24A5423a), confirmed through ProcessInfo and UIDevice, despite the selected iOS 26.2 destination. These are iOS 27 runtime reproductions of source defects in the iOS 26 implementation. |
| Demo build | Blocked by `Missing package product 'STULabelSwift'`, including after reopening the project. The source-level cause was not established. |
| Standalone local consumer build | Blocked by `Unable to resolve module dependency: 'STULabelSwift'`. The source-level cause was not established. |
| Aggregate known-failing suite | Not rerun merely to catalogue known failures. |
| Performance | Structural regressions identified; no comparable timing benchmark was completed. |
| Dynamic foreground-color fast path | A suspected stale CoreText foreground color was disproven: one frame shaped in light traits drew correctly under both light and dark traits. Do not revive this finding without new evidence. |

Runtime results must not be described as iOS 26 reproductions until verified on an actual iOS 26 runtime.

## How agents should maintain this document

1. Read repository instructions and the task's current record. Recheck the current diff and source before implementing; another task may already have changed the relevant architecture.
2. Preserve unrelated worktree edits. This tracker alone does not authorize implementing every task, committing, pushing, or publishing.
3. Use the Xcode MCP for project, build, and simulator interactions, as required by repository instructions.
4. Prefer deletion, consolidation, or a direct ownership model over additive compatibility wrappers. Preserve hot-path performance.
5. Write new tests in Swift using Testing where possible. Use native Testing assertions directly. Favor meaningful behavior coverage over tests that mirror implementation details.
6. Update both the task status below and its local record. Keep task IDs stable so future prompts can refer to them.
7. Record the actual runtime, SDK/toolchain, destination, and test/build commands or MCP actions. Separate baseline failures from failures introduced by the fix.
8. Do not mark a task complete merely because it compiles. Satisfy its acceptance criteria or explicitly explain an approved replacement criterion.
9. Record changed files, design decisions, validation evidence, remaining risks, and a commit hash when available. If work is uncommitted, say so.
10. Preserve the original finding and evidence. Add dated implementation notes rather than rewriting the historical evidence to match the fix.

### Status meanings

- **Open:** no completed fix is recorded.
- **In progress:** an agent is actively implementing or validating the task.
- **Blocked:** a named dependency prevents further meaningful progress; record the exact blocker and next action.
- **Ready for review:** implementation and focused validation are complete, but review or a required gate remains.
- **Complete:** acceptance criteria are satisfied and evidence is recorded.
- **Deferred:** deliberately postponed with a recorded rationale and decision.
- **Superseded:** another task/change resolves it; link that evidence. Do not silently remove the task.

A dated progress entry should include:

> YYYY-MM-DD — Agent/owner — Status  
> Changes and rationale: ...  
> Files/commit: ...  
> Validation, environment, and results: ...  
> Remaining risk/blocker and next action: ...

## Task index

Statuses reflect the dated implementation records below; unchanged tasks retain their initial handoff state.

| ID | Classification | Task | Status | Coordination |
| --- | --- | --- | --- | --- |
| R01 | Must fix | Transactional text-input document publication | Complete | One retained snapshot owns text, geometry, links, and selection |
| R02 | Must fix | Visual caret navigation across bidi boundaries | Ready for review | Native UI smoke check blocked by Demo product resolution |
| R03 | Must fix | Preserve target traits in tiled rendering | Complete | Uses layer snapshot contract; R04–R06 ownership boundaries recorded below |
| R04 | Must fix | Synchronize the complete rendering environment | Complete | R03 and R06 integrated; R05 default-font semantics remain separate |
| R05 | Must fix | Trait-correct preferred default fonts | Complete | Follow-ups preserve provenance, Bold Text, and prerenderer defaults |
| R06 | Must fix | Single background-color owner across prerenderer configuration | Complete | Prerequisite for R04 environment synchronization |
| R07 | Must fix | Preserve disabled link colors during tint/lifecycle changes | Complete | Independent, same STULabel.mm file |
| R08 | Must fix for distribution | Remove unsafe flags from public package dependency graph | Open | Coordinate with G01 and ARC work |
| R09 | Strong improvement | Restore deliberate rendering concurrency | Open | Uncommitted changes at review; coordinate with R03 |
| R10 | Strong improvement | Avoid eager attributed-string normalization | Open | Coordinate with R05 |
| R11 | Strong improvement | Reduce historical Auto Layout retry machinery | Complete | Bounds-origin conversion fixed; retry simplification retained |
| R12 | Optional cleanup | Remove unreachable accessibility non-rotor branch | Complete | Committed as `31b6916` |
| R13 | Release requirement | Document the breaking consumer migration contract | Open | Finalize after behavior/API decisions |
| G01 | Release validation gate | Establish real downstream and iOS 26 build/runtime health | Open | Includes R08's versioned-consumer check |

## R01 — Transactional text-input document publication

**Classification:** Must fix  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabel+UITextInput.mm:214](Source/STULabel/STULabel+UITextInput.mm#L214), `updateVisibleString`, sends `textWillChange:` before updating `stu_displayedString`. Public text-input getters call `textInputString`, which calls this synchronization function again.

A delegate querying `endOfDocument` during `textWillChange:` re-enters the same outstanding change. A bounded runtime probe produced four nested `textWillChange:` callbacks for one mutation. Removing the artificial recursion bound would continue re-entering and can exhaust the stack.

Probe outline: nonzero label bounds (400 × 100), initial text "before", selectable enabled, initialize the text-input document, install a delegate that queries `endOfDocument` from `textWillChange:`, set text to "after", then query the document. Zero-sized bounds can produce an empty visible document and hide the issue.

### Preferred implementation

Publish the displayed document through an explicit transaction. Getters expose a stable old snapshot during "will change"; commit the new document and selection once; then issue "did change". Getters must not recursively initiate publication. Account for displayed text changing through truncation/layout as well as direct text assignment.

Do not merely move the assignment before the callback if that breaks the promised old/new notification semantics. Avoid adding repeated whole-string work to geometry queries.

### Acceptance criteria

- [x] Delegate queries during both will/did callbacks do not recursively notify.
- [x] One document mutation produces one coherent notification transaction.
- [x] Document, selection, and range queries observe internally consistent snapshots.
- [x] Text changes and layout/truncation-driven visible-document changes are covered.
- [x] Focused meaningful tests reproduce the old problem and validate the new behavior.
- [x] Actual runtime used for validation is recorded.

### Progress and completion record

2026-09-09 — Codex — Complete; committed as `1bae9ff`.

Changes and rationale: Made `_stu_displayedString` the document snapshot exposed by UITextInput getters and added an explicit publication guard. The delegate now observes the old snapshot during `textWillChange:`, the new snapshot during `textDidChange:`, and re-entrant getters cannot begin another transaction. The same transaction boundary covers layout/truncation-driven visible-string changes.

Files/commit: `Source/STULabel/STULabel+UITextInput-Internal.h`, `Source/STULabel/STULabel+UITextInput.mm`, and `Tests/STULabelTests/UITextInputTests.swift`; `1bae9ff`.

Validation, environment, and results: The native Swift Testing case `Visible document publication is stable during delegate callbacks` passed after rebuild on Xcode 27 Beta 6, iPhone 17 Pro simulator, iOS 26.2 (test result `Test-STULabel-Package-2026.09.09_21-10-23-+1000.xcresult`). It covers re-entrant getters in both callbacks plus a truncation-driven document change. `clang-format --dry-run --Werror` and `git diff --check` passed.

Remaining risk/blocker and next action: None for this finding.

### Follow-up review — 2026-09-11

**Status: Complete.** String recursion was fixed first; the reopened geometry inconsistency is now resolved by the completion record below.

[updateVisibleString/textInputString](Source/STULabel/STULabel+UITextInput.mm#L234) expose the old stored string during will-change. However, [caretRect](Source/STULabel/STULabel+UITextInput.mm#L356) reads the new visible string, and rectangle/hit-testing helpers read the live text frame and origin. [caretRectForPosition:](Source/STULabel/STULabel+UITextInput.mm#L846) validates an endpoint against the old snapshot before passing it into that new geometry.

New evidence, Xcode MCP RunCodeSnippet on **iOS 27.0 (24A434)**:
- With a 20-point font, replace "iiii" with "WWWW". During `textWillChange:`, `text(in:)` returns "iiii" while its end caret moves from x≈17.03 to x≈74.63.
- Set text to "abcdef", obtain its backward-affinity endpoint using `closestPosition(to: CGPoint(x: 399, y: 10))` in a 400 × 100 label, then replace text with "a". Querying that old endpoint's caret inside `textWillChange:` aborts: the endpoint is valid for the old document, but `previousCharacterBoundary` indexes the new one-character string.
- Crash report: `/Users/jessehalley/Library/Logs/DiagnosticReports/XCPreviewAgent-2026-09-11-101226.ips`, containing an Objective-C exception, `-[NSString rangeOfComposedCharacterSequenceAtIndex:]`, and SIGABRT.
- The original publication test passed again on actual iOS 26.2, but does not query callback geometry. The new cases still need iOS 26 regression coverage.

Preferred fix: publish a retained displayed-frame snapshot together with its string, origin/geometry environment, and selection. Every UITextInput query in the transaction must use the same old or new snapshot. Reuse existing frame geometry; a caret bounds check alone would retain contradictory document state.

Additional completion criteria:
- [x] Callback text, caret/selection rectangles, point hit testing, and position/range queries agree on one snapshot.
- [x] Shrinking text cannot throw when will-change queries an old valid caret.
- [x] Cover same-length replacements with different glyph widths and layout/truncation changes.
- [x] Reentrant queries do not perform another layout merely to discover that publication is already in progress.
- [x] Add focused Swift Testing regressions and run them on actual iOS 26.

### Reopened-finding completion — 2026-09-11

Changes and rationale: Replaced the separately published string and selection with one retained `STULabelTextInputDocument`. The document owns the immutable text frame, visible string, frame origin, display scale, links, and selection. Every UITextInput geometry, hit-testing, styling, position, and range helper now receives that document explicitly, so will-change callbacks use the complete old generation and did-change callbacks use the complete new generation. Geometry-only updates replace the snapshot without text notifications, while the unchanged-frame fast path avoids both allocation and the previous whole-string comparison on repeated queries.

Files/commit: `Source/STULabel/STULabel+UITextInput-Internal.h`, `Source/STULabel/STULabel+UITextInput.mm`, `Tests/STULabelTests/UITextInputTests.swift`, and this tracker; committed together with this record.

Validation, environment, and results: Xcode 27 Release Candidate, STULabel-Package scheme, Xcode MCP destination `iPhone 17 Pro (26.2)`. `BuildProject(buildForTesting: true)` passed (`BuildProject-Log-20260911-160955.txt`). All 21 `UITextInputTests` passed after the final callback-coverage expansion (`Test-STULabel-Package-2026.09.11_16-17-08-+1000.xcresult`). The new cases cover `iiii` → `WWWW` with an origin change, old/new selection rectangles, point hit testing, closest positions, and the `abcdef` → `a` backward-affinity endpoint that previously crashed. A Mac Catalyst product build also passed (`BuildProject-Log-20260911-161405.txt`). Mac Catalyst build-for-testing remains blocked outside R01 by the existing `AllocatorUtils.hpp:10` `UInt` typedef mismatch (`BuildProject-Log-20260911-161344.txt`). `clang-format --dry-run --Werror`, `swift-format lint --strict`, and `git diff --check` passed.

Remaining risk/blocker and next action: None for R01. The historical record above remains evidence of the narrower recursion fix; the Mac Catalyst test-target baseline remains part of broader release validation.


## R02 — Visual caret navigation across bidi boundaries

**Classification:** Must fix  
**Status:** Ready for review
**Owner:** Unassigned

### Problem and evidence

[STULabel+UITextInput.mm:411](Source/STULabel/STULabel+UITextInput.mm#L411), `positionInDirection`, approximates visual movement by advancing/reversing logical grapheme boundaries according to local writing direction. The farthest-position implementation near line 659 similarly chooses logical range endpoints.

For "abc אבג", repeated rightward movement cycles 3 → 4 → 3. The farthest-right query returns index 7 at approximately x=32, although index 4 lies at approximately x=59. These were runtime reproductions, not hypothetical Unicode edge cases.

### Preferred implementation

Derive visual caret movement from existing line/run geometry. Represent affinity at bidi and wrapped-line boundaries and share that representation across horizontal movement, farthest-position queries, and caret geometry. Reuse existing CoreText/text-frame geometry rather than introducing a second shaping system or patching individual RTL transitions.

### Acceptance criteria

- [x] Mixed LTR/RTL navigation makes visual progress without cycles.
- [x] Farthest-left/right positions agree with visual caret geometry.
- [x] Pure LTR, pure RTL, mixed runs, wrapped lines, and composed characters are covered.
- [x] Offset-zero, document boundaries, and boundary affinity are handled consistently.
- [ ] Native interaction behavior is checked where public protocol tests cannot establish it.
- [x] No repeated full-document geometry reconstruction is added to each arrow movement.

### Progress and completion record

2026-09-09 — Codex — Ready for review; committed as `1bae9ff`.

Changes and rationale: Added storage affinity to text positions, then consolidated point hit-testing, adjacent-line navigation, horizontal navigation, and farthest-position selection around the existing text-frame grapheme/run geometry. Horizontal movement now walks visual grapheme edges without rebuilding the text frame; farthest positions inspect existing selection rects rather than choosing logical range endpoints.

Files/commit: `Source/STULabel/STULabel+UITextInput.mm` and `Tests/STULabelTests/UITextInputTests.swift`; `1bae9ff`.

Validation, environment, and results: The native Swift Testing case `Visual caret movement retains affinity at bidirectional boundaries` passed after rebuild on Xcode 27 Beta 6, iPhone 17 Pro simulator, iOS 26.2 (test result `Test-STULabel-Package-2026.09.09_21-09-39-+1000.xcresult`). It covers the reported mixed string, farthest-right geometry, ordinary LTR, RTL, a composed emoji, and a wrapped line. `clang-format --dry-run --Werror` and `git diff --check` passed.

Remaining risk/blocker and next action: Native UIKit selection smoke testing is blocked: Device Interaction supports iOS 27+ only, while the Demo fails to build on the iOS 27 fallback with `Missing package product 'STULabelSwift'`. The test device session was closed. Once G01 resolves that product failure, manually long-press and move both selection handles through a mixed-bidi label.

2026-09-11 — Codex — Ready for review; follow-up committed as `ae8600b`.

Changes and rationale: Preserved the original position and its storage affinity for a logical offset of zero. At a visual line edge, horizontal movement now identifies the current line from the caret's affinity and existing text-frame range, selects the adjacent line in logical forward/backward order from the paragraph base direction, and enters it at its logical leading/trailing visual edge. This closes wrapped LTR and RTL traversal without a document scan, new shaping pass, or work in drawing loops.

Files/commit: `Source/STULabel/STULabel+UITextInput.mm` and `Tests/STULabelTests/UITextInputTests.swift`; `ae8600b`.

Validation, environment, and results: Xcode MCP, generated package workspace, `STULabel-Package`, iPhone 17 Pro simulator, iOS 26.2. Before the production change, the two focused regressions produced five expectation failures: offset-zero affinity changed the caret from x≈34 to x≈63, and both LTR and RTL traversal stopped before the next wrapped line. After the change, the dedicated Swift Testing cases cover offset-zero caret identity plus bidirectional traversal across all wrapped lines in both paragraph directions. All 19 `UITextInputTests` passed (result `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/49DA04F5-FA36-40A9-9518-CA616555A3D3.txt`). Scoped Swift and Objective-C++ formatting checks and `git diff --check` passed.

Remaining risk/blocker and next action: The protocol-level defects are closed. The native UIKit selection-handle smoke check remains part of G01 and is not claimed here.

## R03 — Preserve target traits in tiled rendering

**Classification:** Must fix  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabelLayer.mm:1523](Source/STULabel/STULabelLayer.mm#L1523) installs a tile drawing closure that captures the frame and drawing options but not `renderingTraitCollection`. Tiles execute later through [STULabelTiledLayer.mm:1019](Source/STULabel/Internal/STULabelTiledLayer.mm#L1019), outside the trait scope used by ordinary rendering.

A standalone layer with dark target traits, bounds 200 × 6000, contents scale 1, and "Line of text\n" repeated 200 times selected `STULabelTiledLayer`. Its four drawing callbacks observed light traits. Long labels can therefore draw semantic colors/custom content under the wrong environment; format selection and drawing may also use different traits.

### Preferred implementation

Capture an immutable target trait snapshot with each tile generation. Activate it once around each complete tile render, including custom drawing. Invalidate/cancel obsolete tile generations when the target changes. Use the same environment model as R04, and keep trait activation outside glyph/line loops.

### Acceptance criteria

- [x] Default and custom tile drawing observe the requested target traits.
- [x] Synchronous visible tiles and asynchronously prepared tiles are covered.
- [x] Changing traits cannot publish stale tiles from an older generation.
- [x] Bitmap-format selection and pixel rendering use the same environment.
- [x] Ordinary non-tiled rendering remains correct.
- [x] Validation includes the actual tiled path, not just the parent layer's initial display callback.

### Progress and completion record

2026-09-10 — Codex — Complete; committed as `01a1b86`.

Changes and rationale:
- Each installed tile drawing closure retains the layer's immutable `renderingTraitCollection` snapshot, the same snapshot active when selecting the image format. It activates that snapshot once around the complete default/custom drawing operation. The visible-tile and background-prerender paths already share this closure, so neither needs another environment property or per-glyph work.
- A changed target immediately clears tiled content, before scheduling the parent redraw. Replacing the tile drawing block removes existing tiles and uses the existing cancellation/abandonment ownership: running tiles lose their layer, receive cancellation, and are destroyed by their task after completion. They cannot rejoin the new generation. No generation counter or second cancellation mechanism was added.
- Equal snapshots remain a no-op. Pixel invalidation retains the existing text frame; the tests verify frame identity across dark/light/dark changes.

Coordination contract for R04–R06:
- R04 remains responsible for refreshing the complete snapshot from the view at its environment preparation/invalidation boundaries. It must use the layer setter, which now also retires deferred tiles. The tile callback captures the complete snapshot unchanged, including content size, direction, size class, and custom traits; it must not read a view or mutable layer on worker threads.
- R05 should resolve/cache preferred defaults against that explicit target upstream of shaping. Tile rendering neither selects fonts nor owns font invalidation. The regression uses an explicit font to isolate R03 from the still-open default-font issue.
- R06 should make the view's UIColor background authoritative and adopt the prerenderer's incoming background there. Tiles do not acquire a second background owner. Background adoption and target snapshot synchronization belong before render preparation/format selection.
- R03 required neither the R04 callback rewrite nor the R05/R06 behavior changes to fix deferred snapshot transport. R04, R05, and R06 have since completed.

Files/commit: `Source/STULabel/STULabelLayer.mm`, `Tests/STULabelTests/TiledRenderingTraitsTests.swift`, and this tracker; `01a1b86`.

Validation:
- Xcode MCP `BuildProject(buildForTesting: true)` and `RunSomeTests`, generated package workspace, `STULabel-Package`, iPhone 17 Pro (26.2), Xcode 27 Beta 6 / iOS 27 SDK. Test console confirms actual runtime **iOS 26.2 (23C54)**.
- All five Swift Testing cases pass: ordinary/tiled × default/custom drawing, plus an in-flight background tile held across a trait change. The tiled cases invoke the actual child layer after the parent's trait scope ends, inspect target appearance/content-size/direction/size-class values, verify RGB format for colored text, and inspect red/white pixels across dark/light/dark changes.
- The scrolling-driven background case proves that display returns while the tile callback is suspended, then verifies immediate retirement of old tile contents and drawing under the new target after resumption.
- A scoped baseline comparison removed only the two production changes and rebuilt: both ordinary cases passed, both tiled pixel/trait cases failed, and the background case failed its old-trait and immediate-retirement assertions. Baseline result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/46AFAB49-5F9D-46D1-8BA6-A4B3AB571BFC.txt`.
- Restored the production fix, rebuilt, and reran successfully. Final result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/F8D7A93F-3DE0-4F5B-8C60-4661A62EB1FE.txt`.

Remaining scope: G01 remains open. No timing claim or aggregate-suite health claim is made.

### Follow-up review — 2026-09-11

**Status: Complete (retained).** The immutable target capture encloses the complete tile draw. Existing clear/cancel ownership prevents abandoned tiles from publishing into a replacement generation, without a second generation system. All five tile cases passed again, including in-flight abandonment. No additional defect found in this resolution. Shared validation details appear in the final follow-up assessment.


## R04 — Synchronize the complete rendering environment

**Classification:** Must fix  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabel.mm:1077](Source/STULabel/STULabel.mm#L1077) updates layout direction without refreshing the layer's trait snapshot. The nearby content-size callback adjusts fonts but likewise leaves the snapshot stale. Complete synchronization occurs only in selected display/color callbacks.

After a label's preferred-content-size override changed to accessibility XXXL and traits were updated, the view reported XXXL while `layer.renderingTraitCollection` still reported Large. Custom drawing and dynamic providers can observe stale traits. [STULabelLayer.h:23](Source/STULabel/STULabelLayer.h#L23) promises that the view keeps this collection synchronized.

### Preferred implementation

Make the view own a coherent rendering-environment snapshot, updated at rendering invalidation/preparation boundaries with appropriate trait dependencies. Pass the complete snapshot unchanged through sync, async, prerendered, and tiled paths. Include content-size and direction changes; consider size-class/custom-trait dependencies supported by drawing callbacks.

Do not use ambient background-thread traits or repeatedly add unrelated callback-specific assignments without an ownership model.

### Acceptance criteria

- [x] The layer snapshot agrees with relevant current view traits before rendering.
- [x] Content-size, layout-direction, display properties, and appearance changes are covered.
- [x] Custom drawing receives the correct environment.
- [x] Async results are accepted only for the environment that produced them.
- [x] Trait-only pixel changes preserve shaping/layout where those stages do not depend on the changed traits.
- [x] R03, R05, and R06 use this model without competing state owners.

### Progress and completion record

2026-09-10 — Codex — Complete; committed as `133a242`.

Changes and ownership:
- The view owns environment synchronization in `updateRenderingEnvironment`. One registration replaces the separate appearance/display/direction callbacks and the conditional content-size registration. Standard appearance, content-size, direction, display, idiom, and size-class changes publish the complete immutable collection through the existing layer setter, even when Dynamic Type adjustment is disabled.
- Layout preparation, explicit view display invalidation, window changes, and prerenderer configuration use that same update. The layer invokes a private, cached delegate method before synchronous/asynchronous rendering and before accepting completed work. Worker threads retain snapshots and never access the view.
- Async completion detaches the finishing task before synchronizing the view, then rejects results if layout was invalidated or the full trait collection/display scale no longer matches. This also covers already queued completions and waiting prerenderers when no trait invalidation callback ran.
- Drawing-only changes retain the existing text frame. Display-scale changes update scale, while unrelated traits preserve an explicitly assigned contentScaleFactor. Semantic content direction and the existing opt-in font scaling behavior remain supported.
- Custom drawing or dynamic-color dependencies beyond the standard registered traits use UIKit's `registerForTraitChanges` with `label.setNeedsDisplay()`. This is documented on `drawingBlock` and tested with a custom trait. Background-thread trait reads cannot participate in UIView automatic trait tracking. The complete snapshot, including custom values, is still checked before every render and async publication.

Coordination:
- R03 consumes this snapshot and immediately retires obsolete tiled generations through the layer setter. Its five regression cases remain passing. R03 was committed as `01a1b86`.
- R06's authoritative view background adoption was required before centralizing color resolution and was committed separately as `ba2e4ef`. Prerenderer CGColor imports are static UIColors; normal dynamic UIColor assignments retain identity.
- R05 subsequently resolved and cached preferred defaults against this same explicit layer snapshot upstream of shaping in `f2b11be`.

Files: `Source/STULabel/STULabel.mm`, `Source/STULabel/STULabel.h`, `Source/STULabel/STULabelLayer.mm`, `Source/STULabel/STULabelLayer-Internal.hpp`, and `Tests/STULabelTests/RenderingEnvironmentTests.swift`.

Validation:
- Xcode MCP, STULabel-Package, iPhone 17 Pro (26.2), Xcode 27 Release Candidate / iOS 27 SDK. Console confirms actual runtime **iOS 26.2 (23C54)**. After a stalled headless service connection, the same MCP APIs were invoked through `mcpbridge` connected to the running Xcode app; no command-line build or simulator substitute was used.
- `BuildProject(buildForTesting: true)` passed. `RunSomeTests` selected entire suites so all parameterized cases ran: four R04 environment cases, six R06 background cases, five R03 tiled cases, and six existing intrinsic-layout cases — **21 passed, zero failed**.
- A scoped baseline comparison restored only the three R04 production files to the committed R03/R06 state and rebuilt. All four R04 cases failed: stale content-size/custom traits and acceptance of obsolete regular/prerendered async results. Baseline result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/9B9464A6-C413-4A0A-9DD7-04402A6D9F7F.txt`.
- Restored the R04 implementation, rebuilt, and reran all 21 focused cases successfully. Final result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/379A7A2B-56CF-4CC5-9768-9C2A9C3EB608.txt`. `git diff --check` passed.

Remaining scope: G01 remains open. This is focused iOS 26.2 correctness evidence, not aggregate-suite, Xcode 26 toolchain, or performance-benchmark evidence.

### Follow-up review — 2026-09-11

**Status: Complete after follow-up correction.** The consolidated view-owned update, documented custom-trait invalidation contract, cached main-thread preparation callback, and completion-time full-snapshot/scale rejection form a coherent design. All four original environment cases passed again, including regular and prerendered async rejection. The completed-task review subsequently found that the registered dependency set omitted `UITraitLegibilityWeight`, so UIKit did not publish Bold Text changes into the layer snapshot. Replacement implicit text could therefore resolve a regular font while the view requested bold text.

2026-09-11 — Codex — Follow-up corrected.

Changes and rationale: Added `UITraitLegibilityWeight` to the existing centralized rendering-trait registration. This uses the same view-owned update and layer invalidation path as content size, appearance, direction, display, idiom, and size classes; it does not introduce a second callback or any work in shaping, layout, drawing, or scrolling loops. Existing implicit content retains its effective font under the documented opt-in scaling contract, while replacement content resolves the preferred body font from the newly published Bold Text environment.

Files: `Source/STULabel/STULabel.mm`, `Tests/STULabelTests/RenderingEnvironmentTests.swift`, and this tracker.

Validation: Xcode MCP `BuildProject(buildForTesting: true)` passed with Xcode 27 Release Candidate / iOS 27 SDK. The focused Swift Testing regression transitions an attached label from regular to bold legibility, verifies the complete layer snapshot, verifies existing-content stability, and then verifies that replacement implicit text uses the target-compatible bold preferred body font. The existing system-trait parameter sequence now also includes legibility weight. All five RenderingEnvironment cases and nine DynamicTypeFontScaling cases passed on the iPhone 17 Pro simulator, actual iOS 26.2; result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/D5887B56-9EF6-4E11-ABDE-D5D601CDF173.txt`.


## R05 — Trait-correct preferred default fonts

**Classification:** Must fix  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabelLayer.mm:402](Source/STULabel/STULabelLayer.mm#L402), `defaultFont`, globally caches `preferredFontForTextStyle:UIFontTextStyleBody` once. [Missing attributed-string fonts](Source/STULabel/STULabelLayer.mm#L558) use that result regardless of the label's traits. [Enabling Dynamic Type adjustment](Source/STULabel/STULabel.mm#L1033) records the current category without immediately applying it.

After warming the default at Large, a label overridden to accessibility XXXL with adjustment enabled received a 17-point default font for text lacking an explicit font. UIKit's preferred body font compatible with the label's traits was 53 points.

### Preferred implementation

Resolve the preferred default against the explicit target traits. Cache per relevant font environment or per layer and invalidate appropriately. Apply the current category when enabling adjustment. Plain text and missing attributed-string fonts should share the same default resolution, coordinated with R10.

### Acceptance criteria

- [x] A label created after the global default was first used still gets its own correct preferred font.
- [x] Different local trait environments do not contaminate one another.
- [x] Enabling adjustment applies the current category immediately.
- [x] Plain and partially attributed text use consistent defaults.
- [x] Explicit consumer-provided font semantics remain intentional and documented.
- [x] Font resolution/caching avoids repeated expensive work in shaping or drawing loops.

### Progress and completion record

2026-09-11 — Codex — Complete; committed as `f2b11be`, separately from R04.

Changes and rationale:
- The process-wide preferred-body-font singleton was replaced by a lazy per-layer default resolved with the layer's complete `renderingTraitCollection`. A trait transition preserves an already-effective implicit plain-text font, maintaining the opt-in Dynamic Type contract, then retires the resolver cache so newly assigned content uses the new target environment. Resolution remains upstream of shaping and drawing.
- Enabling `adjustsFontForContentSizeCategory` now immediately runs the existing adjustment path for the current category. The plain-text path assigns even when UIKit returns the same font object so a newly resolved implicit default replaces any attributed string materialized under the previous category. Partially attributed text continues through the existing preferred-font scaler, which leaves explicit fixed fonts unchanged.
- The `STULabel` and `STULabelLayer` contracts now state which trait collection resolves defaults and that consumer-provided fonts are preserved. R10's attributed-string copy optimization remains separate.

Files/commit: `Source/STULabel/STULabel.h`, `Source/STULabel/STULabel.mm`, `Source/STULabel/STULabelLayer.h`, `Source/STULabel/STULabelLayer.mm`, `Tests/STULabelTests/DynamicTypeFontScalingTests.swift`, and this tracker; `f2b11be`.

Validation:
- Xcode MCP, generated package workspace, `STULabel-Package`, iPhone 17 Pro. `BuildProject(buildForTesting: true)` passed.
- Before the production change, all three new regressions failed: a layer targeted at accessibility XXXL received the globally warmed 17-point body font instead of 53 points, plain and partially attributed defaults were likewise 17 points, and enabling adjustment left materialized text at 17 points. Baseline result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/777DB961-CD09-4E7D-89F2-F7B6B5F1EE22.txt`.
- Final focused validation passed all six Dynamic Type tests and all 15 R03/R04/R06 rendering-environment, tiled-rendering, and prerendered-background cases. Results: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/1B8DCA65-97D5-4E4E-A114-7786725EF92C.txt` and `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/A4275653-5C80-4740-9FE5-A79F7A14A424.txt`.
- The aggregate plan was also retried. It remained red at 73 passed, 108 failed, and two not run: five Objective-C Unicode tests rejected the simulator's ICU data version, snapshot/layout assertions failed, and the Swift test host repeatedly restarted, causing entire suites (including the independently passing R03–R06 suites) to be reported as crashes. Aggregate result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunAllTests/5D7C2723-5422-4E27-AA2B-2616F0249C59.txt`.

Remaining scope: R10 may remove eager attributed-string normalization without changing the default-font ownership established here. Aggregate test-plan stabilization is outside R05.

### Follow-up review — 2026-09-11

**Status: Complete (resolved).** Per-layer resolution fixes cross-label contamination, but a trait transition previously promoted an implicit default into the explicit-font storage.

[setRenderingTraitCollection](Source/STULabel/STULabelLayer.mm#L237) copies `defaultFont_` into `font_`. [setText](Source/STULabel/STULabelLayer.mm#L390) preserves that value as though the consumer assigned it. This contradicts the comment/completion record that new content uses the new rendering environment.

Reproduction, Xcode MCP RunCodeSnippet on **iOS 27.0 (24A434)**:
1. Set Large traits, assign plain text, and resolve its default: 17 points.
2. Change traits to accessibility XXXL: existing text appropriately stays 17 without opt-in adjustment.
3. Assign different plain text: it still receives 17, although the target-compatible body font is 53.
4. Assign a fresh attributed string without a font: it receives 53.

Preferred fix: retain the distinction between an explicit consumer font and the effective implicit font of existing content. Preserve old content when adjustment is disabled, but retire its implicit font when replacing the content. Resolve the new default against current traits. Clearing every `font_` on text assignment would wrongly discard explicit consumer fonts.

Additional completion criteria:
- [x] Replacement plain text uses the current implicit default after a category transition.
- [x] New plain and partially attributed content agree after prior font queries and prior materialization/rendering.
- [x] Existing content remains stable with adjustment disabled, and enabling adjustment applies immediately.
- [x] Explicit fonts survive replacement and trait changes as documented.
- [x] Run focused transition regressions on actual iOS 26.

All six existing Dynamic Type cases passed on iOS 26.2; none covers this replacement transition. R10's allocation work remains separate and was not re-reviewed.

2026-09-11 — Codex — Follow-up resolved.

Changes and rationale: Added explicit font provenance to the layer independently of the stored effective font. Trait changes may retain an implicit font for the current content, but replacing that content retires the retained font and its cached plain-text attributes before resolving the current trait-compatible default. First-character provenance is captured before attributed-string default insertion, so converting replacement attributed content to plain text preserves an explicit consumer font but not a layer-injected default. Dynamic Type's internal plain and attributed rewrites preserve the existing provenance instead of being mistaken for public font assignments. This adds only constant-time state transitions outside shaping and drawing loops.

Files: `Source/STULabel/STULabelLayer-Internal.hpp`, `Source/STULabel/STULabelLayer.mm`, `Source/STULabel/STULabel.mm`, `Source/STULabel/STULabel.h`, `Source/STULabel/STULabelLayer.h`, `Tests/STULabelTests/DynamicTypeFontScalingTests.swift`, and this tracker.

Validation: Xcode MCP, generated package workspace, `STULabel-Package`, iPhone 17 Pro simulator, actual iOS 26.2. Before the production change, the two implicit-font regressions failed at 17 points versus the expected 53 points while the explicit-font control passed. `BuildProject(buildForTesting: true)` passed. Final validation passed all nine Dynamic Type cases and six focused R03/R04/R06 rendering-environment cases in one 15-case run. Result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/E82441C6-022F-405B-8108-B556194D069E.txt`.

Remaining scope: R10's attributed-string allocation work remains separate. The aggregate plan was not rerun because its unrelated ICU, snapshot/layout, and host-restart failures are already recorded above.

### Prerenderer follow-up resolution — 2026-09-11

**Status: Complete after follow-up correction.** The completed-task review found that `STULabelPrerenderer` passed fontless attributed strings directly to `STUShapedString`, whose general-purpose fallback is a 12-point Core Text font. At accessibility XXXL this produced approximately 38 × 15 point prerendered layout instead of the direct label's 161 × 64 point preferred-body layout. After import, the label reported a 53-point public `font` while retaining the 12-point shaped layout.

Changes and rationale:
- The shared text-shaping task can now receive label defaults. Prerenderers resolve one preferred body font from their explicit target trait collection and inject missing font and semantic label-color attributes immediately upstream of shaping. Fully attributed input takes the existing no-copy path; missing defaults require one attributed-string scan and copy per shaping generation, outside glyph, line-layout, drawing, and scrolling loops.
- The prerenderer retains its original attributed string separately from the normalized string owned by the shaped result. A consuming layer reuses that normalized string and shape only when target traits match. When traits differ or no shape is reusable, the layer applies defaults to the original text using its own environment before reshaping. This prevents prerenderer-target fonts from leaking into a different consumer environment.
- Explicit first-character font provenance is transported independently of injected attributes, so later plain-text replacement still distinguishes a consumer font from an implicit default. Explicit fonts in other ranges are preserved.

Files: `Source/STULabel/Internal/LabelRenderTask.hpp`, `Source/STULabel/Internal/LabelRenderTask.mm`, `Source/STULabel/Internal/LabelPrerenderer.hpp`, `Source/STULabel/STULabelLayer.mm`, `Source/STULabel/STULabelPrerenderer.h`, `Tests/STULabelTests/DynamicTypeFontScalingTests.swift`, and this tracker.

Additional completion criteria:
- [x] Fontless and partially attributed prerenderer input use the preferred body font for the target traits.
- [x] A matching consumer reuses the normalized shaped result without a second default-insertion copy.
- [x] A mismatching consumer resolves implicit defaults for its own traits before reshaping.
- [x] Explicit range fonts and implicit first-character provenance survive configuration.
- [x] Missing semantic foreground color follows the same label-default contract.

Validation: Xcode MCP `BuildProject(buildForTesting: true)` passed with Xcode 27 Release Candidate / iOS 27 SDK. All 13 DynamicTypeFontScaling cases, five RenderingEnvironment cases, and two Objective-C prerenderer trait cases passed on the iPhone 17 Pro simulator, actual iOS 26.2 (23C54). The four parameter combinations cover fontless/partially attributed input across matching/mismatching consumer traits, compare imported and direct layout, inspect the prerenderer's normalized shape, and verify replacement implicit-font provenance. Result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/99A853C8-3A47-4E29-9977-1EC6297C7574.txt`.


## R06 — Single background-color owner across prerenderer configuration

**Classification:** Must fix  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabel.mm:2361](Source/STULabel/STULabel.mm#L2361), `configureWithPrerenderer:`, imports the prerenderer into the layer but does not synchronize the view's `_backgroundColor`. [Appearance updates](Source/STULabel/STULabel.mm#L1104) later regenerate the displayed background from that stale view value.

A red prerenderer background produced a red layer while `label.backgroundColor` was nil. Executing the appearance-update path cleared the red background. A previously configured view color can similarly overwrite the imported background.

### Preferred implementation

Adopt the incoming background into the view's authoritative state during prerenderer configuration. Preserve UIColor identity for normally assigned dynamic view colors and derive displayed CGColor from that state. Define the imported prerenderer color semantics explicitly instead of special-casing the next appearance callback.

### Acceptance criteria

- [x] Configuring a fresh label imports a coherent view/layer background.
- [x] Configuring a label with an existing background replaces it consistently.
- [x] Subsequent appearance changes do not erase or restore stale colors.
- [x] Normal dynamic UIColor backgrounds still resolve against target traits.
- [x] Nil/transparent backgrounds and relevant opacity/render-format state remain coherent.

### Progress and completion record

2026-09-10 — Codex — Complete; committed as `ba2e4ef`, separately from R04.

Changes: `configureWithPrerenderer:` adopts the incoming resolved CGColor as a static UIColor in the view before the layer can notify its delegate. This replaces nil or existing view backgrounds consistently; later environment updates derive the displayed color from that authoritative state. Normally assigned dynamic UIColor identity is preserved. The public configuration method documents the imported color semantics.

Files: `Source/STULabel/STULabel.mm`, `Source/STULabel/STULabel.h`, and `Tests/STULabelTests/PrerenderedBackgroundTests.swift`.

Validation: Xcode MCP, STULabel-Package, iPhone 17 Pro / actual iOS 26.2 (23C54). All six background combinations passed: fresh/existing view background × nil/red/transparent import, followed by dark/light changes and normal dynamic background assignment. These cases passed within the 21-case rendering/layout regression run on Xcode 27 Release Candidate, result `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/67E0A2EC-EDD1-4CC1-AEC0-75BB17B94B61.txt`. The tests were then moved into their own suite for the atomic R06 commit.

Remaining scope: R04 owns complete environment synchronization; R05's default-font behavior remains separate.

### Follow-up review — 2026-09-11

**Status: Complete (retained).** Background adoption precedes layer-configuration callbacks; imported CGColors intentionally become static UIColors, and normal dynamic UIColor identity remains view-owned. All six background combinations passed again. No additional defect found; retain the single-owner implementation.


## R07 — Preserve disabled link colors during tint/lifecycle changes

**Classification:** Must fix  
**Status:** Complete
**Owner:** Unassigned

### Problem and evidence

[STULabel.mm:1178](Source/STULabel/STULabel.mm#L1178), `tintColorMayHaveChanged`, assigns tint or `UIColor.linkColor` even when an explicit disabled-link override should remain active. The helper runs from tint, superview, and window callbacks.

A label with red `disabledLinkColor` and `isEnabled == false` initially had a red override; `tintColorDidChange` replaced it with the system link color.

### Preferred implementation

Consolidate effective link-color calculation. Apply an explicit disabled override first, then the intended tint/dimming/default-link rules. Reuse the calculation from property/state setters and lifecycle callbacks.

### Acceptance criteria

- [x] Disabled-link overrides survive tint and hierarchy/window changes.
- [x] Enabled/disabled transitions select the appropriate color.
- [x] Explicit override removal restores the intended fallback.
- [x] Tint usage and dimmed-tint behavior remain intentional.
- [x] Native Testing coverage checks observable effective colors, including the original regression.

### Progress and completion record

2026-09-09 — Codex — Complete; committed as `e4d71f1`.

Changes and rationale: Consolidated every state and lifecycle update of `overrideLinkColor` around one
effective-color calculation. An explicit disabled override now wins before tint/dimming/default-link
fallbacks, so UIKit tint, superview, and window callbacks cannot replace it. Clearing that override
uses the current effective tint (including UIKit's disabled dimming), and re-enabling restores the
configured regular-link behavior.

Files/commit: `Source/STULabel/STULabel.mm` and `Tests/STULabelTests/SwiftWrapperTests.swift`;
`e4d71f1`.

Validation, environment, and results: `build-for-testing` and the native Swift Testing suite
`SwiftWrapperTests` passed on Xcode 27 Beta 6, iPhone 17 Pro simulator, iOS 26.2. The test
`STULabel preserves disabled link color through tint and hierarchy changes` covers the reported tint
regression, superview and window lifecycle callbacks, override removal with dimmed tint, and re-enabling. `git diff --check`
passed.

Remaining risk/blocker and next action: None for this finding.

### Follow-up review — 2026-09-11

**Status: Complete (retained).** State setters and lifecycle callbacks share the effective-color calculation, with explicit disabled overrides taking precedence. The focused tint/hierarchy case passed again. No additional defect found; retain this centralized calculation.


## R08 — Remove unsafe flags from the public package dependency graph

**Classification:** Must fix for reusable package distribution  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[Package.swift:34](Package.swift#L34) exports unsafe flags through the core library target, including ARC/modules/RTTI settings and release exception/assertion switches. Both library products depend on that target.

SwiftPM restricts consumption of products containing unsafe flags by other packages. A successful local path consumer does not establish normal versioned distribution. [SwiftPM PackageDescription documentation](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)

[Integration/PackageConsumer/Package.swift:14](Integration/PackageConsumer/Package.swift#L14) uses a local path dependency. The README acknowledges the unsafe-flags limitation. A tagged downstream-package build was not completed during the review.

### Preferred implementation

Remove exported unsafe flags using supported package settings/defaults and the simplified ARC architecture. Keep project-specific performance/build switches out of the public dependency graph. Do not delete flags blindly if doing so changes required behavior; account for assertions, exception policy, and Objective-C/C++ compilation.

Add a consumer that resolves a tagged SCM dependency through another package. If indispensable flags truly prevent source distribution, make a deliberate binary distribution decision rather than calling a local-path exception complete.

### Acceptance criteria

- [ ] Public products are usable by a downstream package resolving a versioned SCM dependency.
- [ ] Objective-C and Swift public product/module visibility is validated.
- [ ] Debug and Release configurations build through the supported package interface.
- [ ] Resources needed by consumers are located correctly.
- [ ] Required ARC and C++ behavior is preserved without exported unsafe settings, or an explicitly approved distribution alternative is documented.
- [ ] README and G01 reflect verified consumer support rather than only local-package success.

### Progress and completion record

No implementation recorded. Next: classify each unsafe flag as redundant, replaceable, local-only, or genuinely required.

## R09 — Restore deliberate rendering concurrency

**Classification:** Strong improvement; structural performance regression  
**Status:** Open  
**Owner:** Unassigned  
**Snapshot note:** The queue changes were uncommitted at review time.

### Problem and evidence

[STULabelTiledLayer.mm:373](Source/STULabel/Internal/STULabelTiledLayer.mm#L373), `maximumPriorityQueue`, now creates a shared serial queue. [Visible-tile rendering](Source/STULabel/Internal/STULabelTiledLayer.mm#L339) still calls synchronous `dispatch_apply` on it. Independent tiles execute sequentially while display waits. Targeting a global concurrent queue does not make the child queue concurrent.

[LabelPrerenderer.hpp:392](Source/STULabel/Internal/LabelPrerenderer.hpp#L392) also makes default prerendering serial across unrelated labels and lowers its priority to Utility. One expensive label can delay unrelated work.

The loss of parallelism follows directly from the queue configuration. No measured frame-time or throughput regression was established.

### Preferred implementation

Retain concurrent execution for independent visible tiles. If limiting background work is desirable, use an explicit bounded scheduling policy with cancellation and priority handling. Do not accidentally serialize urgent visible work behind unrelated rendering.

### Acceptance criteria

- [ ] Independent visible tiles can execute concurrently.
- [ ] Default prerender scheduling and priority have an explicit rationale.
- [ ] Cancellation, lifetime, and completion semantics remain correct under concurrency.
- [ ] Comparable repeated before/after measurements cover representative long-label and multi-label workloads.
- [ ] Results distinguish simulator noise, throughput, frame latency, and memory tradeoffs.
- [ ] No numerical performance claims are made without recorded measurements.

### Progress and completion record

No implementation recorded. Next: establish why the serial queues were introduced and compare candidate scheduling policies.

## R10 — Avoid eager attributed-string normalization

**Classification:** Strong improvement; likely practical allocation/assignment cost  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabelLayer.mm:558](Source/STULabel/STULabelLayer.mm#L558), `addMissingDefaultTextAttributes`, creates a mutable copy, enumerates fonts, separately enumerates foreground colors, and copies back even for fully specified strings.

Replacing the original immutable object also weakens the identity fast path in [the setter](Source/STULabel/STULabelLayer.mm#L503): reassigning the same original object can repeat the scans and copies. This adds work during cell configuration before shaping begins.

### Preferred implementation

Prefer resolving defaults during the existing attribute-processing pass. If stored normalization is required by the public contract, enumerate once and copy only upon the first necessary mutation. Preserve fully specified immutable input identity. Coordinate the default-font semantics with R05.

### Acceptance criteria

- [ ] Fully specified immutable input avoids unnecessary normalization copies.
- [ ] Reassigning the same original object preserves a useful fast path.
- [ ] Partially specified font/color runs receive correct defaults.
- [ ] Mutable caller input is still isolated according to the copy contract.
- [ ] Dynamic UIColor identity is retained through shaping.
- [ ] Representative allocation/assignment measurements support any performance claims.

### Progress and completion record

No implementation recorded. Next: establish whether normalized storage is a public requirement or can be deferred to the existing style pass.

## R11 — Reduce historical Auto Layout retry machinery

**Classification:** Strong improvement; deletion requires focused evidence  
**Status:** Complete
**Owner:** Codex

### Problem and evidence

[STULabel.mm:725](Source/STULabel/STULabel.mm#L725) retains coordination around constraint-update state, expected bounds callbacks, Auto Layout's knowledge of intrinsic size, and forced superview layout. Relevant state includes `intrinsicContentSizeIsKnownToAutoLayout`, `waitingForPossibleSetBoundsCall`, and `didSetNeedsLayoutOnSuperview`. Part of the rationale cites historical `rdar://34422006`.

This is a substantial complexity/invalidation opportunity. The review did not prove that the original UIKit bug is fixed on iOS 26.

### Preferred implementation

Keep necessary width-dependent measurement caching and baseline-guide updates. Reduce the surrounding protocol to direct bounds-change and intrinsic-size invalidation, retiring retry branches only after focused modern-runtime scenarios establish the resulting behavior.

### Acceptance criteria

- [x] iOS 26 self-sizing, constrained width changes, and multiline resizing are covered.
- [x] Baseline alignment and relevant layout-guide updates remain correct.
- [x] Constraints/bounds changes converge without repeated or missing layout.
- [x] Necessary measurement fast paths remain intact.
- [x] Deleted branches have a recorded rationale and replacement behavior.
- [x] If a workaround remains necessary, record a concrete reproduction and reduce its scope rather than assuming the entire old mechanism is required.

### Progress and completion record

2026-09-09 — Codex — Complete; committed as `3e4b8d2`.

Changes and rationale:
- Removed `isUpdatingConstraints`, `intrinsicContentSizeIsKnownToAutoLayout`, `waitingForPossibleSetBoundsCall`, and `didSetNeedsLayoutOnSuperview`. Intrinsic measurements now record their width directly, including public queries outside UIKit's constraint-update callback. The previous stored height is no longer needed.
- Retained the maximum-width measurement cache and the multiline width-validity interval. Bounds changes that affect only height/origin skip intrinsic-size invalidation; single-line width changes retain their fast path.
- Kept one coalesced follow-up layout request per intrinsic-size invalidation, consumed in `layoutSubviews`. iOS 26.2 still needs this: removing the request left a newly constrained multiline label 203 points too short; moving the request into `setBounds:` did not resolve it. With baseline constraints, UIKit can query the new measurement without applying it in the same pass, so consuming the flag in `intrinsicContentSize` also fails. No expected-bounds-callback tracking, recursive constraint-update state, or alternating retry suppression remains.
- Preserved content and baseline guide updates. Focused baseline coverage also exposed an existing coordinate bug: with a 7-point top inset, baseline anchors were 7 points above the rendered baselines. Guide constants now include the text-frame origin; line-height spacing metadata is unchanged.

Files: `Source/STULabel/STULabel.mm`, new Swift Testing suite `Tests/STULabelTests/IntrinsicContentSizeTests.swift`, and this tracker. Existing `AutoLayoutTests.swift` and snapshot references are unchanged.

Validation:
- Xcode MCP, generated package workspace, `STULabel-Package`, iPhone 17 Pro (26.2), Xcode 27 Beta 6 / iOS 27 SDK. Console confirms actual runtime **iOS 26.2 (23C54)**.
- `BuildProject(buildForTesting: true)` passed. `RunSomeTests` passed all six new tests, covering both intrinsic-width settings, narrowing/widening, multiline text replacement and clearing, self-sizing container fitting, font/inset changes, baseline positions, content guides, stable subsequent layout calls, and single-line/height-only invalidation fast paths.
- Final focused result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/85087173-27AD-475D-B786-8AECBD2C6609.txt`.
- Existing Auto Layout checks: content-guide and guide-deallocation tests passed. Three snapshot tests (baseline anchors, spacing constraints, and non-label spacing) still differ from stored references. A scoped A/B run restored the original `STULabel.mm` and reproduced the same failures; all 17 generated snapshot PNGs were byte-identical between original and patched implementations. Original comparison result: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/78DD89B8-16F7-452A-8B64-4A37A9D19C0E.txt`. The R11 patch was then restored and the six new tests rerun successfully.
- `git diff --check` passed. No snapshot rerecording or push.

Remaining scope: snapshot reference differences remain outside R11; G01's other release gates remain open. This establishes the focused iOS 26.2 behavior, not an Xcode 26 toolchain result or a timing benchmark.

### Follow-up review — 2026-09-11

**Status: Complete (resolved below; originally reopened as Must fix, P2).** The original retry simplification remains sound.

Keep the reduced invalidation state, maximum-width cache, width-validity interval, and coalesced follow-up backed by the documented iOS 26 reproduction. All six intrinsic-layout cases passed again on actual iOS 26.2.

The baseline correction remains incomplete for nonzero bounds origins. [updateBaselinesLayoutGuide](Source/STULabel/STULabel.mm#L319) adds the text-frame origin to the baseline, then treats that label-coordinate Y value as a distance from `label.topAnchor`. It must also account for `label.bounds.minY`. [STULabelLayoutInfo.h](Source/STULabel/STULabelLayoutInfo.h#L18) explicitly defines baseline values in label coordinates.

Reproduction, Xcode MCP RunCodeSnippet on **iOS 27.0 (24A434)**: place a label at parent y=20 with a 7-point top inset, 20-point font, width 200 and height 100; constrain a marker to `firstBaselineAnchor`. At bounds origin zero, the marker and converted public first baseline both equal y≈46.33. Set `bounds.origin.y = 9` and lay out: the marker stays y≈46.33, while `label.convert(CGPoint(x: 0, y: label.layoutInfo.firstBaseline), to: parent).y` equals y≈37.33. Returning the origin to zero restores agreement.

This is a residual coordinate issue, not evidence that the retry simplification introduced the bounds-origin behavior. Existing tests cover origin-only intrinsic invalidation but compare baseline anchors only with zero bounds origins.

Preferred fix: derive first/last baseline constants as distances from the bounds minimum, and refresh those guide constants when bounds origin changes. Preserve the origin-only intrinsic-measurement fast path; updating guide coordinates does not require reshaping or intrinsic invalidation.

Additional completion criteria:
- [x] First/last baseline anchors match converted baseline coordinates for positive, negative, and zero bounds origins.
- [x] Origin changes refresh guide constants without intrinsic-size measurement invalidation.
- [x] Insets, vertical alignment, and baseline spacing remain correct.
- [x] Add actual iOS 26 coverage and retain the passing convergence cases.

### Reopened issue completion — 2026-09-11

**Status: Complete.**

Changes and rationale:
- Baseline guide constants now convert label-coordinate baseline values into distances from `topAnchor` by subtracting `bounds.minY` after adding the text-frame origin.
- `setBounds:` refreshes an existing baseline guide when the bounds Y origin changes. This updates only guide geometry; the width-based intrinsic invalidation decision remains unchanged, so origin-only changes retain the intrinsic-measurement fast path.
- The focused Swift Testing regression covers first and last baseline anchors at zero, positive, and negative bounds origins with top, center, and bottom vertical alignment, nonzero content insets, and a line-height spacing constraint. It also verifies that origin changes do not invalidate intrinsic size and that the spacing constant remains stable.

Validation:
- Xcode MCP, generated package workspace, `STULabel-Package`, iPhone 17 Pro (26.2), iOS 27 SDK. Console confirms actual runtime **iOS 26.2 (23C54)**.
- `BuildProject(buildForTesting: true)` passed. Log: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/BuildProject/BuildProject-Log-20260911-110652.txt`.
- `RunSomeTests` passed all seven `IntrinsicContentSizeTests`, including the new bounds-origin regression and the six retained convergence/fast-path cases. Summary: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/94440884-0B67-4378-B128-DAB2BFCFC521.txt`. Runtime evidence: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/test-console-log-2026-09-11T11-07-07+10-00.txt`.
- `git diff --check` passed. No snapshot references were changed and no push was performed.

Remaining scope: snapshot reference differences and G01's release gates remain outside R11. No timing claim or aggregate-suite health claim is made.


## R12 — Remove unreachable accessibility non-rotor branch

**Classification:** Optional cleanup  
**Status:** Complete
**Owner:** Unassigned

### Problem and evidence

[STUTextFrameAccessibilityElement.mm:672](Source/STULabel/STUTextFrameAccessibilityElement.mm#L672) sets `createRotorLinks` permanently to true but keeps conditional element-class selection and rotor assignment.

### Preferred implementation

Construct the rotor-link element directly and assign its rotor unconditionally. Remove only the unreachable alternatives. Do not delete an element class still used elsewhere.

This is a clarity improvement; the compiler likely already removes the dead branch. Do not extend the deletion to unrelated VoiceOver/CoreText workarounds merely because they mention older releases.

### Acceptance criteria

- [x] The constant and unreachable alternatives are removed.
- [x] Remaining element classes still serve their actual callers.
- [x] Link accessibility/rotor construction preserves observable behavior.
- [x] No unnecessary test harness or unrelated accessibility rewrite is added.

### Progress and completion record

Removed the permanent `createRotorLinks` switch and directly create rotor-link elements with an
unconditional rotor assignment. The shared subelement type remains in its non-rotor callers.
The iOS 26.2 package build and existing accessibility-element lifecycle test pass.

2026-09-10 — Codex — Complete; committed as `31b6916`.

### Follow-up review — 2026-09-11

**Status: Complete (retained).** The removed conditional was permanently true, and the shared subelement class remains in use elsewhere. The existing accessibility-element lifetime case passed again. No additional defect found; retain the direct rotor construction.


## R13 — Document the breaking consumer migration contract

**Classification:** Release requirement; intentional API changes, not automatically bugs  
**Status:** Open  
**Owner:** Unassigned

### Changes to explain

- iOS 26 minimum and supported platform/toolchain policy.
- CocoaPods migration, public `STULabel` versus `STULabelSwift` products, imports, resources, and verified downstream-package support.
- Removed long-press APIs/delegate callbacks; delegate-driven context menus replace prior built-in link actions. See [STULabel.mm:1546](Source/STULabel/STULabel.mm#L1546).
- Explicit prerenderer rendering traits and unavailable old initializer. See [STULabelPrerenderer.h:34](Source/STULabel/STULabelPrerenderer.h#L34).
- Removed global main-screen helpers. See [STUMainScreenProperties.h](Source/STULabel/STUMainScreenProperties.h).
- Preferred font, semantic text/link colors, and changed tint defaults.
- Image helper default scale now 1 rather than main-screen scale. See [STUImageUtils.overlay.swift](Source/STULabelSwift/STUImageUtils.overlay.swift).
- Uncommitted ownership changes at review time retain the prerenderer until work finishes and expose explicit cancellation; dropping the caller's reference is no longer the same abandonment mechanism.
- Any further API/behavior changes resulting from R01–R12.

### Preferred implementation

Write a concise migration guide with before/after examples and explicit behavior choices. Treat this as a breaking release. Avoid resurrecting obsolete wrappers solely to conceal the changes. If built-in link-action parity is desired, implement it through the modern context-menu model and record that decision.

### Acceptance criteria

- [ ] Each removed or changed public API has an accurate replacement or an explicit removal rationale.
- [ ] Examples compile against the final public package products.
- [ ] Cancellation/ownership and trait responsibilities are explicit.
- [ ] Changed defaults and link-action behavior are visible to consumers.
- [ ] Supported destinations and distribution claims match G01 evidence.
- [ ] The guide reflects the final implementation rather than the review snapshot.

### Progress and completion record

No migration update recorded. Next: inventory the public API diff and maintain the guide alongside the fixes.

## G01 — Establish downstream and iOS 26 validation

**Classification:** Release validation gate; unresolved build symptoms are not yet attributed source defects  
**Status:** Open  
**Owner:** Unassigned

### Existing evidence and uncertainty

The package itself passed iOS build-for-testing and a Catalyst build. Demo and local downstream consumer builds failed to resolve `STULabelSwift`; the cause was not established. These failures prevent claiming downstream health but should not be presented as a proven manifest defect without diagnosis.

The generated package workspace is `.swiftpm/xcode/package.xcworkspace`, scheme `STULabel-Package`. Demo is `Demo/STULabel.xcodeproj`. The local consumer workspace is `Integration/PackageConsumer/.swiftpm/xcode/package.xcworkspace`.

### Required completion evidence

- [ ] Package builds in supported configurations using the documented toolchain.
- [ ] Demo builds against the real package products for iOS and Catalyst where supported.
- [ ] The standalone downstream consumer resolves and builds.
- [ ] R08's versioned SCM consumer succeeds; local path consumption alone does not satisfy this.
- [ ] Focused correctness fixes run on an actual iOS 26 runtime, with runtime identity recorded.
- [ ] Relevant native interaction/VoiceOver scenarios are exercised where unit/protocol tests are insufficient.
- [ ] Meaningful required checks are complete; known unrelated suite failures are separated from patch failures.
- [ ] Remaining release limitations have explicit owners and decisions.

### Progress and completion record

No further validation recorded. Next: reproduce and diagnose product/module resolution through Xcode MCP without rewriting package configuration based solely on the error message.

## Architectural direction and completion assessment

The highest-risk findings are R01's recursive text-input notifications, R02's bidi navigation cycles, R03/R04's incorrect rendering environment, R05's default-font behavior, and R08's distribution restriction.

The most valuable cohesive improvements are:

1. One rendering environment for traits, defaults, and colors across every rendering mode.
2. Transactional displayed-document state plus shared visual-caret geometry.
3. Completed ARC/package consolidation with verified versioned downstream consumption.
4. Preserved immutable-string fast paths and deliberate parallel rendering.
5. Removal of obsolete Auto Layout/accessibility branches with focused modern-runtime evidence.

The initial review judged the branch cleaner in infrastructure but not yet ready to merge/release. CocoaPods removal, simpler ownership/synchronization, explicit traits, scene-aware behavior, and native interactions are worthwhile. The remaining work is to make ownership and invalidation consistent across those changes.

Do not replace specialized CoreText layout/drawing or remove old CoreText/VoiceOver workarounds solely because the OS floor increased. Preserve demonstrated fast paths, and require concrete behavioral evidence for deleting still-relevant workarounds.

### Final completion record

- Overall state: **Open — six tasks are complete; R01 and R05 remain reopened by the 2026-09-11 follow-up review.**
- Completed task IDs: R03 (`01a1b86`), R04 (`133a242`), R06 (`ba2e4ef`), R07 (`e4d71f1`), R11 (`3e4b8d2` plus the current bounds-origin follow-up), and R12 (`31b6916`).
- Previously completed tasks with additional work: R01 (`1bae9ff`) and R05 (`f2b11be`). Their original fixes and evidence remain recorded above.
- R02 remains Ready for review; it was outside this follow-up review's completed-only scope.
- Deferred/superseded task IDs and rationale: None recorded.
- Required validation still outstanding: R01 and R05's reopened criteria and the previously outstanding gates. Other open tasks and G01 were not re-reviewed.
- Follow-up reviewed commit/worktree: `4191e2a`, with the current implementations inspected in place. Existing uncommitted context-menu/drag-preview/color changes and Demo edits were identified and excluded from review findings.
- The subsequent R11 resolution modifies `Source/STULabel/STULabel.mm`, `Tests/STULabelTests/IntrinsicContentSizeTests.swift`, and this tracker. Existing unrelated worktree changes remain excluded.

## Completed-task follow-up assessment — 2026-09-11

Scope was strictly the eight tasks marked Complete at the start: R01, R03, R04, R05, R06, R07, R11, and R12. R02 and all open tasks were excluded. Source was reviewed as an integrated library, including ownership and invalidation boundaries shared by the completed tasks.

| Task | Follow-up outcome |
| --- | --- |
| R01 | Reopened, P1; resolved by the subsequent coherent-document completion recorded above. |
| R03 | Remains complete: tile trait capture and cancellation reuse are coherent. |
| R04 | Remains complete: shared environment preparation and async rejection are coherent. |
| R05 | Reopened, P2: an implicit font becomes a permanent override across replacement plain text. |
| R06 | Remains complete: background ownership/import semantics are coherent. |
| R07 | Remains complete: disabled-link precedence is centralized and preserved. |
| R11 | Reopened, P2 residual baseline defect; resolved by the subsequent R11 completion recorded above. |
| R12 | Remains complete: unreachable branch removed without broadening the change. |

### Fresh validation

- Toolchain: Xcode 27 Release Candidate / iOS 27 SDK.
- Xcode MCP `BuildProject(buildForTesting: true)` passed. Log: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/BuildProject/BuildProject-Log-20260911-101037.txt`.
- **29 focused cases passed on actual iOS 26.2 (23C54)**: DynamicTypeFontScalingTests (6), IntrinsicContentSizeTests (6), PrerenderedBackgroundTests (6), RenderingEnvironmentTests (4), TiledRenderingTraitsTests (5), the R01 publication case (1), and the R07 disabled-link case (1).
- Focused summary: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/3B0301FC-E5A1-4E95-8450-886C3FB0C05B.txt`. Console runtime evidence: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/test-console-log-2026-09-11T10-10-49+10-00.txt`.
- The existing accessibility-element lifetime case also passed: **30 selected existing cases passed overall**. Separate summary: `/var/folders/bq/pkfs0gjn1qz8mn678px902fh0000gp/T/ActionArtifacts/default/RunSomeTests/DF1390BE-D64F-4B64-B29E-546A423AD26D.txt`.
- Additional review probes used Xcode MCP RunCodeSnippet and reported **iOS 27.0 (24A434)**. They demonstrated the new R01/R05/R11 gaps described above. They are not claimed as new iOS 26 runtime reproductions.
- R01's document-shrink probe terminated the preview host with an Objective-C string-range exception. The tool surfaced `Preview service no longer running`; the associated crash report confirms SIGABRT and the composed-character indexing frame. This was separated from build/test infrastructure failures.
- No aggregate known-failing suite was rerun, no snapshots were rerecorded, and no new timing claims were made.
- Temporary diagnostic/result paths may be cleaned by the system; the reproduction steps and observations above are the durable handoff.

### Architectural assessment and next work

The completed work is substantially better than the original review snapshot. Rendering-environment ownership, deferred tile transport, background adoption, link-color precedence, and the reduced Auto Layout retry mechanism are cohesive improvements. There is no reason from this review to replace those successful designs.

The baseline coordinate boundary has since been completed under R11, and R01 now publishes document geometry with the string. The remaining ownership boundary from this assessment is preserving the distinction between implicit and explicit fonts under R05. Address that boundary directly rather than adding an isolated guard.

After each remaining fix, add focused regressions for the newly identified cases, run them on actual iOS 26, and update the task's status and this completion record. Passing the previous focused cases alone is insufficient to close the reopened findings.
