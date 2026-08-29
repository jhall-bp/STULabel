// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "STULabelConsumer",
  platforms: [
    .iOS(.v26),
    .macCatalyst(.v26),
  ],
  products: [
    .library(name: "STULabelConsumer", targets: ["STULabelConsumer"]),
  ],
  dependencies: [
    .package(name: "STULabel", path: "../.."),
  ],
  targets: [
    .target(
      name: "STULabelConsumer",
      dependencies: [
        .product(name: "STULabelSwift", package: "STULabel"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
