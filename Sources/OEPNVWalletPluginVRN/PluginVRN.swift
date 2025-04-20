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
        associationSpecialNotice: "Die VRN verwendet \"Benutzername\" und \"E-Mail-Adresse\" synonym. Trage als Benutzernamen also einfach deine E-Mail-Adresse ein.",
        associationAuthURLs: [
            URL(string: "https://shop.myvrn.de/app/login")!,
            URL(string: "https://apps.apple.com/de/app/myvrn/id405436716")!
        ],
        associationAuthType: .usernamePassword,
        supportedTickets: ["Deutschlandticket"]
    )
    
    public let design = OEPNVWalletPluginDesign(
        backgroundColor: .init(red: 255, green: 255, blue: 255),
        headlineColor: .init(red: 1, green: 152, blue: 216),
        textColor: .init(red: 1, green: 47, blue: 90),
        associationIcon1x: try! Data(contentsOf: Bundle.module.url(forResource: "icon", withExtension: "png")!),
        associationIcon2x: try! Data(contentsOf: Bundle.module.url(forResource: "icon@2x", withExtension: "png")!),
        associationIcon3x: try! Data(contentsOf: Bundle.module.url(forResource: "icon@3x", withExtension: "png")!),
        associationLogo1x: try! Data(contentsOf: Bundle.module.url(forResource: "logo", withExtension: "png")!),
        associationLogo2x: try! Data(contentsOf: Bundle.module.url(forResource: "logo@2x", withExtension: "png")!),
        associationLogo3x: try! Data(contentsOf: Bundle.module.url(forResource: "logo@3x", withExtension: "png")!)
    )
    
    public func testAuthentication(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws {
        
        guard case let .usernamePassword(username, password) = credentials else {
            throw OEPNVWalletPluginError.internalFailed(description: "Fehlerhafte Credentials übermittelt.")
        }
        
        do {
            let loginData = try await login(with: username, and: password, using: client)
            
            try await logout(auth: loginData.cookie, using: client)
        } catch let error as OEPNVWalletPluginError {
            throw error
        } catch {
            throw OEPNVWalletPluginError.underlyingFailed(description: error.localizedDescription)
        }
        
    }
    
    public func fetchTickets(with credentials: OEPNVWalletPluginAPI.OEPNVWalletPluginAuthCredentials, using client: OEPNVWalletPluginAPI.OEPNVWalletClient) async throws -> [OEPNVWalletPluginAPI.OEPNVWalletPluginTicket] {
        
        guard case let .usernamePassword(username, password) = credentials else {
            throw OEPNVWalletPluginError.internalFailed(description: "Fehlerhafte Credentials übermittelt.")
        }
        
        do {
            let loginData = try await login(with: username, and: password, using: client)
            let listData = try await list(auth: loginData.cookie, using: client)
            
            var pluginTickets = [OEPNVWalletPluginAPI.OEPNVWalletPluginTicket]()
            for ticket in listData.tickets {
                let codeData = try await code(for: ticket.id, of: loginData.subjectId, auth: loginData.cookie, using: client)
                pluginTickets.append(OEPNVWalletPluginTicket(
                    id: String(ticket.id),
                    type: ticket.type,
                    validFrom: ticket.validFrom,
                    validUntil: ticket.validUntil,
                    price: ticket.price,
                    holder: ticket.holder,
                    holderBirthday: ticket.holderBirthday,
                    scanCode: .base64AztecCodeWithISO88591Message(codeData.scanCode)
                ))
            }
            
            try await logout(auth: loginData.cookie, using: client)
            
            return pluginTickets
        } catch let error as OEPNVWalletPluginError {
            throw error
        } catch {
            throw OEPNVWalletPluginError.underlyingFailed(description: error.localizedDescription)
        }
        
    }
    
}
