// swift-tools-version: 5.9
import PackageDescription

// QeenSDK — binary distribution.
//
// The compiled XCFramework is committed in this repo and referenced by a path-based
// binaryTarget, so consumers just add the package — the repo is public, no account needed.
//
// PostHog is baked INTO the framework and hidden: there is no `posthog-ios`
// dependency here and no importable PostHog module.
//
// NAMING (since 1.3.0): the module/product is `Qeen` — clients write `import Qeen`.
// The public namespace type is still `QeenSDK` (`QeenSDK.configure`, `QeenSDK.track`, …).
// The two names must differ: this binary ships a library-evolution `.swiftinterface`,
// and a module and type both named `QeenSDK` would make any signature that references
// an SDK-defined type (Money/LineItem/QeenEvent) unresolvable on the client.
let package = Package(
    name: "Qeen",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Qeen", targets: ["Qeen"]),
    ],
    targets: [
        .binaryTarget(name: "Qeen", path: "Qeen.xcframework"),
    ]
)
