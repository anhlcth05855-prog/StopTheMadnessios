// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StopTheMadnessPro",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "StopTheMadnessCore",
            targets: ["StopTheMadnessCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StopTheMadnessCore",
            dependencies: [],
            path: "StopTheMadnessPro/Core"
        ),
        .testTarget(
            name: "StopTheMadnessProTests",
            dependencies: ["StopTheMadnessCore"],
            path: "StopTheMadnessProTests"
        )
    ]
)

