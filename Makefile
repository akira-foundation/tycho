.DEFAULT_GOAL := help
.PHONY: help test build test-ui test-ios lint swiftlint format format-check

KIT := Packages/TychoKit
SWIFT_FORMAT := xcrun swift-format
SOURCES := $(KIT)/Sources $(KIT)/Tests $(KIT)/Package.swift Tycho TychoUITests
MAC := -scheme Tycho -destination 'platform=macOS'
IOS := -scheme Tycho -destination 'generic/platform=iOS Simulator'
SIM := -scheme Tycho -destination 'platform=iOS Simulator,name=iPhone 17'

help: ## Show this list
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-13s %s\n", $$1, $$2}'

test: ## Run the TychoKit suite
	cd $(KIT) && swift test

build: ## Build the app for macOS and the iOS simulator
	xcodebuild build $(MAC) CODE_SIGNING_ALLOWED=NO -quiet
	xcodebuild build $(IOS) CODE_SIGNING_ALLOWED=NO -quiet

test-ui: ## Run the macOS UI smoke test
	xcodebuild test $(MAC) -only-testing:TychoUITests -quiet

test-ios: ## Build and run the UI smoke test in the iOS simulator
	xcodebuild test $(SIM) -only-testing:TychoUITests -quiet

lint: swiftlint format-check ## Run SwiftLint and swift-format strictly

swiftlint: ## Run SwiftLint against .swiftlint.yml
	./Tools/swiftlint.sh

format: ## Rewrite sources with swift-format
	$(SWIFT_FORMAT) format --in-place --recursive --parallel $(SOURCES)

format-check: ## Fail when a source is not formatted
	$(SWIFT_FORMAT) lint --strict --recursive --parallel $(SOURCES)
