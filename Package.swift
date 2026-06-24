// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Recall",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "RecallCore",
            path: "Recall",
            exclude: ["RecallApp.swift", "RecallAppDelegate.swift", "Views/"]
        ),
        .testTarget(
            name: "RecallTests",
            dependencies: ["RecallCore"],
            path: "Tests/RecallTests"
        )
    ]
)
