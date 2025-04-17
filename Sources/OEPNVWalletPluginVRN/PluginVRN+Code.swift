//
//  PluginVRN+Code.swift
//  OEPNV-Wallet-Plugin-VRN
//
//  Created by Jonas Sannewald on 06.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginVRN {
    
    func code(for ticketId: Int, of userId: String, auth cookie: String, using client: OEPNVWalletClient) async throws -> CodeData {
        
        struct CodeRequestBody: Encodable {
            let Id: Int
            let UserId: String
            let CommonOptions = [KeyValue()]
            
            struct KeyValue: Encodable {
                let Key = "TicketType"
                let Value = "1"
            }
        }
        
        struct CodeResponseBody: Decodable {
            let QrCode: String?
            let Error: Error?
            
            struct Error: Decodable {
                let Subject: String
                let Message: String
                let MessageId: Int
            }
        }
        
        let codeRequestBody = CodeRequestBody(Id: ticketId, UserId: userId)
        let codeRequestBodyJSON = try JSONEncoder().encode(codeRequestBody)
        
        let clientRequest = OEPNVWalletClientRequest(
            method: .post,
            headers: [
                (name: "content-type", value: "application/json"),
                (name: "cookie", value: cookie)
            ],
            url: "https://shop.myvrn.de/TicketShop/Shop/QRCode",
            body: codeRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let codeResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden.")
        }
        
        let codeResponseBodyJSON = try JSONDecoder().decode(CodeResponseBody.self, from: codeResponseBody)
        
        guard codeResponseBodyJSON.Error == nil else {
            throw OEPNVWalletPluginError.endpointFailed(description: "\(codeResponseBodyJSON.Error!.Subject): \(codeResponseBodyJSON.Error!.Message)")
        }
        
        guard let scanCode = codeResponseBodyJSON.QrCode else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein Scan-Code vorhanden: \(String(data: codeResponseBody, encoding: .utf8) ?? "Fehler")")
        }
        
        return CodeData(scanCode: scanCode)
        
    }
    
}
