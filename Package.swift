// swift-tools-version: 5.9
import PackageDescription

// QeenSDK — binary distribution.
//
// The compiled XCFramework is committed in this (private) repo and referenced by
// a path-based binaryTarget, so consumers just add the package — SPM fetches the
// binary through their normal git authentication, no .netrc needed.
//
// PostHog is baked INTO QeenSDK.xcframework and hidden: there is no `posthog-ios`
// dependency here and no importable PostHog module.
//
// (If this repo ever goes public, switch to a GitHub-Release asset with
//  `.binaryTarget(name:url:checksum:)` to keep the git repo small.)
let package = Package(
    name: "QeenSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "QeenSDK", targets: ["QeenSDK"]),
    ],
    targets: [
        .binaryTarget(name: "QeenSDK", path: "QeenSDK.xcframework"),
    ]
)
