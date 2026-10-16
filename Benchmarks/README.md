# Release text layout measurements

Select **STULabel-Release** and an iOS destination in Xcode, then run only
`TextFrameLayoutBenchmarks/preshapedMultilingualLayout()`. The shared scheme enables
`STU_LAYOUT_BENCHMARKS=1` and uses Release with coverage and debugger attachment disabled.
The benchmark is skipped by the ordinary Debug scheme; explicitly enabling it in Debug reports an issue.
Do not run other tests or background rendering while collecting timings.

The Swift Testing benchmark shapes each string once, warms 500 layouts, then records
nine samples of 4,000 layouts per workload. Workload order rotates between samples.
Each timed operation constructs and releases an STUTextFrame at width 120, height 10,000,
display scale 2, using Helvetica Neue 18 pt. Timings include frame allocation, layout,
line-count access and autorelease-pool cleanup; they exclude shaping and drawing.
A printed line-count checksum keeps the result observable. These are measurements,
not machine-specific pass/fail thresholds.

## Grapheme normalization investigation — 2026-10-17

The earlier Debug observation of an 11.6% emoji-heavy slowdown did **not** reproduce
as a demonstrated Release regression. Five separate runs per variant gave:

| Workload | Before correctness fix | Correctness fix | Scanner candidate |
| --- | ---: | ---: | ---: |
| Latin | 38.657 µs | 38.653 µs | 38.473 µs |
| Arabic | 76.021 µs | 77.250 µs | 76.173 µs |
| Emoji | 17.293 µs | 17.413 µs | 17.195 µs |
| Indic | 23.519 µs | 23.754 µs | 23.480 µs |

Each cell is the median of five run medians; each run median contains nine samples.
Emoji run medians ranged from 17.057–17.794 µs before the fix, 16.981–17.566 µs
with the fix, and 16.827–17.528 µs with the candidate. The fix's observed +0.7%
and candidate's observed −1.3% are smaller than the run-to-run spread. These data
do not establish equivalence or a repeatable end-to-end improvement.

Environment: Xcode 27.0 RC, arm64 iPhone 17 Pro simulator, iOS 27.0 (24A434).
Build logs verified Clang `-Os`, Swift `-O -whole-module-optimization`, and no
coverage instrumentation. This is simulator evidence, not a physical-device or
cold-font-cache result. [Raw samples](2026-10-17-release-layout.json) retain run
times, checksums and the additional exploratory smoke run. Timings from the full
correctness-suite run are excluded.

“Before” restores only `TextFrameLayouter-LineBreaking.mm` from `0cb7dc0^`;
the rest of production source is `0cb7dc0`. “Correctness fix” is `0cb7dc0`.
The experimental candidate peeled the first scalar comparison in
`NSStringRef::endIndexOfGraphemeClusterAtImpl_utf16Buffer`, returning immediately
only when the existing category-pair table said `isBreak`. All other pairs
initialized the existing BreakFinder with the original index/category and consumed
the already decoded scalar. This retained RI parity, emoji ZWJ, Indic conjunct and
CRLF rules, but added control flow and a duplicate initial table lookup on continuing
clusters. **The candidate was discarded; production grapheme logic is unchanged.**

A temporary focused benchmark collected the emoji workload's 11 nonterminal
Core Text line endpoints at the same font and width. It validated the endpoints
outside timing, warmed 1,000 passes, then measured seven samples of 1,000,010 boundary
queries with a compiler memory barrier before every pass. Original/candidate/original
median query costs were 4.272/4.054/4.260 ns with identical checksums.
That suggests only about 2.3 ns saved across a 12-line frame (under 0.02% of total
layout time), insufficient to justify the extra production complexity.
The focused temporary benchmark was removed after the experiment.

## Measurement repairs

Release C++ test targets previously enabled exceptions while the library disabled
them. Instantiating internal Optional helpers then referenced the library's absent
`throwBadOptionalAccess` symbol. The test targets now match the library's Release
C++ exception/assertion settings, retaining Objective-C exceptions for XCTest.

The existing long-Indic benchmark repeatedly called pure functions with invariant
arguments. Its logged checksum did not stop Release from hoisting those calls.
Adding a compiler memory barrier before each pass changed the 4,097-unit result
from 0.023 ms to 3.430 ms per 200 forward/backward passes. The same barrier protects
the general grapheme scan benchmark. These barriers execute no machine instruction;
they require fresh memory reads for each pass.

## Correctness validation

All three Release test targets passed: 154 Swift Testing tests (including parameterized
cases and snapshots), 84 Objective-C ARC tests, and one Objective-C no-ARC test.
The benchmark also passed independently. The final combined run with the explicit
test plan reported 285 passed, zero failed and three unavailable entries: the empty
SnapshotTestCase base class and two tests compiled only in Debug. A focused Debug
run passed 36 cases and correctly skipped the opt-in benchmark. The existing Unicode 17 corpus checks 766
official grapheme cases at every scalar position through both direct UTF-16 and
message-buffered string representations. The discarded candidate also passed that
corpus, malformed-surrogate and long-Indic regressions.

During measurement, Xcode's MCP result-bundle export repeatedly reported an incomplete
bundle for the initial legacy Release scheme. The test processes themselves completed;
the MCP live console supplied full sample output, passing suite summaries and exit
code 0. Incomplete-bundle errors alone were never treated as successful runs.
The committed scheme uses an explicit test plan; two successive benchmark runs
then exported complete result bundles successfully. Those final configuration
verification runs are retained separately in the raw data and excluded from the
five-run comparison table.
