# QeenSDK (iOS)

Qeen's mobile analytics SDK for iOS, shipped as a binary XCFramework. Provider-agnostic
public API; the analytics engine is an internal implementation detail.

> Public distribution — **no GitHub account or sign-in required** to fetch the package.
> Your `host` + API key are shared privately (tech@qeen.ai).

## Install (Swift Package Manager)

**Xcode:** File ▸ Add Package Dependencies… → enter:

```
https://github.com/fodoole/qeen-mobile-sdk-ios.git
```

Pick a version (e.g. **Up to Next Major** from `1.4.0`) and add the **Qeen** library to your app target.

**Or in `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/fodoole/qeen-mobile-sdk-ios.git", from: "1.4.0"),
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "Qeen", package: "qeen-mobile-sdk-ios"),
    ]),
]
```

Requirements: iOS 15+, Xcode 16+.

> **Import name (since 1.3.0):** the module is `Qeen` — write `import Qeen`. The API namespace
> is unchanged: you still call `QeenSDK.configure`, `QeenSDK.track`, etc. Upgrading from 1.2.0 is a
> one-line change: `import QeenSDK` → `import Qeen`.

## Usage

```swift
import Qeen

// Once, as early as possible (e.g. App.init):
QeenSDK.configure(apiKey: "<your-key>", host: "<your-host>", debug: false)

QeenSDK.identify(userId: "user_42", traits: ["email": "a@b.com"])

// Freeform events (unchanged):
QeenSDK.track("Add To Cart", properties: ["product_id": "SKU-1001"])

// Typed standard events (new in 1.3.0) — type-safe, correct wire keys:
QeenSDK.productViewed(item: QeenSDK.LineItem(productId: "SKU-1001", unitPrice: .usd(39.99)))
QeenSDK.addToCart(cartId: cartId,
                  item: QeenSDK.LineItem(productId: "SKU-1001", quantity: 1, unitPrice: .usd(39.99)))
QeenSDK.orderCompleted(orderId: "1001", cartId: cartId, value: .usd(79.98),
                       items: [QeenSDK.LineItem(productId: "SKU-1001", unitPrice: .usd(39.99))])
// Or build the event value and pass it to track:
QeenSDK.track(.signedIn(method: "email"))

QeenSDK.screen("Product")
QeenSDK.flush()
QeenSDK.reset()

// Forward every inbound deep link / universal link:
//   SwiftUI:  .onOpenURL { QeenSDK.handleDeepLink($0) }
//   UIKit:    AppDelegate application(_:open:options:) / SceneDelegate openURLContexts
QeenSDK.handleDeepLink(url)
```

`configure(debug:)` toggles `[QeenSDK]` console logging. Deep links are parsed for campaign
attribution — any `utm_*` param and any `*clid` click id (`gclid`, `fbclid`, `ttclid`, …) — and
every query param on the link is captured on the `Deep Link Opened` event, so new marketing
params need no SDK update. Attribution is derived server-side by Qeen.

## Typed events

The typed surface lives under the `QeenSDK` namespace: `QeenSDK.QeenEvent`, `QeenSDK.LineItem`,
`QeenSDK.Money`, `QeenSDK.Currency`. Every monetary amount is a `Money` (an amount always carries a
currency); product lines are always `LineItem`. Helpers exist for each standard event
(`productViewed`, `addToCart`, `cartUpdated`, `checkoutStarted`, `orderCompleted`, `orderRefunded`,
`signedIn`, `signedUp`), or pass a `QeenSDK.QeenEvent` to `QeenSDK.track(_:)`.

## What ships

A single self-contained `Qeen.xcframework` (iOS device + simulator). No transitive Swift
Package dependencies appear in your project.

## Releasing (maintainers)

The XCFramework is built from the SDK source repo:

```bash
cd QeenSDK && ./Scripts/build-xcframework.sh   # → dist/Qeen.xcframework
```

Then in this repo: replace `Qeen.xcframework`, commit, and tag:

```bash
git add Qeen.xcframework && git commit -m "QeenSDK x.y.z"
git tag x.y.z && git push && git push --tags
```

Consumers pick up the new version via SPM.
