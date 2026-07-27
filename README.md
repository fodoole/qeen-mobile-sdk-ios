# QeenSDK (iOS)

Qeen's mobile analytics SDK for iOS, shipped as a binary XCFramework. Provider-agnostic
public API; the analytics engine is an internal implementation detail.

> Private distribution: your GitHub account must have read access to this repo. In Xcode,
> sign in under **Settings ▸ Accounts** (or configure a git credential/SSH key) so SPM can
> resolve the package.

## Install (Swift Package Manager)

**Xcode:** File ▸ Add Package Dependencies… → enter:

```
https://github.com/fodoole/qeen-mobile-sdk-ios.git
```

Pick a version (e.g. **Up to Next Major** from `0.1.0`) and add the **QeenSDK** library to your app target.

**Or in `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/fodoole/qeen-mobile-sdk-ios.git", from: "0.1.0"),
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "QeenSDK", package: "qeen-mobile-sdk-ios"),
    ]),
]
```

Requirements: iOS 15+, Xcode 16+.

## Usage

```swift
import QeenSDK

// Once, as early as possible (e.g. App.init):
QeenSDK.configure(apiKey: "<your-key>", host: "https://us.i.posthog.com", debug: false)

QeenSDK.identify(userId: "user_42", traits: ["email": "a@b.com"])
QeenSDK.track("Add To Cart", properties: ["product_id": "SKU-1001"])
QeenSDK.screen("Product")
QeenSDK.flush()
QeenSDK.reset()

// Forward every inbound deep link / universal link:
//   SwiftUI:  .onOpenURL { QeenSDK.handleDeepLink($0) }
//   UIKit:    AppDelegate application(_:open:options:) / SceneDelegate openURLContexts
QeenSDK.handleDeepLink(url)
```

`configure(debug:)` toggles `[QeenSDK]` console logging. Deep links are parsed for campaign
attribution — any `utm_*` param and any `*clid` click id (`gclid`, `fbclid`, `ttclid`, …) —
and first-touch and last-touch campaign params attach to every subsequent event. Every other
query param on the link is also captured on the `Deep Link Opened` event, so new marketing
params need no SDK update.

## What ships

A single self-contained `QeenSDK.xcframework` (iOS device + simulator). No transitive Swift
Package dependencies appear in your project.

## Releasing (maintainers)

The XCFramework is built from the SDK source repo:

```bash
cd QeenSDK && ./Scripts/build-xcframework.sh   # → dist/QeenSDK.xcframework
```

Then in this repo: replace `QeenSDK.xcframework`, commit, and tag:

```bash
git add QeenSDK.xcframework && git commit -m "QeenSDK x.y.z"
git tag x.y.z && git push && git push --tags
```

Consumers pick up the new version via SPM. (At scale, consider Git LFS for the binary, or a
public repo + GitHub-Release asset with `url:`+`checksum:`.)
