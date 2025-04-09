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
        associationAuthType: OEPNVWalletPluginAuthType.usernamePassword,
        supportedTickets: ["Deutschlandticket"]
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
            throw OEPNVWalletPluginError.underlyingFailed(error: error)
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
                    scanCode: codeData.scanCode
                ))
            }
            
            try await logout(auth: loginData.cookie, using: client)
            
            return pluginTickets
        } catch let error as OEPNVWalletPluginError {
            throw error
        } catch {
            throw OEPNVWalletPluginError.underlyingFailed(error: error)
        }
        
    }
    
}
