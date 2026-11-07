import Darwin
import Foundation
import STULabelSwift
import Testing

/// Run alone with STULabel-Release; compare repeated runs on the same simulator.
@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["STU_LAYOUT_BENCHMARKS"] == "1"))
struct RenderTaskBenchmarks {
  @Test func renderingAndCancellation() async throws {
    #if DEBUG
    Issue.record("Rendering benchmarks require the Release build configuration.")
    #else
    let thermalStart = ProcessInfo.processInfo.thermalState.rawValue
    let font = UIFont(name: "HelveticaNeue", size: 18)!
    let string = String(repeating: "A quick brown fox jumps over a lazy dog. ", count: 4)
    let plain = NSAttributedString(string: string, attributes: [.font: font])
    let linked = NSAttributedString(
      string: string, attributes: [.font: font, .link: URL(string: "https://example.com")!])
    let shaped = [plain, linked].map {
      STUShapedString($0, defaultBaseWritingDirection: .leftToRight)
    }
    let size = CGSize(width: 240, height: 160)
    let traits = UITraitCollection(displayScale: 2)
    let rendered = STULabelPrerenderer(traitCollection: traits)
    rendered.setSize(size, contentInsets: .zero)
    rendered.maximumNumberOfLines = 0
    rendered.attributedText = linked
    rendered.render()

    let names = ["display/plain/retain", "display/plain/release", "display/links/release",
                 "relayout/mismatched-traits/links", "async-layout-and-render/links"]
    let iterations = 500
    let warmupIterations = 100
    let rounds = 9
    var durations = [[Double]](repeating: [], count: names.count)
    var cpuDurations = [[Double]](repeating: [], count: names.count)
    var checksums = [Int](repeating: 0, count: names.count)

    func display(_ workload: Int) -> Int {
      autoreleasepool {
        let layer = STULabelLayer()
        layer.releasesTextFrameAfterRendering = workload != 0
        if workload == 3 {
          layer.configure(with: rendered)
        } else {
          layer.bounds = CGRect(origin: .zero, size: size)
          layer.contentsScale = 2
          layer.maximumNumberOfLines = 0
          layer.shapedText = shaped[workload == 2 ? 1 : 0]
          layer.display()
        }
        return Int(layer.layoutInfo.lineCount) + layer.links.count
      }
    }

    func layoutAndRender() -> (nanoseconds: UInt64, cpuNanoseconds: UInt64, checksum: Int) {
      autoreleasepool {
        let prerenderer = STULabelPrerenderer(traitCollection: traits)
        prerenderer.setSize(size, contentInsets: .zero)
        prerenderer.maximumNumberOfLines = 0
        prerenderer.attributedText = linked
        _ = prerenderer.shapedText
        var elapsed: UInt64 = 0
        var cpu: UInt64 = 0
        // Exercise the asynchronous worker's layout path without queue-start noise.
        prerenderer.render(scheduler: { context, function in
          let start = DispatchTime.now().uptimeNanoseconds
          let cpuStart = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
          function(context)
          cpu = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID) - cpuStart
          elapsed = DispatchTime.now().uptimeNanoseconds - start
        })
        var info = STULabelLayoutInfo()
        let completed = prerenderer.tryGet(sizeThatFits: nil, layoutInfo: &info)
        return (elapsed, cpu, completed ? Int(info.lineCount) : 0)
      }
    }

    func drainHandoffs() async {
      await withCheckedContinuation { continuation in
        DispatchQueue.main.async { continuation.resume() }
      }
    }

    for workload in names.indices {
      for _ in 0..<warmupIterations {
        checksums[workload] += workload == 4 ? layoutAndRender().checksum : display(workload)
      }
      await drainHandoffs()
    }
    for round in 0..<rounds {
      for offset in names.indices {
        let workload = (round + offset) % names.count
        var elapsed: UInt64 = 0
        var cpu: UInt64 = 0
        if workload == 4 {
          for _ in 0..<iterations {
            let result = layoutAndRender()
            elapsed += result.nanoseconds
            cpu += result.cpuNanoseconds
            checksums[workload] += result.checksum
          }
        } else {
          let start = DispatchTime.now().uptimeNanoseconds
          let cpuStart = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
          for _ in 0..<iterations { checksums[workload] += display(workload) }
          cpu = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID) - cpuStart
          elapsed = DispatchTime.now().uptimeNanoseconds - start
        }
        durations[workload].append(Double(elapsed) / Double(iterations))
        cpuDurations[workload].append(Double(cpu) / Double(iterations))
        await drainHandoffs()
      }
    }

    var cancellationDurations = [UInt64]()
    var cancellationCalls = [Int]()
    for iteration in 0..<17 {
      let probe = LayoutCancellationProbe()
      let layer = makeCancellableLayoutLayer(probe)
      _ = layer.shapedText
      defer {
        layer.text = "Replacement"
        layer.lastHyphenationLocationInRangeFinder = nil
        probe.resume.signal()
      }
      layer.display()
      let entered = await Task.detached { probe.waitForEntry() }.value
      try #require(entered == .success)
      layer.text = "Replacement"
      layer.lastHyphenationLocationInRangeFinder = nil
      probe.resumeAfterCancellation()
      let finished = await Task.detached { probe.waitForFinish() }.value
      try #require(finished == .success)
      if iteration >= 2 {
        cancellationDurations.append(probe.cancellationNanoseconds)
        cancellationCalls.append(probe.callCount)
      }
    }

    func report(_ record: [String: Any]) throws {
      var record = record
      record["os"] = ProcessInfo.processInfo.operatingSystemVersionString
      record["thermalStateAtStart"] = thermalStart
      record["thermalStateAtEnd"] = ProcessInfo.processInfo.thermalState.rawValue
      let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
      print("STU_RENDER_BENCHMARK " + String(decoding: data, as: UTF8.self))
    }
    for workload in names.indices {
      #expect(checksums[workload] > 0)
      #expect(cpuDurations[workload].allSatisfy { $0 > 0 })
      try report([
        "workload": names[workload], "nanosecondsPerOperation": durations[workload],
        "threadCpuNanosecondsPerOperation": cpuDurations[workload],
        "iterationsPerSample": iterations, "warmupIterations": warmupIterations,
        "checksum": checksums[workload],
      ])
    }
    try report([
      "workload": "cancelled-layout", "nanosecondsToReleaseFinder": cancellationDurations,
      "hyphenationCalls": cancellationCalls, "wordCount": 500,
    ])
    #endif
  }

  @Test func matchedPrerenderHandoff() throws {
    #if DEBUG
    Issue.record("Rendering benchmarks require the Release build configuration.")
    #else
    let traits = UITraitCollection.current
    let prerenderers = ["0 ", "1 "].map { prefix in
      let result = STULabelPrerenderer(traitCollection: traits)
      result.setSize(CGSize(width: 240, height: 160), contentInsets: .zero)
      result.maximumNumberOfLines = 0
      result.attributedText = NSAttributedString(
        string: prefix + String(repeating: "A quick brown fox jumps over a lazy dog. ", count: 4),
        attributes: [.font: UIFont(name: "HelveticaNeue", size: 18)!,
                     .link: URL(string: "https://example.com")!])
      result.render()
      return result
    }
    let layer = STULabelLayer()
    layer.renderingTraitCollection = traits
    layer.releasesTextFrameAfterRendering = true
    // Keep both cached bitmaps resident while measuring result assignment.
    let images = try prerenderers.map { prerenderer in
      layer.configure(with: prerenderer)
      #expect(layer.shapedText === prerenderer.shapedText)
      return try #require(layer.contents ?? layer.sublayers?.first?.contents)
    }

    var next = 0
    func handoff() -> Int {
      autoreleasepool {
        layer.configure(with: prerenderers[next])
        next ^= 1
        return layer.links.count
      }
    }
    let thermalStart = ProcessInfo.processInfo.thermalState.rawValue
    let iterations = 100_000
    let warmupIterations = 500_000
    let batchSize = 1_000
    var checksum = 0
    func measureBatch() -> (wall: UInt64, cpu: UInt64) {
      let start = DispatchTime.now().uptimeNanoseconds
      let cpuStart = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)
      for _ in 0..<batchSize { checksum += handoff() }
      let cpu = clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID) - cpuStart
      let elapsed = DispatchTime.now().uptimeNanoseconds - start
      // Bound Core Animation's pending changes without timing transaction commits.
      CATransaction.flush()
      return (elapsed, cpu)
    }
    for _ in 0..<(warmupIterations/batchSize) { _ = measureBatch() }
    var durations = [Double]()
    var cpuDurations = [Double]()
    for _ in 0..<9 {
      var wall: UInt64 = 0
      var cpu: UInt64 = 0
      for _ in 0..<(iterations/batchSize) {
        let elapsed = measureBatch()
        wall += elapsed.wall
        cpu += elapsed.cpu
      }
      durations.append(Double(wall) / Double(iterations))
      cpuDurations.append(Double(cpu) / Double(iterations))
    }
    #expect(cpuDurations.allSatisfy { $0 > 0 })
    #expect(checksum == warmupIterations + 9*iterations)
    #expect(layer.text == prerenderers[next ^ 1].attributedText?.string)
    withExtendedLifetime(images) {}
    let record: [String: Any] = [
      "workload": "handoff/matching-traits/links/release",
      "fixture": "reused layer, alternating resident matching-trait results; flush every 1000 handoffs outside timing",
      "nanosecondsPerOperation": durations, "threadCpuNanosecondsPerOperation": cpuDurations,
      "iterationsPerSample": iterations, "warmupIterations": warmupIterations, "checksum": checksum,
      "thermalStateAtStart": thermalStart,
      "thermalStateAtEnd": ProcessInfo.processInfo.thermalState.rawValue,
      "os": ProcessInfo.processInfo.operatingSystemVersionString,
    ]
    let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
    print("STU_HANDOFF_BENCHMARK " + String(decoding: data, as: UTF8.self))
    #endif
  }
}
