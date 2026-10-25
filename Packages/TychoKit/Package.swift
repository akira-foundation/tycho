// swift-tools-version: 6.2
import PackageDescription

let strict: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "TychoKit",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "TychoCore", targets: ["TychoCore"]),
        .library(name: "TychoDesign", targets: ["TychoDesign"]),
        .library(name: "TychoFeatures", targets: ["TychoFeatures"]),
    ],
    targets: [
        .target(name: "TychoCore", swiftSettings: strict),
        .target(name: "TychoDesign", swiftSettings: strict),
        .target(name: "TychoFeatures", dependencies: ["TychoCore", "TychoDesign"], swiftSettings: strict),
        .testTarget(name: "TychoCoreTests", dependencies: ["TychoCore"], swiftSettings: strict),
        .testTarget(name: "TychoDesignTests", dependencies: ["TychoDesign"], swiftSettings: strict),

        .testTarget(
            name: "TychoFeaturesTests",
            dependencies: ["TychoFeatures", "TychoCore", "TychoDesign"],
            swiftSettings: strict
        ),
    ]
)
