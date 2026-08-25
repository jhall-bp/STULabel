// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "STULabel",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v26),
    .tvOS(.v26),
    .watchOS(.v26),
    .macCatalyst(.v26),
  ],
  products: [
    .library(name: "STULabel", targets: ["STULabel"]),
    .library(name: "STULabelSwift", targets: ["STULabelSwift"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing",
      from: "1.19.4",
    )
  ],
  targets: [
    .target(
      name: "STULabelNoARC",
      path: "Source/STULabel",
      exclude: ["Resources"],
      sources: [
        "Internal/Color-no-ARC.mm",
        "Internal/NSArrayRef-no-ARC.mm",
        "Internal/NSAttributedString-no-ARC.mm",
        "Internal/STUPlaceholderObjects-no-ARC.m",
        "STULabelPrerenderer-no-ARC.mm",
        "STUObjCRuntimeWrappers-no-ARC.m",
      ],
      publicHeadersPath: "NoARC/include",
      cSettings: [
        .headerSearchPath(".."),
        .headerSearchPath("Internal"),
        .define("STU_IMPLEMENTATION"),
        .define("DEBUG", .when(configuration: .debug)),
        .unsafeFlags(["-fno-objc-arc", "-fmodules"]),
      ],
      cxxSettings: [
        .unsafeFlags(["-fno-objc-arc", "-fno-rtti", "-fcxx-modules"]),
        .unsafeFlags(
          ["-fno-exceptions", "-fno-objc-exceptions", "-fno-objc-arc-exceptions", "-UNDEBUG"],
          .when(configuration: .release)),
      ],
      linkerSettings: [
        .unsafeFlags(["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"])
      ]
    ),
    .target(
      name: "STULabel",
      dependencies: ["STULabelNoARC"],
      exclude: [
        "STULabel.modulemap",
        "Internal/Color-no-ARC.mm",
        "Internal/NSArrayRef-no-ARC.mm",
        "Internal/NSAttributedString-no-ARC.mm",
        "Internal/STUPlaceholderObjects-no-ARC.m",
        "STULabelPrerenderer-no-ARC.mm",
        "STUObjCRuntimeWrappers-no-ARC.m",
      ],
      resources: [.process("Resources")],
      publicHeadersPath: ".",
      cSettings: [
        .headerSearchPath(".."),
        .headerSearchPath("Internal"),
        .define("STU_IMPLEMENTATION"),
        .define("DEBUG", .when(configuration: .debug)),
        .unsafeFlags(["-fobjc-arc", "-fmodules"]),
      ],
      cxxSettings: [
        .unsafeFlags(["-fobjc-arc", "-fno-rtti", "-fcxx-modules"]),
        .unsafeFlags(
          ["-fno-exceptions", "-fno-objc-exceptions", "-fno-objc-arc-exceptions", "-UNDEBUG"],
          .when(configuration: .release)),
      ]
    ),
    .target(
      name: "STULabelSwift",
      dependencies: ["STULabel"],
      swiftSettings: [
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      ]
    ),
    .testTarget(
      name: "STULabelTests",
      dependencies: [
        "STULabel",
        "STULabelSwift",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      ],

    ),
  ],
  swiftLanguageModes: [.v6],
  cLanguageStandard: .gnu11,
  cxxLanguageStandard: .cxx2b
)
