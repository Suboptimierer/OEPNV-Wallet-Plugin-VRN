//
//  PluginVRN.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 10.02.25.
//

import Foundation
import OEPNVWalletPluginAPI

public struct PluginVRN: OEPNVWalletPlugin {
    
    public init() {}
    
    public let information = OEPNVWalletPluginInformation(
        gitRepositoryURL: URL(string: "https://github.com/Suboptimierer/OEPNV-Wallet-Plugin-VRN")!,
        authorName: "Jonas Sannewald",
        authorURL: URL(string: "https://sannewald.com")!,
        associationName: "Verkehrsverbund Rhein-Neckar",
        associationAbbreviation: "VRN",
        associationSpecialNotice: nil,
        associationAuthURLs: [
            URL(string: "https://shop.myvrn.de/app/login")!,
            URL(string: "https://apps.apple.com/de/app/myvrn/id405436716")!
        ],
        associationAuthType: OEPNVWalletPluginAuthType.usernamePassword,
        supportedTickets: ["Deutschlandticket"]
    )
    
}

// TODO: Weitere Funktionalitäten über Extensions in separaten Files...
