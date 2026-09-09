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
| R01 | Must fix | Transactional text-input document publication | Complete | Coordinated with R02 |
| R02 | Must fix | Visual caret navigation across bidi boundaries | Ready for review | Native UI smoke check blocked by Demo product resolution |
| R03 | Must fix | Preserve target traits in tiled rendering | Open | Share environment model with R04 |
| R04 | Must fix | Synchronize the complete rendering environment | Open | Coordinate with R03, R05, R06 |
| R05 | Must fix | Trait-correct preferred default fonts | Open | Coordinate with R04, R10 |
| R06 | Must fix | Single background-color owner across prerenderer configuration | Open | Coordinate with R04 |
| R07 | Must fix | Preserve disabled link colors during tint/lifecycle changes | Open | Independent, same STULabel.mm file |
| R08 | Must fix for distribution | Remove unsafe flags from public package dependency graph | Open | Coordinate with G01 and ARC work |
| R09 | Strong improvement | Restore deliberate rendering concurrency | Open | Uncommitted changes at review; coordinate with R03 |
| R10 | Strong improvement | Avoid eager attributed-string normalization | Open | Coordinate with R05 |
| R11 | Strong improvement | Reduce historical Auto Layout retry machinery | Complete | Narrow iOS 26.2 retry retained with reproduction and focused coverage |
| R12 | Optional cleanup | Remove unreachable accessibility non-rotor branch | Open | Narrow cleanup only |
| R13 | Release requirement | Document the breaking consumer migration contract | Open | Finalize after behavior/API decisions |
| G01 | Release validation gate | Establish real downstream and iOS 26 build/runtime health | Open | Includes R08's versioned-consumer check |

## R01 — Transactional text-input document publication

**Classification:** Must fix  
**Status:** Complete
**Owner:** Unassigned

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

2026-09-09 — Codex — Complete; uncommitted.

Changes and rationale: Made `_stu_displayedString` the document snapshot exposed by UITextInput getters and added an explicit publication guard. The delegate now observes the old snapshot during `textWillChange:`, the new snapshot during `textDidChange:`, and re-entrant getters cannot begin another transaction. The same transaction boundary covers layout/truncation-driven visible-string changes.

Files/commit: `Source/STULabel/STULabel+UITextInput-Internal.h`, `Source/STULabel/STULabel+UITextInput.mm`, and `Tests/STULabelTests/UITextInputTests.swift`; no commit.

Validation, environment, and results: The native Swift Testing case `Visible document publication is stable during delegate callbacks` passed after rebuild on Xcode 27 Beta 6, iPhone 17 Pro simulator, iOS 26.2 (test result `Test-STULabel-Package-2026.09.09_21-10-23-+1000.xcresult`). It covers re-entrant getters in both callbacks plus a truncation-driven document change. `clang-format --dry-run --Werror` and `git diff --check` passed.

Remaining risk/blocker and next action: None for this finding.

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

2026-09-09 — Codex — Ready for review; uncommitted.

Changes and rationale: Added storage affinity to text positions, then consolidated point hit-testing, adjacent-line navigation, horizontal navigation, and farthest-position selection around the existing text-frame grapheme/run geometry. Horizontal movement now walks visual grapheme edges without rebuilding the text frame; farthest positions inspect existing selection rects rather than choosing logical range endpoints.

Files/commit: `Source/STULabel/STULabel+UITextInput.mm` and `Tests/STULabelTests/UITextInputTests.swift`; no commit.

Validation, environment, and results: The native Swift Testing case `Visual caret movement retains affinity at bidirectional boundaries` passed after rebuild on Xcode 27 Beta 6, iPhone 17 Pro simulator, iOS 26.2 (test result `Test-STULabel-Package-2026.09.09_21-09-39-+1000.xcresult`). It covers the reported mixed string, farthest-right geometry, ordinary LTR, RTL, a composed emoji, and a wrapped line. `clang-format --dry-run --Werror` and `git diff --check` passed.

Remaining risk/blocker and next action: Native UIKit selection smoke testing is blocked: Device Interaction supports iOS 27+ only, while the Demo fails to build on the iOS 27 fallback with `Missing package product 'STULabelSwift'`. The test device session was closed. Once G01 resolves that product failure, manually long-press and move both selection handles through a mixed-bidi label.

## R03 — Preserve target traits in tiled rendering

**Classification:** Must fix  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabelLayer.mm:1523](Source/STULabel/STULabelLayer.mm#L1523) installs a tile drawing closure that captures the frame and drawing options but not `renderingTraitCollection`. Tiles execute later through [STULabelTiledLayer.mm:1019](Source/STULabel/Internal/STULabelTiledLayer.mm#L1019), outside the trait scope used by ordinary rendering.

A standalone layer with dark target traits, bounds 200 × 6000, contents scale 1, and "Line of text\n" repeated 200 times selected `STULabelTiledLayer`. Its four drawing callbacks observed light traits. Long labels can therefore draw semantic colors/custom content under the wrong environment; format selection and drawing may also use different traits.

### Preferred implementation

Capture an immutable target trait snapshot with each tile generation. Activate it once around each complete tile render, including custom drawing. Invalidate/cancel obsolete tile generations when the target changes. Use the same environment model as R04, and keep trait activation outside glyph/line loops.

### Acceptance criteria

- [ ] Default and custom tile drawing observe the requested target traits.
- [ ] Synchronous visible tiles and asynchronously prepared tiles are covered.
- [ ] Changing traits cannot publish stale tiles from an older generation.
- [ ] Bitmap-format selection and pixel rendering use the same environment.
- [ ] Ordinary non-tiled rendering remains correct.
- [ ] Validation includes the actual tiled path, not just the parent layer's initial display callback.

### Progress and completion record

No implementation recorded. Next: trace tile generation, cancellation, and closure ownership before choosing the capture boundary.

## R04 — Synchronize the complete rendering environment

**Classification:** Must fix  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabel.mm:1077](Source/STULabel/STULabel.mm#L1077) updates layout direction without refreshing the layer's trait snapshot. The nearby content-size callback adjusts fonts but likewise leaves the snapshot stale. Complete synchronization occurs only in selected display/color callbacks.

After a label's preferred-content-size override changed to accessibility XXXL and traits were updated, the view reported XXXL while `layer.renderingTraitCollection` still reported Large. Custom drawing and dynamic providers can observe stale traits. [STULabelLayer.h:23](Source/STULabel/STULabelLayer.h#L23) promises that the view keeps this collection synchronized.

### Preferred implementation

Make the view own a coherent rendering-environment snapshot, updated at rendering invalidation/preparation boundaries with appropriate trait dependencies. Pass the complete snapshot unchanged through sync, async, prerendered, and tiled paths. Include content-size and direction changes; consider size-class/custom-trait dependencies supported by drawing callbacks.

Do not use ambient background-thread traits or repeatedly add unrelated callback-specific assignments without an ownership model.

### Acceptance criteria

- [ ] The layer snapshot agrees with relevant current view traits before rendering.
- [ ] Content-size, layout-direction, display properties, and appearance changes are covered.
- [ ] Custom drawing receives the correct environment.
- [ ] Async results are accepted only for the environment that produced them.
- [ ] Trait-only pixel changes preserve shaping/layout where those stages do not depend on the changed traits.
- [ ] R03, R05, and R06 use this model without competing state owners.

### Progress and completion record

No implementation recorded. Next: document environment ownership and invalidation boundaries before editing the callbacks.

## R05 — Trait-correct preferred default fonts

**Classification:** Must fix  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabelLayer.mm:402](Source/STULabel/STULabelLayer.mm#L402), `defaultFont`, globally caches `preferredFontForTextStyle:UIFontTextStyleBody` once. [Missing attributed-string fonts](Source/STULabel/STULabelLayer.mm#L558) use that result regardless of the label's traits. [Enabling Dynamic Type adjustment](Source/STULabel/STULabel.mm#L1033) records the current category without immediately applying it.

After warming the default at Large, a label overridden to accessibility XXXL with adjustment enabled received a 17-point default font for text lacking an explicit font. UIKit's preferred body font compatible with the label's traits was 53 points.

### Preferred implementation

Resolve the preferred default against the explicit target traits. Cache per relevant font environment or per layer and invalidate appropriately. Apply the current category when enabling adjustment. Plain text and missing attributed-string fonts should share the same default resolution, coordinated with R10.

### Acceptance criteria

- [ ] A label created after the global default was first used still gets its own correct preferred font.
- [ ] Different local trait environments do not contaminate one another.
- [ ] Enabling adjustment applies the current category immediately.
- [ ] Plain and partially attributed text use consistent defaults.
- [ ] Explicit consumer-provided font semantics remain intentional and documented.
- [ ] Font resolution/caching avoids repeated expensive work in shaping or drawing loops.

### Progress and completion record

No implementation recorded. Next: trace default-font use in label, standalone layer, and prerenderer paths.

## R06 — Single background-color owner across prerenderer configuration

**Classification:** Must fix  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabel.mm:2361](Source/STULabel/STULabel.mm#L2361), `configureWithPrerenderer:`, imports the prerenderer into the layer but does not synchronize the view's `_backgroundColor`. [Appearance updates](Source/STULabel/STULabel.mm#L1104) later regenerate the displayed background from that stale view value.

A red prerenderer background produced a red layer while `label.backgroundColor` was nil. Executing the appearance-update path cleared the red background. A previously configured view color can similarly overwrite the imported background.

### Preferred implementation

Adopt the incoming background into the view's authoritative state during prerenderer configuration. Preserve UIColor identity for normally assigned dynamic view colors and derive displayed CGColor from that state. Define the imported prerenderer color semantics explicitly instead of special-casing the next appearance callback.

### Acceptance criteria

- [ ] Configuring a fresh label imports a coherent view/layer background.
- [ ] Configuring a label with an existing background replaces it consistently.
- [ ] Subsequent appearance changes do not erase or restore stale colors.
- [ ] Normal dynamic UIColor backgrounds still resolve against target traits.
- [ ] Nil/transparent backgrounds and relevant opacity/render-format state remain coherent.

### Progress and completion record

No implementation recorded. Next: trace the configuration contract and consolidate background ownership.

## R07 — Preserve disabled link colors during tint/lifecycle changes

**Classification:** Must fix  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STULabel.mm:1178](Source/STULabel/STULabel.mm#L1178), `tintColorMayHaveChanged`, assigns tint or `UIColor.linkColor` even when an explicit disabled-link override should remain active. The helper runs from tint, superview, and window callbacks.

A label with red `disabledLinkColor` and `isEnabled == false` initially had a red override; `tintColorDidChange` replaced it with the system link color.

### Preferred implementation

Consolidate effective link-color calculation. Apply an explicit disabled override first, then the intended tint/dimming/default-link rules. Reuse the calculation from property/state setters and lifecycle callbacks.

### Acceptance criteria

- [ ] Disabled-link overrides survive tint and hierarchy/window changes.
- [ ] Enabled/disabled transitions select the appropriate color.
- [ ] Explicit override removal restores the intended fallback.
- [ ] Tint usage and dimmed-tint behavior remain intentional.
- [ ] Native Testing coverage checks observable effective colors, including the original regression.

### Progress and completion record

No implementation recorded. Next: enumerate current link-color writers and replace divergent decision rules.

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

2026-09-09 — Codex — Complete; uncommitted.

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
- `git diff --check` passed. No snapshot rerecording, commit, or push.

Remaining scope: snapshot reference differences remain outside R11; G01's other release gates remain open. This establishes the focused iOS 26.2 behavior, not an Xcode 26 toolchain result or a timing benchmark.

## R12 — Remove unreachable accessibility non-rotor branch

**Classification:** Optional cleanup  
**Status:** Open  
**Owner:** Unassigned

### Problem and evidence

[STUTextFrameAccessibilityElement.mm:672](Source/STULabel/STUTextFrameAccessibilityElement.mm#L672) sets `createRotorLinks` permanently to true but keeps conditional element-class selection and rotor assignment.

### Preferred implementation

Construct the rotor-link element directly and assign its rotor unconditionally. Remove only the unreachable alternatives. Do not delete an element class still used elsewhere.

This is a clarity improvement; the compiler likely already removes the dead branch. Do not extend the deletion to unrelated VoiceOver/CoreText workarounds merely because they mention older releases.

### Acceptance criteria

- [ ] The constant and unreachable alternatives are removed.
- [ ] Remaining element classes still serve their actual callers.
- [ ] Link accessibility/rotor construction preserves observable behavior.
- [ ] No unnecessary test harness or unrelated accessibility rewrite is added.

### Progress and completion record

No implementation recorded. Next: verify the constant's scope and remaining class references, then simplify directly.

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

- Overall state: **Open — initial review handoff**
- Completed task IDs: R11 (2026-09-09; uncommitted).
- Deferred/superseded task IDs and rationale: None recorded.
- Required validation still outstanding: G01 and task-specific criteria.
- Final reviewed commit/worktree: Not yet recorded.
- Final assessment after fixes: Not yet recorded.
