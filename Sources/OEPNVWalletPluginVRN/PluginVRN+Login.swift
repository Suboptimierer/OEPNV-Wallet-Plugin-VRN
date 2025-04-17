//
//  PluginVRN+Login.swift
//  OEPNV-Wallet-Plugin-VRN
//
//  Created by Jonas Sannewald on 06.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginVRN {
    
    func login(with username: String, and password: String, using client: OEPNVWalletClient) async throws -> LoginData {
        
        struct LoginRequestBody: Encodable {
            let Name: String
            let Password: String
            let Client = "vrn"
            let Organization = "vrn"
            let RememberLogin = true
        }
        
        struct LoginResponseBody: Decodable {
            let Succeeded: Bool
            let TwoFactorProvider: Int
            let HasPwnedPassword: Bool
            let CredentialValidationFailed: Bool
            let SubjectId: String?
            let UserNotActivated: Bool
            let UserLocked: Bool
            let InvalidClient: Bool
            let InvalidOrganization: Bool
        }
        
        let loginRequestBody = LoginRequestBody(Name: username, Password: password)
        let loginRequestBodyJSON = try JSONEncoder().encode(loginRequestBody)
        
        let clientRequest = OEPNVWalletClientRequest(
            method: .post,
            headers: [
                (name: "content-type", value: "application/json")
            ],
            url: "https://shop.myvrn.de/Identity/Authentication/Login",
            body: loginRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let loginResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden: \(clientResponse.status), \(clientResponse.headers)")
        }
        
        let loginResponseBodyJSON = try JSONDecoder().decode(LoginResponseBody.self, from: loginResponseBody)
        
        guard loginResponseBodyJSON.Succeeded else {
            if loginResponseBodyJSON.CredentialValidationFailed {
                throw OEPNVWalletPluginError.authenticationFailed(description: "Fehlerhafte Anmeldedaten.")
            } else {
                throw OEPNVWalletPluginError.authenticationFailed(description: "UserNotActivated: \(loginResponseBodyJSON.UserNotActivated), UserLocked: \(loginResponseBodyJSON.UserLocked), InvalidClient: \(loginResponseBodyJSON.InvalidClient), InvalidOrganization: \(loginResponseBodyJSON.InvalidOrganization)")
            }
        }
        
        guard let subjectId = loginResponseBodyJSON.SubjectId else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Keine Subject-ID vorhanden: \(String(data: loginResponseBody, encoding: .utf8) ?? "Fehler")")
        }
        
        guard let cookie = clientResponse.headers.first(where: {
            $0.name == "Set-Cookie" && $0.value.contains("mentz.cookie=")}) else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein Session-Cookie vorhanden: \(String(data: loginResponseBody, encoding: .utf8) ?? "Fehler")")
        }
        
        return LoginData(subjectId: subjectId, cookie: cookie.value)
        
    }
    
}
