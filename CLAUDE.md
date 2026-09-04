# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

PrimeMove is an iOS app built with SwiftUI, generated from the default Xcode App template. As of this writing it is a fresh scaffold: `PrimeMoveApp` (the `@main` entry point) renders a single `ContentView` showing the placeholder "Hello, world!" view. There is no custom architecture, networking, persistence, or test target yet — most real work will involve adding new code rather than navigating existing structure.

- iOS only (`TARGETED_DEVICE_FAMILY = 1`, iPhone), `SDKROOT = iphoneos`.
- Swift 5 language mode, SwiftUI lifecycle, Info.plist auto-generated (`GENERATE_INFOPLIST_FILE = YES`).
- Bundle id: `com.example.PrimeMove` (placeholder — update before distribution).
- The Xcode project (`PrimeMove.xcodeproj`) has a single target and single scheme, both named `PrimeMove`.

## Build & run

There is no `Package.swift` or workspace — build through the `.xcodeproj` with `xcodebuild`, or open in Xcode.

```bash
# Build for the simulator
xcodebuild -project PrimeMove.xcodeproj -scheme PrimeMove \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# List available simulator destinations if the name above is unavailable
xcodebuild -showdestinations -project PrimeMove.xcodeproj -scheme PrimeMove

# Clean
xcodebuild -project PrimeMove.xcodeproj -scheme PrimeMove clean
```

Note: passing no `-scheme`/`-configuration` to `xcodebuild` defaults to the **Release** configuration. Use `-configuration Debug` during development.

## Tests

No test target exists yet. Once one is added, run:

```bash
xcodebuild test -project PrimeMove.xcodeproj -scheme PrimeMove \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test
xcodebuild test -project PrimeMove.xcodeproj -scheme PrimeMove \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PrimeMoveTests/SomeTestClass/testSomething
```
