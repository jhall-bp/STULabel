# This justfile builds and tests the local Swift package through its Xcode workspace.

set shell := ["zsh", "-cu"]

build_dir := "build"
derived_data_dir := build_dir / "derived_data"
workspace := ".swiftpm/xcode/package.xcworkspace"
scheme := "STULabel-Package"
unicode_version := "17.0.0"
simulator_destination := env_var_or_default("SIMULATOR_DESTINATION", "platform=iOS Simulator,OS=27.0,name=iPhone 17 Pro")
xcodebuild := "xcodebuild -workspace " + workspace + " -scheme " + scheme + " -quiet -derivedDataPath " + derived_data_dir
xcode_build_settings := "CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO"
lto_flags := if env_var_or_default("LTO", "") == "" { "" } else { "LLVM_LTO=" + env_var_or_default("LTO", "") }

# List available recipes.
default:
    @just --list

# Print the resolved Swift package manifest.
package-graph:
    swift package dump-package

# Resolve dependencies declared by the Swift package.
resolve:
    swift package resolve

# Build both package products in debug and release configurations.
build: resolve build-debug build-release

build-debug:
    {{ xcodebuild }} -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' build {{ xcode_build_settings }} {{ lto_flags }}
    {{ xcodebuild }} -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

build-release:
    {{ xcodebuild }} -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' build {{ xcode_build_settings }} {{ lto_flags }}
    {{ xcodebuild }} -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build {{ xcode_build_settings }} {{ lto_flags }}

# Build the complete package test suite for the iOS simulator.
build-for-testing: resolve
    {{ xcodebuild }} -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build-for-testing {{ xcode_build_settings }} {{ lto_flags }}

# Run every SwiftPM test target: Swift, Objective-C ARC, and Objective-C no-ARC.
test: build-for-testing
    {{ xcodebuild }} -configuration Debug -destination '{{ simulator_destination }}' test-without-building -only-testing:STULabelTests -only-testing:STULabelTestsObjC -only-testing:STULabelTestsObjCNoARC {{ xcode_build_settings }} {{ lto_flags }}

# Run the complete suite except the two longest tests, for local iteration only.
test-fast: build-for-testing
    {{ xcodebuild }} -configuration Debug -destination '{{ simulator_destination }}' test-without-building -only-testing:STULabelTests -only-testing:STULabelTestsObjC -only-testing:STULabelTestsObjCNoARC -skip-testing:STULabelTestsObjC/NSStringRefTests/testGraphemeClusterBreakFinding -skip-testing:STULabelTests/ShapedStringTests/testCTTypesetterThreadSafety {{ xcode_build_settings }} {{ lto_flags }}

# Remove Xcode build products and test results.
clean:
    {{ xcodebuild }} clean {{ xcode_build_settings }} {{ lto_flags }}

generate-unicode-code-point-properties:
    uv run Scripts/generate_unicode_code_point_properties.py \
          --unicode-version {{ unicode_version }} \
          --verify-tail \
          --output Source/STULabel/Internal/UnicodeCodePointProperties.generated.inc
