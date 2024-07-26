// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TQDMProgressBar",
    products: [
        .library(
            name: "TQDMProgressBar",
            targets: ["TQDMProgressBar"]
        ),
        .executable(
            name: "ProgressBarDemo",
            targets: ["ProgressBarDemo"]
        ),
    ],
    targets: [
        .target(
            name: "TQDMProgressBar"),
        .testTarget(
            name: "TQDMProgressBarTests",
            dependencies: ["TQDMProgressBar"]
        ),
        .executableTarget(
            name: "ProgressBarDemo",
            dependencies: ["TQDMProgressBar"]
        ),
    ]
)
