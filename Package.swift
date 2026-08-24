// swift-tools-version:5.9
// Open this folder directly in Xcode (File > Open… select prpht-iOS.xcodeproj
// OR open prpht/ as a Swift package playground). This manifest builds an iOS
// app target when using Xcode 16's "Swift Package for an App" flow; for a
// classic app shell use project.yml with XcodeGen.
import PackageDescription

let package = Package(
    name: "prpht",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "prpht", targets: ["prpht"])
    ],
    targets: [
        .target(
            name: "prpht",
            path: "prpht",
            resources: [
                .process("Resources"),
                .process("Assets.xcassets")
            ]
        )
    ]
)
