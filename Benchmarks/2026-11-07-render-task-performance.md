Release measurements for review fixes #2 and #5 — 7 November 2026.

The final implementation preserves links before releasing cached text frames, retains the frame needed by tiled drawing, and passes cancellation into asynchronous layout. Link creation and whole-task cancellation are shared. Redundant task release-preference overrides are removed. Rendering-only cancellation remains separate because the label can still reuse a completed layout.

Cancelled-layout cleanup fell from **92.919 ms to 0.453 ms (−99.51%)**. The paused 500-word fixture made **1,999 hyphenation callbacks before the fix and one afterward**, eliminating all 1,998 callbacks after cancellation.

| Workload | Before CPU (µs/op) | After CPU (µs/op) | Change |
| --- | ---: | ---: | ---: |
| Plain rendering, retain frame (control) | 69.490 | 69.729 | +0.34% |
| Plain rendering, release frame | 69.701 | 69.169 | -0.76% |
| Linked text, release frame | 69.593 | 69.736 | +0.20% |
| Relayout after trait mismatch | 19.284 | 19.529 | +1.27% |
| Async layout and rendering | 68.261 | 68.471 | +0.31% |
| Cached result handoff | 0.743 | 0.719 | -3.24% |

There is no consistent slowdown in these normal-path measurements. Linked rendering (+0.20%) and async layout/rendering (+0.31%) track the unchanged control (+0.34%). The +1.27% trait-mismatch result is smaller than its baseline launch variation (18.781–19.788 µs). Treat the apparent handoff improvement as measurement variation, rather than a promised speedup.

The [raw results](/Users/jessehalley/Developer/STULabel/Benchmarks/2026-11-07-render-task-performance.json) include every sample from the final protocol, both elapsed and thread CPU times, launch medians, environment, and Xcode result-bundle paths.

Measurements used Xcode 27.2.0, the STULabel-Release scheme/test plan, arm64 iPhone 18 Pro simulator running iOS 27.0 (24A434), iOS Simulator 27.2 SDK, and code coverage disabled. Thermal state was nominal throughout the recorded launches.

Each variant ran twice per benchmark. Values above are the median of the two launch medians. Normal workloads use nine samples of 500 operations after 100 warmups; workload order rotates. Cached handoff uses nine samples of 100,000 operations after 500,000 warmups, alternating two matching-trait results on one layer. Their images remain resident, and Core Animation transactions flush outside timing. Cancellation uses 15 samples after two warmups and measures worker resumption through release of the obsolete finder.

Before runs used the exact captured original production sources at a1660c4. After runs used the final sources, verified after restoration. The same benchmark harness was used on both variants. Earlier exploratory fixtures and implementation variants are excluded from this final comparison and explained in the JSON.

Validation on the final implementation:

- Release lifecycle tests: **14 passed**, covering release timing, links, tiled-frame lifetime, layout cancellation, drawing cancellation, and layout reuse.
- Full Debug suite: **316 passed, 0 failed, 3 skipped**. The three skipped cases are opt-in benchmarks.
- The existing Package.resolved contents were preserved.

To repeat through Xcode MCP, select STULabel-Release (its test plan enables STU_LAYOUT_BENCHMARKS=1) and run RenderTaskBenchmarks/renderingAndCancellation() and RenderTaskBenchmarks/matchedPrerenderHandoff() separately with RunSomeTests. Retrieve STU_RENDER_BENCHMARK and STU_HANDOFF_BENCHMARK records using GetConsoleOutput. Keep the simulator and benchmark source identical across variants and avoid overlapping other Xcode work.

These are warm-cache simulator measurements, with two launches per variant; they do not establish strict zero overhead on every device or workload.
