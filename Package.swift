// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OEPNV-Wallet-Plugin-VRN",
    products: [
        .library(name: "OEPNVWalletPluginVRN", targets: ["OEPNVWalletPluginVRN"]),
    ],
    dependencies: [
        .package(url: "../OEPNV-Wallet-Plugin-API", branch: "main"),
    ],
    targets: [
        .target(name: "OEPNVWalletPluginVRN", dependencies: [
            .product(name: "OEPNVWalletPluginAPI", package: "OEPNV-Wallet-Plugin-API")
        ]),
        .testTarget(name: "OEPNVWalletPluginVRNTests", dependencies: ["OEPNVWalletPluginVRN"]),
    ]
)
