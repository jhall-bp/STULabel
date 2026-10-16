import Foundation
import STULabelSwift
import Testing

/// Run with the STULabel-Release scheme. Timings are observations, not machine-specific pass limits.
@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["STU_LAYOUT_BENCHMARKS"] == "1"))
struct TextFrameLayoutBenchmarks {
  @Test func preshapedMultilingualLayout() throws {
    #if DEBUG
    Issue.record("Layout benchmarks require the Release build configuration.")
    #else
    let font = UIFont(name: "HelveticaNeue", size: 18)!
    let samples = [
      ("Latin", String(repeating: "A quick brown fox jumps over a lazy dog. ", count: 8)),
      ("Arabic", String(repeating: "اختبار النص العربي والمسافات ", count: 8)),
      ("Emoji", String(repeating: "👩🏽‍🚀😀 🇦🇺✊🏿🌈 ", count: 12)),
      ("Indic", String(repeating: "क्षेत्र हिन्दी परीक्षण ", count: 12)),
    ].map { name, string in
      (name, STUShapedString(
        NSAttributedString(string: string, attributes: [.font: font]),
        defaultBaseWritingDirection: .leftToRight))
    }
    let iterations = 4_000
    let rounds = 9
    var durations = [[Double]](repeating: [], count: samples.count)
    var lineCounts = [Int](repeating: 0, count: samples.count)

    func layout(_ shapedString: STUShapedString) -> Int {
      autoreleasepool {
        STUTextFrame(shapedString, size: CGSize(width: 120, height: 10000),
                     displayScale: 2).lines.count
      }
    }

    for (index, sample) in samples.enumerated() {
      for _ in 0..<500 { lineCounts[index] += layout(sample.1) }
    }
    // Rotate the workload order so one script does not always run on a colder CPU.
    for round in 0..<rounds {
      for offset in samples.indices {
        let index = (round + offset) % samples.count
        let start = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<iterations { lineCounts[index] += layout(samples[index].1) }
        let elapsed = DispatchTime.now().uptimeNanoseconds - start
        durations[index].append(Double(elapsed) / Double(iterations))
      }
    }

    for index in samples.indices {
      let record: [String: Any] = [
        "workload": samples[index].0,
        "nanosecondsPerLayout": durations[index],
        "iterationsPerSample": iterations,
        "warmupIterations": 500,
        "lineCountChecksum": lineCounts[index],
        "os": ProcessInfo.processInfo.operatingSystemVersionString,
      ]
      let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
      print("STU_LAYOUT_BENCHMARK " + String(decoding: data, as: UTF8.self))
    }
    #endif
  }
}
