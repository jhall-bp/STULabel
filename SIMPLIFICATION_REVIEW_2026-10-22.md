# STULabel simplification and modernization review — 22 October 2026

## Scope and method

Reviewed all **231 files** under `Source/STULabel/`: 106 direct Internal files, 35 Internal/stu files, 88 top-level files and two nested support/resource files. The generated Unicode table received structural and bounds checks rather than a claim of semantic Unicode conformance. All other files were read in full. Public headers, module maps, debugger support, resources and the non-ARC bridge were included even where they belong to a companion target or are excluded from compilation.

Applied the requested code-simplification and modern-cpp skills. Traced callers and ownership before editing, reviewed the existing C++23/package policy and relevant history, and used Xcode MCP for project reads, edits, builds and execution. Existing work in text input, accessibility, attachment conversion, the layouter header, tests and README was preserved. The two earlier review documents were left intact. No commits or publishing were performed.

## Implemented changes

1. **Rendering decisions:** `labelTextFrameRenderInfo` finalizes render mode before choosing grayscale. Grayscale therefore excludes CA-context drawing. Removed the unreachable branch, made the decision const and used the already-established opaque-background invariant. Both layer rendering and asynchronous render tasks consume the same plan.
2. **Glyph spans:** removed the unused advances wrapper, type alias, private Core Text accessor and allocation fallback. A workspace-wide search found declarations/definitions only, including tests. Live glyph/position/string-index paths are unchanged. Retained the negative-advance rationale beside the actual typographic-width method.
3. **Underline metrics:** drawing and image-bounds calculation now share one always-inline helper for original-font metrics, override handling and fallback-font exclusions. Each caller retains its previous-style/font cache, adjacency propagation and pixel rounding. Font lookups and floating-point operation order are unchanged.
4. **Scaling:** use the existing `needsRealignment` result to skip traversing paragraphs when there are no centered/right-aligned lines. The producer and consumer classify alignments identically; empty paragraphs have no lines to move. Removed unread hyphenation bookkeeping. Scale-search arithmetic is unchanged.
5. **Blank attachments:** compare drawing IMPs using `class_getMethodImplementation`, instead of comparing an IMP with a `Method` metadata pointer. This activates the already-designed no-op fast path before context flips, per-glyph calls and color-cache invalidation. Normal construction and decoding share this setup; subclass drawing remains supported.
6. **Link overlay:** after content-origin movement, unwrap the active link before matching it and pass the remapped link into the overlay. Previously an overlay object could be treated as a link, or the correctly remapped link could be discarded. Removed the redundant style assignment. Preserved delegate-selected styles and nil-style removal behavior.

Seven production files changed. Added one Swift Testing regression file covering overlay style changes with and without an existing overlay. The test uses a small UITouch subclass through public responder methods; it verifies responder behavior, not OS touch-event delivery.

## Performance and design decisions

The project already uses C++23. Language-version churn would not improve its runtime behavior. Retained small-buffer vectors, arenas, tagged pointers, intrusive ownership, packed style/frame records, custom optional references, borrowed callbacks and lazy caches. These choices have observable storage, ARC, allocation or semantic differences from blanket std::vector/std::optional/std::function/smart-pointer substitutions.

No change introduces a new per-label allocation, retain operation, lookup or traversal. The underline helper is always-inline and preserves both caller caches. Removing an unused function may reduce emitted code, but no binary-size saving is claimed. The rendering simplification is something the compiler could already eliminate; no speedup is claimed for it. The scaling and blank-attachment changes remove identifiable unnecessary work; benchmark results below determine what can be said about measured layout performance.

Relevant prior art supports selective modernization rather than replacing specialized storage:

- [LLVM SmallVector](https://llvm.org/docs/ProgrammersManual.html#llvm-adt-smallvector-h): inline storage and reduced allocation are established high-performance techniques.
- [LLVM TrailingObjects](https://llvm.org/docs/doxygen/TrailingObjects_8h_source.html): typed trailing storage is a useful comparator for coallocated immutable records.
- [LLVM PointerIntPair](https://github.com/llvm/llvm-project/blob/main/llvm/include/llvm/ADT/PointerIntPair.h): tagged compact references are an intentional representation technique.
- [Clang ARC specification](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#template-arguments): Objective-C pointer template arguments and ownership qualification must be considered together.
- [C++ Core Guidelines on signed subscripts](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es107-dont-use-unsigned-for-subscripts-prefer-gslindex): the signed-index design is defensible; changing everything to size_t would complicate end-relative arithmetic.

## Validation

- **Builds:** Debug build-for-testing and Release benchmark builds succeeded through Xcode MCP. Existing warnings were not represented as a warning-free build.
- **Final Swift suite:** fresh console session PID 18774 reports **188 tests in 30 suites passed**, exit code 0, after 17.777 seconds. The existing opt-in benchmark suite remained disabled during normal runs.
- **Final Objective-C suite:** Xcode returned a complete result for **86/86 passed**, zero failures/skips, PID 18916. The separate non-ARC ownership target returned **1/1 passed**, PID 18887.
- **Focused regression:** both overlay variants and the base/image attachment initializer/encoding tests passed (four cases, three Swift test functions). A negative control with the original overlay setter failed because the public activeLink became nil after the style change. Fixed source and both arguments were restored and passed again.
- **Independent review:** a second reviewer checked the scoped production diff, callers, ARC ownership, cache equivalence and regression test using the code-review-and-quality skill; no actionable issues found.
- **Workspace hygiene:** final diff whitespace check passed. Temporary benchmark code was removed, the existing benchmark source restored exactly, the scaling guard restored and STULabel-Package reselected. All preexisting unrelated modifications were retained.

Xcode MCP intermittently failed to open completed result bundles. The final Swift-suite and benchmark claims above are grounded in fresh, complete console summaries with successful exit codes, rather than a claim that their result bundles were available. The final 86-test Objective-C and one-test non-ARC runs returned complete structured passing results.

### Release scaling comparison

A/B/B/A on the arm64 iPhone 18 Pro simulator, iOS 27.0 build 24A434, SDK iOS 27.1. A used the old unconditional realignment call; B used the new guard; other source was identical. Each workload used 100 warmups and nine rotated samples of 100 layouts. An initial oversized calibration timed out, produced no usable records and was excluded.

Per-run medians in microseconds per layout:

| Workload | A1 | B1 | B2 | A2 | Pooled B vs A |
|---|---:|---:|---:|---:|---:|
| Scaled left | 12690.921 | 12693.537 | 12307.509 | 12302.708 | +0.40% |
| Scaled center | 12616.020 | 12631.239 | 12357.500 | 12372.892 | +0.43% |
| Scaled right | 12667.225 | 12750.533 | 12344.581 | 12358.700 | +0.62% |
| Unscaled Latin | 40.016 | 39.168 | 36.007 | 37.505 | -3.18% |
| Unscaled Arabic | 78.495 | 79.246 | 76.931 | 76.380 | +0.51% |
| Unscaled Emoji | 17.833 | 17.840 | 17.218 | 17.023 | -0.69% |
| Unscaled Indic | 25.155 | 24.898 | 24.365 | 24.166 | -0.79% |

**No regression distinguishable from run-to-run noise; no demonstrated speedup.** The scaled differences are small beside approximately 3% shared run-level drift. This is a bounded simulator observation, not a device-performance guarantee or a timing measurement of every changed path.

All seven bit-exact frame signatures and line/scale checksums matched across all four runs. Scaled cases used 180×1082, scale 0.79510498046875 and 13 layout iterations. No breakpoint was used, so exact execution of the guarded upward-adjustment branch is not independently established. The four benchmark runs passed and exited 0 in 38.627, 38.578, 37.552 and 37.420 seconds.

Raw samples, checksums, signatures and environment metadata: [CXX_MODERNIZATION_BENCHMARK_RESULTS.json](/Users/jessehalley/Developer/STULabel/CXX_MODERNIZATION_BENCHMARK_RESULTS.json).

## Retained findings and boundaries

- `Internal/stu/ArrayRef.hpp`: unused ranged `lastIndexWhere` overloads recursively call themselves rather than the existing implementation helper. No production/test caller was found. This header is also exported by the separate stu module; absence of repository callers does not establish absence of external consumers. Its API was retained, and the defect is recorded for focused correction and utility-level coverage.
- `stu_label_lldb_formatters.py`: source review found a mismatched child-index member name, Python 2 string decoding/integer-division remnants, a missing comma between registered type names and unterminated quoted type names in registration commands. These support-tool issues were not reproduced in an attached LLDB session and were left separate from the runtime changes.
- Custom Optional/reference/container implementations contain subtle constraint and ownership behavior. Replacing them requires focused compile-time/ownership coverage and measurement, not just modern spelling.
- Generated Unicode data was checked for dimensions, byte-valued entries and lookup bounds. Translation accuracy, end-to-end VoiceOver speech, real touch delivery and device performance are not established by this review.
- Core Text compatibility workarounds and the guarded fast font accessor were retained. Removing them needs evidence across supported OS/font behavior, not an assumption that age makes them obsolete.

## File-by-file disposition

“Retained” means reviewed and intentionally unchanged by this task; it does not mean the file was initially clean. Header/implementation pairs may share a rationale where their contract is inseparable.

### Internal layout and rendering

| File | Disposition | Reason |
|---|---|---|
| [Internal/AtomicEnum.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/AtomicEnum.hpp) | Retained | Preserve underlying atomic enum representation and bitwise operations; no wrapper allocation or virtual dispatch. |
| [Internal/CancellationFlag.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CancellationFlag.hpp) | Retained | Preserve C-compatible cancellation flag and relaxed sentinel checks shared by synchronous and asynchronous work. |
| [Internal/CancellationFlag.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CancellationFlag.mm) | Retained | Preserve C-compatible cancellation flag and relaxed sentinel checks shared by synchronous and asynchronous work. |
| [Internal/Color.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Color.hpp) | Retained | Preserve tagged borrowed/owned references and dynamic-color resolution; generic ownership replacement would add retain work. |
| [Internal/Color.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Color.mm) | Retained | Preserve tagged borrowed/owned references and dynamic-color resolution; generic ownership replacement would add retain work. |
| [Internal/Common.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Common.hpp) | Retained | Preserve shared aliases, compiler annotations and ARC/debug boundaries. |
| [Internal/CoreAnimationUtils.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CoreAnimationUtils.hpp) | Retained | Preserve layer/window handling and pointer-identity format fast paths. |
| [Internal/CoreAnimationUtils.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CoreAnimationUtils.mm) | Retained | Preserve layer/window handling and pointer-identity format fast paths. |
| [Internal/CoreGraphicsUtils.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CoreGraphicsUtils.hpp) | Retained | Preserve constrained geometry helpers, winding direction and floating-point evaluation order. |
| [Internal/CoreGraphicsUtils.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/CoreGraphicsUtils.mm) | Retained | Preserve constrained geometry helpers, winding direction and floating-point evaluation order. |
| [Internal/DecorationLines.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DecorationLines.hpp) | Retained | Preserve decoration caches, gap/path work, adjacency propagation and pixel rounding. |
| [Internal/DecorationLines.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DecorationLines.mm) | Changed | Centralize original/fallback underline metrics in one always-inline helper used by drawing and bounds; preserve caller cache hits and arithmetic. |
| [Internal/DefineUIntOnCatalystToWorkAroundGlobalNamespacePollution.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DefineUIntOnCatalystToWorkAroundGlobalNamespacePollution.h) | Retained | Preserve paired Catalyst namespace workaround around affected framework imports. |
| [Internal/DisplayScaleRounding.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DisplayScaleRounding.hpp) | Retained | Preserve cached scale/inverse values, optional-zero representation and exact tolerance rules. |
| [Internal/DisplayScaleRounding.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DisplayScaleRounding.mm) | Retained | Preserve cached scale/inverse values, optional-zero representation and exact tolerance rules. |
| [Internal/DrawingContext.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DrawingContext.hpp) | Retained | Preserve scoped context restoration and cached line, shadow and color state. |
| [Internal/DrawingContext.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DrawingContext.mm) | Retained | Preserve scoped context restoration and cached line, shadow and color state. |
| [Internal/DynamicTypeFontScaling.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/DynamicTypeFontScaling.h) | Retained | Preserve internal category interfaces used by font adjustment and provenance tracking. |
| [Internal/Equal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Equal.hpp) | Retained | Preserve component-level equality, including deliberate NaN and negative-size behavior. |
| [Internal/Font.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Font.hpp) | Retained | Preserve pooled caches, batched glyph bounds, duplicate handling and emoji/scalable-font distinctions. |
| [Internal/Font.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Font.mm) | Retained | Preserve pooled caches, batched glyph bounds, duplicate handling and emoji/scalable-font distinctions. |
| [Internal/GlyphPathIntersectionBounds.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/GlyphPathIntersectionBounds.hpp) | Retained | Preserve specialized path-intersection geometry used to cut decoration gaps without general geometry allocations. |
| [Internal/GlyphPathIntersectionBounds.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/GlyphPathIntersectionBounds.mm) | Retained | Preserve specialized path-intersection geometry used to cut decoration gaps without general geometry allocations. |
| [Internal/GlyphSpan.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/GlyphSpan.hpp) | Changed | Remove unused glyph-advance API/fallback after workspace-wide caller search; preserve borrowed runs, lazy count and Core Text width semantics. |
| [Internal/GlyphSpan.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/GlyphSpan.mm) | Changed | Remove unused glyph-advance API/fallback after workspace-wide caller search; preserve borrowed runs, lazy count and Core Text width semantics. |
| [Internal/Hash.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Hash.hpp) | Retained | Preserve CityHash structure, bit casts, signed-zero normalization and independent arithmetic operations. |
| [Internal/HashTable.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/HashTable.hpp) | Retained | Preserve compact sentinel layout, quadratic probing and arena relocation; standard containers would alter allocation/cost. |
| [Internal/HashTable.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/HashTable.mm) | Retained | Preserve compact sentinel layout, quadratic probing and arena relocation; standard containers would alter allocation/cost. |
| [Internal/InputClamping.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/InputClamping.hpp) | Retained | Preserve enum validation, NaN/infinity normalization and checked arithmetic at API boundaries. |
| [Internal/IntervalSearchTable.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/IntervalSearchTable.hpp) | Retained | Preserve monotonic contiguous arrays and shared binary boundary search. |
| [Internal/IntervalSearchTable.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/IntervalSearchTable.mm) | Retained | Preserve monotonic contiguous arrays and shared binary boundary search. |
| [Internal/Kerning.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Kerning.hpp) | Retained | Preserve compile-time optional truncation-token kerning; disabled-by-default is not evidence of dead API. |
| [Internal/Kerning.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Kerning.mm) | Retained | Preserve compile-time optional truncation-token kerning; disabled-by-default is not evidence of dead API. |
| [Internal/LabelParameters.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelParameters.hpp) | Retained | Preserve compact flags, copy-on-write options and shared layer/prerenderer setters; inset rounding paths have different contracts. |
| [Internal/LabelParameters.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelParameters.mm) | Retained | Preserve compact flags, copy-on-write options and shared layer/prerenderer setters; inset rounding paths have different contracts. |
| [Internal/LabelPrerenderer.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelPrerenderer.hpp) | Retained | Preserve frozen layout state, intrusive waiters and coallocated Objective-C/C++ lifetime split. |
| [Internal/LabelPrerenderer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelPrerenderer.mm) | Retained | Preserve frozen layout state, intrusive waiters and coallocated Objective-C/C++ lifetime split. |
| [Internal/LabelRenderTask.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelRenderTask.hpp) | Retained | Preserve dual-owner atomic state, acquire/release publication and independent layout/render cancellation. |
| [Internal/LabelRenderTask.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelRenderTask.mm) | Retained | Preserve dual-owner atomic state, acquire/release publication and independent layout/render cancellation. |
| [Internal/LabelRendering.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelRendering.hpp) | Retained | Preserve render-plan representation and shared synchronous/asynchronous drawing ownership. |
| [Internal/LabelRendering.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LabelRendering.mm) | Changed | Make grayscale decision immutable, remove unreachable CA-context branch and reuse established background-opacity invariant. |
| [Internal/LayerVisibleBoundsObserver.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LayerVisibleBoundsObserver.hpp) | Retained | Preserve tagged superlayer references, KVO bookkeeping and scroll-root termination used by predictive tiling. |
| [Internal/LayerVisibleBoundsObserver.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LayerVisibleBoundsObserver.mm) | Retained | Preserve tagged superlayer references, KVO bookkeeping and scroll-root termination used by predictive tiling. |
| [Internal/LineTruncation.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LineTruncation.hpp) | Retained | Preserve direction-specialized traversal, contiguous source/glyph ranges, nonmonotonic runs and balanced two-ended truncation. |
| [Internal/LineTruncation.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/LineTruncation.mm) | Retained | Preserve direction-specialized traversal, contiguous source/glyph ranges, nonmonotonic runs and balanced two-ended truncation. |
| [Internal/NSArrayRef.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/NSArrayRef.hpp) | Retained | Preserve direct-buffer fast enumeration and cached-IMP fallback with borrowed objects. |
| [Internal/NSAttributedStringRef.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/NSAttributedStringRef.hpp) | Retained | Preserve cached attribute/string IMPs and effective-range bridging to avoid repeated Objective-C dispatch. |
| [Internal/NSCoderUtils.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/NSCoderUtils.hpp) | Retained | Preserve explicit integer/enum widths and secure decoding class constraints. |
| [Internal/NSStringRef.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/NSStringRef.hpp) | Retained | Preserve tagged direct-buffer-or-IMP representation, bounded refill buffers and grapheme state machines. |
| [Internal/NSStringRef.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/NSStringRef.mm) | Retained | Preserve tagged direct-buffer-or-IMP representation, bounded refill buffers and grapheme state machines. |
| [Internal/Once.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Once.hpp) | Retained | Preserve dispatch_once fast path and preserve-most initialization arrangement. |
| [Internal/PurgeableImage.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/PurgeableImage.hpp) | Retained | Preserve purgeable access-token transfer to provider callback, checked sizing and scoped Core Graphics cleanup. |
| [Internal/PurgeableImage.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/PurgeableImage.mm) | Retained | Preserve purgeable access-token transfer to provider callback, checked sizing and scoped Core Graphics cleanup. |
| [Internal/Rect.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Rect.hpp) | Retained | Preserve constrained geometry, half-open ranges and conversion semantics; already substantially modernized. |
| [Internal/STULabelGhostingMaskLayer.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelGhostingMaskLayer.h) | Retained | Preserve vanished-link ownership, link remapping and winding-based mask construction. |
| [Internal/STULabelGhostingMaskLayer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelGhostingMaskLayer.mm) | Retained | Preserve vanished-link ownership, link remapping and winding-based mask construction. |
| [Internal/STULabelLinkOverlayLayer.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelLinkOverlayLayer.h) | Retained | Preserve weak animation delegate and clear-before-callback identity handling. |
| [Internal/STULabelLinkOverlayLayer.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelLinkOverlayLayer.m) | Retained | Preserve weak animation delegate and clear-before-callback identity handling. |
| [Internal/STULabelSubrangeView.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelSubrangeView.h) | Retained | Preserve preview drawing environment, source scale and shared tiled rendering behavior. |
| [Internal/STULabelSubrangeView.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelSubrangeView.mm) | Retained | Preserve preview drawing environment, source scale and shared tiled rendering behavior. |
| [Internal/STULabelTiledLayer.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelTiledLayer.h) | Retained | Preserve synchronous visible tiles, two-slot async prerendering, reuse and atomic early-release accounting. |
| [Internal/STULabelTiledLayer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STULabelTiledLayer.mm) | Retained | Preserve synchronous visible tiles, two-slot async prerendering, reuse and atomic early-release accounting. |
| [Internal/STUMediaTimingFunctionUtils.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STUMediaTimingFunctionUtils.h) | Retained | Preserve C/Objective-C utility declarations used by overlay animation. |
| [Internal/STUPlaceholderObjects.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STUPlaceholderObjects.h) | Retained | Preserve class-cluster placeholders and retained-result annotations. |
| [Internal/STUPlaceholderObjects.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/STUPlaceholderObjects.m) | Retained | Preserve class-cluster placeholders and retained-result annotations. |
| [Internal/ShapedString.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/ShapedString.hpp) | Retained | Preserve trailing-array storage, paragraph/bidi scanning, attachment-fix ordering and bounded/unbounded typesetter distinction. |
| [Internal/ShapedString.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/ShapedString.mm) | Retained | Preserve trailing-array storage, paragraph/bidi scanning, attachment-fix ordering and bounded/unbounded typesetter distinction. |
| [Internal/SortedIntervalBuffer.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/SortedIntervalBuffer.hpp) | Retained | Preserve compact arena storage, insertion hints and merged adjacent decoration-gap ranges. |
| [Internal/SortedIntervalBuffer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/SortedIntervalBuffer.mm) | Retained | Preserve compact arena storage, insertion hints and merged adjacent decoration-gap ranges. |
| [Internal/StyledStringRangeIteration.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/StyledStringRangeIteration.hpp) | Retained | Preserve before/override/after traversal, style-pointer hints and callback short-circuiting. |
| [Internal/StyledStringRangeIteration.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/StyledStringRangeIteration.mm) | Retained | Preserve before/override/after traversal, style-pointer hints and callback short-circuiting. |
| [Internal/TextFlags.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFlags.hpp) | Retained | Preserve compact flag mapping shared with packed text styles and public flags. |
| [Internal/TextFrame-Background.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame-Background.mm) | Retained | Preserve packed background segments, relocation-safe offsets, tagged grouping and lazy atomic publication. |
| [Internal/TextFrame-Drawing.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame-Drawing.mm) | Retained | Preserve coordinate conversion and baseline rounding order across rendering contexts. |
| [Internal/TextFrame-IndexConversion.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame-IndexConversion.mm) | Retained | Preserve distinct original/truncated saturation, endpoint and inserted-hyphen behavior. |
| [Internal/TextFrame-PointToIndex.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame-PointToIndex.mm) | Retained | Preserve ligature direction, search tie-breaking and bounded grapheme scanning. |
| [Internal/TextFrame-TruncatedAttributedString.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame-TruncatedAttributedString.mm) | Retained | Preserve original/token attributed-string assembly and attribute ownership. |
| [Internal/TextFrame.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame.hpp) | Retained | Preserve public-record correspondence, trailing allocation, staged ownership transfer and atomic lazy caches. |
| [Internal/TextFrame.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrame.mm) | Retained | Preserve public-record correspondence, trailing allocation, staged ownership transfer and atomic lazy caches. |
| [Internal/TextFrameCompactIndex.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameCompactIndex.hpp) | Retained | Preserve compact index encoding and explicit boundary semantics. |
| [Internal/TextFrameDrawingOptions.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameDrawingOptions.hpp) | Retained | Preserve frozen drawing-state representation and ownership contracts. |
| [Internal/TextFrameLayouter-LineBreaking.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLayouter-LineBreaking.mm) | Retained | Preserve regional-indicator cache, whitespace exceptions, hyphenation validation and actual-glyph kerning correction. |
| [Internal/TextFrameLayouter-LineTruncation.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLayouter-LineTruncation.mm) | Retained | Preserve bounded token-attribute refinement and explicit Core Text ownership; estimator/token paths have different cost contracts. |
| [Internal/TextFrameLayouter-Scaling.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLayouter-Scaling.mm) | Changed | Use existing needsRealignment result to skip unnecessary paragraph traversal; remove unread hyphenation bookkeeping. Preserve scale-search arithmetic. |
| [Internal/TextFrameLayouter.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLayouter.hpp) | Retained | Preserve staged/saved layout ownership, streaming/backtracking state and font-substitution pass; existing dirty header left intact. |
| [Internal/TextFrameLayouter.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLayouter.mm) | Retained | Preserve staged/saved layout ownership, streaming/backtracking state and font-substitution pass; existing dirty header left intact. |
| [Internal/TextFrameLine-Drawing.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLine-Drawing.mm) | Retained | Preserve glyph-span drawing, clipping and coordinate semantics; shared underline metrics remain cached. |
| [Internal/TextFrameLine-FontMetric.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLine-FontMetric.mm) | Retained | Preserve metric aggregation and baseline-offset arithmetic. |
| [Internal/TextFrameLine-GlyphSpanIteration.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLine-GlyphSpanIteration.mm) | Retained | Preserve whole-line/run fast paths, source/token/hyphen distinctions, style hints and bounded ligature splitting. |
| [Internal/TextFrameLine-ImageBounds.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextFrameLine-ImageBounds.mm) | Retained | Preserve glyph-bound caches, decoration aggregation, attachment geometry and atomic publication; retain documented rounding differences. |
| [Internal/TextInputCarets.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextInputCarets.hpp) | Retained | Preserve logical range coalescing, visual ordering, visible-glyph filtering and lazy per-line cache population. |
| [Internal/TextLineSpan.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextLineSpan.hpp) | Retained | Preserve compact tagged spans, adjacent-span coalescing, index hints and originally-empty span distinctions. |
| [Internal/TextLineSpan.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextLineSpan.mm) | Retained | Preserve compact tagged spans, adjacent-span coalescing, index hints and originally-empty span distinctions. |
| [Internal/TextLineSpansPath.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextLineSpansPath.hpp) | Retained | Preserve packed vertices, linear traversal, lazy copying, in-place mutation and direct-rectangle fast path. |
| [Internal/TextLineSpansPath.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextLineSpansPath.mm) | Retained | Preserve packed vertices, linear traversal, lazy copying, in-place mutation and direct-rectangle fast path. |
| [Internal/TextStyle.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextStyle.hpp) | Retained | Preserve packed sizes, optional-index sentinels, padding and constexpr tables; override ranges use distinct coordinate domains. |
| [Internal/TextStyle.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextStyle.mm) | Retained | Preserve packed sizes, optional-index sentinels, padding and constexpr tables; override ranges use distinct coordinate domains. |
| [Internal/TextStyleBuffer.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextStyleBuffer.hpp) | Retained | Preserve compact interning, key-length/pointer fast paths, lazy color caching and attachment ownership boundaries. |
| [Internal/TextStyleBuffer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/TextStyleBuffer.mm) | Retained | Preserve compact interning, key-length/pointer fast paths, lazy color caching and attachment ownership boundaries. |
| [Internal/ThreadLocalAllocator.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/ThreadLocalAllocator.hpp) | Retained | Preserve thread-local arena lifecycle and null-allocator TempArray sentinel. |
| [Internal/ThreadLocalAllocator.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/ThreadLocalAllocator.mm) | Retained | Preserve thread-local arena lifecycle and null-allocator TempArray sentinel. |
| [Internal/UndefineUIntOnCatalystToWorkAroundGlobalNamespacePollution.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/UndefineUIntOnCatalystToWorkAroundGlobalNamespacePollution.h) | Retained | Preserve paired cleanup of the Catalyst namespace workaround. |
| [Internal/UnicodeCodePointProperties.generated.inc](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/UnicodeCodePointProperties.generated.inc) | Retained | Structurally checked all eight arrays and lookup bounds for U+0000–U+1FFFF; preserve generated data. This is not a semantic Unicode conformance audit. |
| [Internal/UnicodeCodePointProperties.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/UnicodeCodePointProperties.hpp) | Retained | Preserve packed Unicode properties and short table-lookup paths. |
| [Internal/UnicodeCodePointProperties.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/UnicodeCodePointProperties.mm) | Retained | Preserve packed Unicode properties and short table-lookup paths. |
| [Internal/Unretained.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/Unretained.hpp) | Retained | Preserve ARC return-value convention wrapper that avoids unnecessary retain/autorelease. |

### Internal C++ utilities

| File | Disposition | Reason |
|---|---|---|
| [Internal/stu/Allocation.cpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Allocation.cpp) | Retained | Preserve checked sizing, sized deallocation/reallocation and ASan hooks; cold failure path remains isolated. |
| [Internal/stu/Allocation.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Allocation.hpp) | Retained | Preserve checked sizing, sized deallocation/reallocation and ASan hooks; cold failure path remains isolated. |
| [Internal/stu/ArenaAllocator.cpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/ArenaAllocator.cpp) | Retained | Preserve initial stack storage, reverse slab release and last-allocation reclamation; retain explicit instantiation. |
| [Internal/stu/ArenaAllocator.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/ArenaAllocator.hpp) | Retained | Preserve initial stack storage, reverse slab release and last-allocation reclamation; retain explicit instantiation. |
| [Internal/stu/Array.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Array.hpp) | Retained | Preserve initialized/uninitialized ownership, empty-base optimization and delayed Repeated constraints. |
| [Internal/stu/ArrayRef.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/ArrayRef.hpp) | Retained | Preserve signed/end-relative indexing and const-reference behavior. Unused reverse-search overload defect recorded separately. |
| [Internal/stu/ArrayUtils.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/ArrayUtils.hpp) | Retained | Preserve transactional construction, trivial bulk copies and zero-fill fast paths. |
| [Internal/stu/Assert.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Assert.h) | Retained | Preserve re-inclusion behavior, debug/release contracts, NSAssertionHandler integration and atomic test configuration. |
| [Internal/stu/Assert.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Assert.m) | Retained | Preserve re-inclusion behavior, debug/release contracts, NSAssertionHandler integration and atomic test configuration. |
| [Internal/stu/BinarySearch.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/BinarySearch.hpp) | Retained | Preserve one-predicate search and existing prefetch behavior. |
| [Internal/stu/Casts.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Casts.hpp) | Retained | Preserve bit_cast and intent-specific checked conversion domains. |
| [Internal/stu/Comparable.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Comparable.hpp) | Retained | Preserve delayed comparison instantiation; blanket spaceship conversion changes constraints/semantics. |
| [Internal/stu/Config.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Config.h) | Retained | Preserve C/compiler feature macros, shared aliases and Byte compatibility workaround. |
| [Internal/stu/Config.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Config.hpp) | Retained | Preserve C/compiler feature macros, shared aliases and Byte compatibility workaround. |
| [Internal/stu/Dollar.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Dollar.hpp) | Retained | Preserve end-relative indexing representation; spelling-only changes provide no benefit. |
| [Internal/stu/FunctionRef.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/FunctionRef.hpp) | Retained | Preserve two-word borrowed callback and noexcept contract; std::function would add ownership and possible allocation. |
| [Internal/stu/InOut.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/InOut.hpp) | Retained | Preserve semantic reference-parameter wrappers. |
| [Internal/stu/Iterator.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Iterator.hpp) | Retained | Preserve iterator trait behavior and constness; duplicate forward declaration is cosmetic and left alone. |
| [Internal/stu/MinMax.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/MinMax.hpp) | Retained | Preserve mixed-type narrowing rules, NaN handling and tie behavior. |
| [Internal/stu/NSFoundationSupport.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/NSFoundationSupport.hpp) | Retained | Preserve ARC/non-ARC and Core Foundation transfer conventions. |
| [Internal/stu/Optional.cpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Optional.cpp) | Retained | Preserve custom reference specialization, compact storage and cold failure path; no blanket std::optional substitution. |
| [Internal/stu/Optional.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Optional.hpp) | Retained | Preserve custom reference specialization, compact storage and cold failure path; no blanket std::optional substitution. |
| [Internal/stu/OptionsEnum.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/OptionsEnum.hpp) | Retained | Preserve typed bitwise operations and contextual-bool semantics. |
| [Internal/stu/Parameter.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Parameter.hpp) | Retained | Preserve named scalar types and self-dependent SFINAE needed to defer instantiation. |
| [Internal/stu/Range.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Range.hpp) | Retained | Preserve mixed signed/floating and CF/NS conversion contracts. |
| [Internal/stu/Ref.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Ref.hpp) | Retained | Preserve explicit borrowing representation. |
| [Internal/stu/RefCounting.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/RefCounting.hpp) | Retained | Preserve intrusive reference-count semantics and Objective-C/CF ownership integration. |
| [Internal/stu/ScopeGuard.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/ScopeGuard.hpp) | Retained | Preserve scoped cleanup and zero-storage disabled guard. |
| [Internal/stu/TypeTraits.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/TypeTraits.hpp) | Retained | Preserve integer/character domains, exact-bool checks and explicit relocatability traits. |
| [Internal/stu/UniquePtr.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/UniquePtr.hpp) | Retained | Preserve custom deleter and movable/zero traits used by font pools and tiles. |
| [Internal/stu/Utility.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Utility.hpp) | Retained | Preserve normalized standard bit operations and checked overflow behavior. |
| [Internal/stu/Vector.cpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Vector.cpp) | Retained | Preserve inline storage, externally supplied arena capacity, erased slow path and alias-safe mutation. |
| [Internal/stu/Vector.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/Vector.hpp) | Retained | Preserve inline storage, externally supplied arena capacity, erased slow path and alias-safe mutation. |
| [Internal/stu/module.modulemap](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/module.modulemap) | Retained | Preserve textual Assert inclusion and explicit Foundation interoperability boundary. |
| [Internal/stu/stu_lldb_formatters.py](/Users/jessehalley/Developer/STULabel/Source/STULabel/Internal/stu/stu_lldb_formatters.py) | Retained | Preserve layout-aware synthetic providers and capped child enumeration; no debugger session validation performed. |

### Public interfaces, implementations and support

| File | Disposition | Reason |
|---|---|---|
| [NSAttributedString+STUDynamicTypeFontScaling.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/NSAttributedString+STUDynamicTypeFontScaling.h) | Retained | Preserve copy-on-first-change adjustment, previous-font pointer cache and retained-copy interface. |
| [NSAttributedString+STUDynamicTypeFontScaling.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/NSAttributedString+STUDynamicTypeFontScaling.m) | Retained | Preserve copy-on-first-change adjustment, previous-font pointer cache and retained-copy interface. |
| [NSLayoutAnchor+STULabelSpacing.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/NSLayoutAnchor+STULabelSpacing.h) | Retained | Preserve Objective-C anchor entry points; convenience implementation belongs to the Swift overlay. |
| [NoARC/include/STULabelNoARC.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/NoARC/include/STULabelNoARC.h) | Retained | Preserve intentionally empty public header for the separate non-ARC target. |
| [Resources/Localizable.xcstrings](/Users/jessehalley/Developer/STULabel/Source/STULabel/Resources/Localizable.xcstrings) | Retained | Preserve localized Drag Item resource and active accessibility caller; translation quality not independently assessed. |
| [STUBackgroundAttribute-Internal.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUBackgroundAttribute-Internal.h) | Retained | Preserve shared field schema for immutable value, builder, coding and equality. |
| [STUBackgroundAttribute.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUBackgroundAttribute.h) | Retained | Preserve shared field schema for immutable value, builder, coding and equality. |
| [STUBackgroundAttribute.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUBackgroundAttribute.mm) | Retained | Preserve shared field schema for immutable value, builder, coding and equality. |
| [STUCancellationFlag.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUCancellationFlag.h) | Retained | Preserve C atomic layout, relaxed access and explicit cancellation lifetime contract. |
| [STUDefines.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUDefines.h) | Retained | Preserve C/Objective-C/C++ interoperability, visibility, ownership and optimizer annotations. |
| [STUImageUtils.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUImageUtils.h) | Retained | Preserve bitmap formats, CF ownership, dimension/scale clamping and debug-vs-release failure behavior. |
| [STUImageUtils.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUImageUtils.m) | Retained | Preserve bitmap formats, CF ownership, dimension/scale clamping and debug-vs-release failure behavior. |
| [STULabel+UITextInput-Internal.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel+UITextInput-Internal.h) | Retained | Preserve immutable text generations, sparse attachment maps, lazy shared caret caches, callback publication order and weak controller ownership. |
| [STULabel+UITextInput.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel+UITextInput.h) | Retained | Preserve immutable text generations, sparse attachment maps, lazy shared caret caches, callback publication order and weak controller ownership. |
| [STULabel+UITextInput.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel+UITextInput.mm) | Retained | Preserve immutable text generations, sparse attachment maps, lazy shared caret caches, callback publication order and weak controller ownership. |
| [STULabel.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel.h) | Retained | Preserve public view/delegate API and lazy interaction/lifetime contracts; existing user edits remain intact. |
| [STULabel.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel.mm) | Changed | Preserve lazy layout/interaction caches and shared layer forwarding; fix active-link remapping during overlay-style changes after content movement. |
| [STULabel.modulemap](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabel.modulemap) | Retained | Preserve separate framework module map; package and framework consumers require different maps. |
| [STULabelAlignment.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelAlignment.h) | Retained | Preserve compact public alignment enums and bit widths. |
| [STULabelDrawingBlock-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelDrawingBlock-Internal.hpp) | Retained | Preserve borrowed CGContext/cancellation lifetime and retained frame/options factory contract. |
| [STULabelDrawingBlock.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelDrawingBlock.h) | Retained | Preserve borrowed CGContext/cancellation lifetime and retained frame/options factory contract. |
| [STULabelDrawingBlock.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelDrawingBlock.mm) | Retained | Preserve borrowed CGContext/cancellation lifetime and retained frame/options factory contract. |
| [STULabelLayer-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayer-Internal.hpp) | Retained | Preserve packed state, cached delegate IMPs, lazy layout, separate cancellation/completion states and render modes. |
| [STULabelLayer.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayer.h) | Retained | Preserve packed state, cached delegate IMPs, lazy layout, separate cancellation/completion states and render modes. |
| [STULabelLayer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayer.mm) | Retained | Preserve packed state, cached delegate IMPs, lazy layout, separate cancellation/completion states and render modes. |
| [STULabelLayoutInfo-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayoutInfo-Internal.hpp) | Retained | Preserve compact snapshots, center/baseline/inset rounding and exact scaled-reuse thresholds. |
| [STULabelLayoutInfo.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayoutInfo.h) | Retained | Preserve compact snapshots, center/baseline/inset rounding and exact scaled-reuse thresholds. |
| [STULabelLayoutInfo.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelLayoutInfo.mm) | Retained | Preserve compact snapshots, center/baseline/inset rounding and exact scaled-reuse thresholds. |
| [STULabelOverlayStyle.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelOverlayStyle.h) | Retained | Preserve immutable style/builder and custom timing-function equality semantics. |
| [STULabelOverlayStyle.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelOverlayStyle.mm) | Retained | Preserve immutable style/builder and custom timing-function equality semantics. |
| [STULabelPrerenderer-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelPrerenderer-Internal.hpp) | Retained | Preserve forwarding into shared C++ state, frozen API and custom cross-target lifetime bridge. |
| [STULabelPrerenderer-no-ARC.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelPrerenderer-no-ARC.mm) | Retained | Preserve objc_destructInstance before C++ lifetime notification; the coallocation may outlive the Objective-C object. |
| [STULabelPrerenderer.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelPrerenderer.h) | Retained | Preserve forwarding into shared C++ state, frozen API and custom cross-target lifetime bridge. |
| [STULabelPrerenderer.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelPrerenderer.mm) | Retained | Preserve forwarding into shared C++ state, frozen API and custom cross-target lifetime bridge. |
| [STULabelSwiftExtensions.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULabelSwiftExtensions.h) | Retained | Preserve borrowed C tuple; Swift overlay immediately transfers the frame into a strong stored property. |
| [STULayerWithNullDefaultActions.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULayerWithNullDefaultActions.h) | Retained | Preserve minimal animation-suppressing subclasses with distinct Core Animation base classes. |
| [STULayerWithNullDefaultActions.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/STULayerWithNullDefaultActions.m) | Retained | Preserve minimal animation-suppressing subclasses with distinct Core Animation base classes. |
| [STUMainScreenProperties.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUMainScreenProperties.h) | Retained | Preserve explicit trait-collection C bridge. |
| [STUMainScreenProperties.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUMainScreenProperties.m) | Retained | Preserve explicit trait-collection C bridge. |
| [STUObjCRuntimeWrappers.c](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUObjCRuntimeWrappers.c) | Retained | Preserve C runtime allocation boundary and retained-result annotations. |
| [STUObjCRuntimeWrappers.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUObjCRuntimeWrappers.h) | Retained | Preserve C runtime allocation boundary and retained-result annotations. |
| [STUParagraphStyle-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUParagraphStyle-Internal.hpp) | Retained | Preserve shared payload, field schema and common first-line-offset validation including NaN/default semantics. |
| [STUParagraphStyle.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUParagraphStyle.h) | Retained | Preserve shared payload, field schema and common first-line-offset validation including NaN/default semantics. |
| [STUParagraphStyle.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUParagraphStyle.mm) | Retained | Preserve shared payload, field schema and common first-line-offset validation including NaN/default semantics. |
| [STUShapedString-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUShapedString-Internal.hpp) | Retained | Preserve placeholder/coallocation, cancellation-before-construction and explicit retained factory ownership. |
| [STUShapedString.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUShapedString.h) | Retained | Preserve placeholder/coallocation, cancellation-before-construction and explicit retained factory ownership. |
| [STUShapedString.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUShapedString.mm) | Retained | Preserve placeholder/coallocation, cancellation-before-construction and explicit retained factory ownership. |
| [STUStartEndRange-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUStartEndRange-Internal.hpp) | Retained | Preserve signed C range representations and constexpr internal conversions. |
| [STUStartEndRange.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUStartEndRange.h) | Retained | Preserve signed C range representations and constexpr internal conversions. |
| [STUTextAttachment-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttachment-Internal.hpp) | Retained | Preserve immutable drawable/metrics contract, Core Text delegate ownership, direct payload and ordered replacement-mapping callback. |
| [STUTextAttachment.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttachment.h) | Retained | Preserve immutable drawable/metrics contract, Core Text delegate ownership, direct payload and ordered replacement-mapping callback. |
| [STUTextAttachment.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttachment.mm) | Changed | Preserve immutable metrics, run-delegate ownership and replacement mapping; correct Method-vs-IMP comparison to restore the no-op drawing fast path. |
| [STUTextAttributes-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttributes-Internal.hpp) | Retained | Preserve small attribute declaration/aggregation boundary. |
| [STUTextAttributes.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttributes.h) | Retained | Preserve small attribute declaration/aggregation boundary. |
| [STUTextAttributes.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextAttributes.mm) | Retained | Preserve small attribute declaration/aggregation boundary. |
| [STUTextFlags.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFlags.h) | Retained | Preserve bit identities shared with packed styles and frame flags. |
| [STUTextFrame-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrame-Internal.hpp) | Retained | Preserve borrowed contiguous records, range-domain distinctions, cached storage and explicit draw/context/scale controls. |
| [STUTextFrame-Unsafe.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrame-Unsafe.h) | Retained | Preserve exposed contiguous-storage layout, borrowed lifetimes, compact paragraph fields and atomic caches. |
| [STUTextFrame.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrame.h) | Retained | Preserve borrowed contiguous records, range-domain distinctions, cached storage and explicit draw/context/scale controls. |
| [STUTextFrame.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrame.mm) | Retained | Preserve borrowed contiguous records, range-domain distinctions, cached storage and explicit draw/context/scale controls. |
| [STUTextFrameAccessibilityElement-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameAccessibilityElement-Internal.hpp) | Retained | Preserve standalone-vs-label integration, binary-search rotors, shared attachment expansion, weak ownership and stale-tree detachment. |
| [STUTextFrameAccessibilityElement.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameAccessibilityElement.h) | Retained | Preserve standalone-vs-label integration, binary-search rotors, shared attachment expansion, weak ownership and stale-tree detachment. |
| [STUTextFrameAccessibilityElement.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameAccessibilityElement.mm) | Retained | Preserve standalone-vs-label integration, binary-search rotors, shared attachment expansion, weak ownership and stale-tree detachment. |
| [STUTextFrameDrawingOptions-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameDrawingOptions-Internal.hpp) | Retained | Preserve frozen implementation boundary; copying intentionally unfreezes options. |
| [STUTextFrameDrawingOptions.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameDrawingOptions.h) | Retained | Preserve frozen implementation boundary; copying intentionally unfreezes options. |
| [STUTextFrameDrawingOptions.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameDrawingOptions.mm) | Retained | Preserve frozen implementation boundary; copying intentionally unfreezes options. |
| [STUTextFrameLine.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameLine.h) | Retained | Preserve borrowed compact line record, metric bridge and two-CTLine truncation/hyphen representation. |
| [STUTextFrameLine.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameLine.mm) | Retained | Preserve borrowed compact line record, metric bridge and two-CTLine truncation/hyphen representation. |
| [STUTextFrameOptions-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameOptions-Internal.hpp) | Retained | Preserve immutable/builder split, shared field normalization, default writing direction and fixed-token handling. |
| [STUTextFrameOptions.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameOptions.h) | Retained | Preserve immutable/builder split, shared field normalization, default writing direction and fixed-token handling. |
| [STUTextFrameOptions.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameOptions.mm) | Retained | Preserve immutable/builder split, shared field normalization, default writing direction and fixed-token handling. |
| [STUTextFrameRange.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextFrameRange.h) | Retained | Preserve packed comparisons that deliberately ignore line index and alias-safe C extraction. |
| [STUTextHighlightStyle-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextHighlightStyle-Internal.hpp) | Retained | Preserve remove/override/no-effect distinctions, dynamic color resolution and packed resolved style. |
| [STUTextHighlightStyle.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextHighlightStyle.h) | Retained | Preserve remove/override/no-effect distinctions, dynamic color resolution and packed resolved style. |
| [STUTextHighlightStyle.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextHighlightStyle.mm) | Retained | Preserve remove/override/no-effect distinctions, dynamic color resolution and packed resolved style. |
| [STUTextLink-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextLink-Internal.hpp) | Retained | Preserve sorted range search, trailing ownership and lazy shifted-origin publication; retain memory ordering. |
| [STUTextLink.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextLink.h) | Retained | Preserve sorted range search, trailing ownership and lazy shifted-origin publication; retain memory ordering. |
| [STUTextLink.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextLink.mm) | Retained | Preserve sorted range search, trailing ownership and lazy shifted-origin publication; retain memory ordering. |
| [STUTextRange.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextRange.h) | Retained | Preserve simple original/truncated tagged range. |
| [STUTextRectArray-Internal.hpp](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextRectArray-Internal.hpp) | Retained | Preserve tail coallocation, tagged proxies, semantic equality and closest-rectangle tie behavior. |
| [STUTextRectArray.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextRectArray.h) | Retained | Preserve tail coallocation, tagged proxies, semantic equality and closest-rectangle tie behavior. |
| [STUTextRectArray.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTextRectArray.mm) | Retained | Preserve tail coallocation, tagged proxies, semantic equality and closest-rectangle tie behavior. |
| [STUTruncationScope-Internal.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTruncationScope-Internal.h) | Retained | Preserve immutable scope and shared range/enum/token normalization, including original-vs-fixed token storage. |
| [STUTruncationScope.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTruncationScope.h) | Retained | Preserve immutable scope and shared range/enum/token normalization, including original-vs-fixed token storage. |
| [STUTruncationScope.mm](/Users/jessehalley/Developer/STULabel/Source/STULabel/STUTruncationScope.mm) | Retained | Preserve immutable scope and shared range/enum/token normalization, including original-vs-fixed token storage. |
| [UIFont+STUDynamicTypeFontScaling.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/UIFont+STUDynamicTypeFontScaling.h) | Retained | Preserve default-font pointer fast path, equality fallback and weak adjusted-font cache. |
| [UIFont+STUDynamicTypeFontScaling.m](/Users/jessehalley/Developer/STULabel/Source/STULabel/UIFont+STUDynamicTypeFontScaling.m) | Retained | Preserve default-font pointer fast path, equality fallback and weak adjusted-font cache. |
| [module.modulemap](/Users/jessehalley/Developer/STULabel/Source/STULabel/module.modulemap) | Retained | Preserve package module boundaries and explicit unsafe/utility submodules. |
| [stu_label_lldb_formatters.py](/Users/jessehalley/Developer/STULabel/Source/STULabel/stu_label_lldb_formatters.py) | Retained | Preserve layout-aware debugger support; Python 3 and registration defects are recorded as follow-up findings, not app-runtime changes. |
| [stu_mutex.h](/Users/jessehalley/Developer/STULabel/Source/STULabel/stu_mutex.h) | Retained | Preserve C unfair-lock wrapper actively used by font caches. |
