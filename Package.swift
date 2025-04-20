// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OEPNV-Wallet-Plugin-VRN",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "OEPNVWalletPluginVRN", targets: ["OEPNVWalletPluginVRN"]),
    ],
    dependencies: [
        // TODO: Vor Veröffentlichung branch entfernen
        .package(url: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-API.git", branch: "main"),
    ],
    targets: [
        .target(name: "OEPNVWalletPluginVRN", dependencies: [
            .product(name: "OEPNVWalletPluginAPI", package: "OEPNV-Wallet-Plugin-API")
        ], resources: [ .process("Resources") ]),
        .testTarget(name: "OEPNVWalletPluginVRNTests", dependencies: ["OEPNVWalletPluginVRN"]),
    ]
)
