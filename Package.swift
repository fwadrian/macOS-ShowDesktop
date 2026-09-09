// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShowDesktop",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ShowDesktop",
            path: "Sources/ShowDesktop"
        ),
        .testTarget(
            name: "ShowDesktopTests",
            dependencies: ["ShowDesktop"],
            path: "Tests/ShowDesktopTests"
        )
    ]
)
