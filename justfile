# This justfile validates the package and its real Xcode and SwiftPM consumers.

set shell := ["zsh", "-cu"]

build_dir := "build"
package_derived_data_dir := build_dir / "package"
demo_derived_data_dir := build_dir / "demo"
consumer_derived_data_dir := build_dir / "consumer"
package_workspace := ".swiftpm/xcode/package.xcworkspace"
package_scheme := "STULabel-Package"
demo_project := "Demo/STULabel.xcodeproj"
demo_scheme := "Demo"
consumer_workspace := "Integration/PackageConsumer/.swiftpm/xcode/package.xcworkspace"
consumer_scheme := "STULabelConsumer"
unicode_version := "17.0.0"
simulator_destination := env_var_or_default("SIMULATOR_DESTINATION", "platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro")
package_xcodebuild := "xcodebuild -workspace " + package_workspace + " -scheme " + package_scheme + " -quiet -derivedDataPath " + package_derived_data_dir
demo_xcodebuild := "xcodebuild -project " + demo_project + " -scheme " + demo_scheme + " -quiet -derivedDataPath " + demo_derived_data_dir
consumer_xcodebuild := "xcodebuild -workspace " + consumer_workspace + " -scheme " + consumer_scheme + " -quiet -derivedDataPath " + consumer_derived_data_dir
xcode_build_settings := "CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO"
lto_flags := if env_var_or_default("LTO", "") == "" { "" } else { "LLVM_LTO=" + env_var_or_default("LTO", "") }

# List available recipes.
default:
    @just --list

format:
    swift format --recursive --in-place . \
    && find . \( -name '*.h' -o -name '*.m' -o -name '*.mm' -o -name '*.c' -o -name '*.cc' -o -name '*.cpp' \) \
          -exec xcrun clang-format -i {} +

# Print the resolved Swift package manifest.
package-graph:
    swift package dump-package

# Resolve dependencies declared by the Swift package.
resolve:
    swift package resolve

# Validate the package and every supported consumer shape.
build: resolve build-package build-demo build-maccatalyst build-consumer

# Build both package products in debug and release configurations.
build-package: build-package-debug build-package-release

build-package-debug:
    {{ package_xcodebuild }} -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' build {{ xcode_build_settings }} {{ lto_flags }}
    {{ package_xcodebuild }} -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

build-package-release:
    {{ package_xcodebuild }} -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' build {{ xcode_build_settings }} {{ lto_flags }}
    {{ package_xcodebuild }} -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

# Build the app that exercises the package from Swift and Objective-C.
build-demo:
    {{ demo_xcodebuild }} -configuration Debug -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

# Build the Demo through its supported Mac Catalyst destination.
build-maccatalyst:
    {{ demo_xcodebuild }} -configuration Debug -destination 'generic/platform=macOS,variant=Mac Catalyst' build {{ xcode_build_settings }} {{ lto_flags }}

# Build a separate package that consumes STULabel exclusively through its public products.
build-consumer:
    {{ consumer_xcodebuild }} -configuration Debug -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

# Build the complete package test suite for the iOS simulator.
build-for-testing: resolve
    {{ package_xcodebuild }} -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build-for-testing {{ xcode_build_settings }} {{ lto_flags }}

# Run every SwiftPM test target: Swift, Objective-C ARC, and Objective-C no-ARC.
test: build-for-testing
    {{ package_xcodebuild }} -configuration Debug -destination '{{ simulator_destination }}' test-without-building -only-testing:STULabelTests -only-testing:STULabelTestsObjC -only-testing:STULabelTestsObjCNoARC {{ xcode_build_settings }} {{ lto_flags }}

# Run the complete suite except the two longest tests, for local iteration only.
test-fast: build-for-testing
    {{ package_xcodebuild }} -configuration Debug -destination '{{ simulator_destination }}' test-without-building -only-testing:STULabelTests -only-testing:STULabelTestsObjC -only-testing:STULabelTestsObjCNoARC -skip-testing:STULabelTestsObjC/NSStringRefTests/testGraphemeClusterBreakFinding -skip-testing:STULabelTests/ShapedStringTests/testCTTypesetterThreadSafety {{ xcode_build_settings }} {{ lto_flags }}

# Remove Xcode build products and test results.
clean:
    {{ package_xcodebuild }} clean {{ xcode_build_settings }} {{ lto_flags }}
    {{ demo_xcodebuild }} clean {{ xcode_build_settings }} {{ lto_flags }}
    {{ consumer_xcodebuild }} clean {{ xcode_build_settings }} {{ lto_flags }}

generate-unicode-code-point-properties:
    uv run Scripts/generate_unicode_code_point_properties.py \
          --unicode-version {{ unicode_version }} \
          --verify-tail \
          --output Source/STULabel/Internal/UnicodeCodePointProperties.generated.inc
