//
//  PluginVRN+Logout.swift
//  OEPNV-Wallet-Plugin-VRN
//
//  Created by Jonas Sannewald on 06.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginVRN {
    
    func logout(auth cookie: String, using client: OEPNVWalletClient) async throws {
        
        struct LogoutRequestBody: Encodable {}
        
        let logoutRequestBody = LogoutRequestBody()
        let logoutRequestBodyJSON = try JSONEncoder().encode(logoutRequestBody)
        
        let clientRequest = OEPNVWalletClientRequest(
            method: .post,
            headers: [
                (name: "content-type", value: "application/json"),
                (name: "cookie", value: cookie)
            ],
            url: "https://shop.myvrn.de/Identity/Authentication/SignOut",
            body: logoutRequestBodyJSON,
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard clientResponse.status == 204 else {
            throw OEPNVWalletPluginError.endpointFailed(description: "Logout nicht erfolgreich.")
        }
        
    }
    
}
