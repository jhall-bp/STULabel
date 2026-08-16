# This Makefile verifies the products that Xcode apps consume from the local Swift package.

BUILD_DIR := build
DERIVED_DATA_DIR := $(BUILD_DIR)/derived_data

PACKAGE_SCHEME := STULabelPackage
SIMULATOR_DESTINATION ?= platform=iOS Simulator,OS=latest,name=iPhone 17 Pro

XCODEBUILD := set -o pipefail && $(shell command -v xcodebuild) \
              -project STULabel.xcodeproj \
              -scheme $(PACKAGE_SCHEME) \
              -quiet \
              -derivedDataPath $(DERIVED_DATA_DIR)

XCODE_BUILD_SETTINGS := CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO
ifdef LTO
  XCODE_BUILD_SETTINGS += LLVM_LTO=$(LTO)
endif

SKIP_SLOW_TESTS ?= true
SKIP_TESTING :=
ifeq ($(SKIP_SLOW_TESTS),true)
  SKIP_TESTING := -skip-testing:AllTests/NSStringRefTests/testGraphemeClusterBreakFinding \
                  -skip-testing:AllTests/ShapedStringTests/testCTTypesetterThreadSafety
endif

.PHONY: package-graph resolve build build-debug build-release build-for-testing test clean

package-graph:
	swift package dump-package

resolve:
	$(XCODEBUILD) -resolvePackageDependencies

# Build the app consumer and both package products for each shipping configuration and platform.
build: resolve build-debug build-release

build-debug:
	$(XCODEBUILD) -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' build $(XCODE_BUILD_SETTINGS)
	$(XCODEBUILD) -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build $(XCODE_BUILD_SETTINGS)

build-release:
	$(XCODEBUILD) -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' build $(XCODE_BUILD_SETTINGS)
	$(XCODEBUILD) -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build $(XCODE_BUILD_SETTINGS)

build-for-testing: resolve
	$(XCODEBUILD) -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build-for-testing $(XCODE_BUILD_SETTINGS)

test: build-for-testing
	$(XCODEBUILD) -configuration Debug -destination '$(SIMULATOR_DESTINATION)' test-without-building $(SKIP_TESTING) $(XCODE_BUILD_SETTINGS)

clean:
	$(XCODEBUILD) clean $(XCODE_BUILD_SETTINGS)
