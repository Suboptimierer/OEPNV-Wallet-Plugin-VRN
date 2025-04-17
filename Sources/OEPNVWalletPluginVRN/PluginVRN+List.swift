//
//  PluginVRN+List.swift
//  OEPNV-Wallet-Plugin-VRN
//
//  Created by Jonas Sannewald on 06.04.25.
//

import Foundation
import OEPNVWalletPluginAPI

extension PluginVRN {
    
    func list(auth cookie: String, using client: OEPNVWalletClient) async throws -> ListData {
        
        struct ListRequestBody: Encodable {
            let ListOrdersTimeFilterMask = 5
            let ListOrdersTicketFilterMask = 15
        }
        
        struct ListResponseBody: Decodable {
            let Orders: [Order]?
            let Error: Error?
            
            struct Order: Decodable {
                let Id: Int
                let Price: Double
                let BookingDate: String
                let Tickets: [Ticket]
                
                struct Ticket: Decodable {
                    let Id: Int
                    let TicketId: String
                    let TicketName: String
                    let ProductNumber: String
                    let ValidFrom: String
                    let ValidTo: String
                    let Price: Double
                    let Details: [Detail]
                    
                    struct Detail: Decodable {
                        let Holder: String
                        let Gender: String
                        let Dob: String
                    }
                }
            }
            
            struct Error: Decodable {
                let Subject: String
                let Message: String
                let MessageId: Int
            }
        }
        
        let listRequestBody = ListRequestBody()
        let listRequestBodyJSON = try JSONEncoder().encode(listRequestBody)
        
        let clientRequest = OEPNVWalletClientRequest(
            method: .post,
            headers: [
                (name: "content-type", value: "application/json"),
                (name: "cookie", value: cookie)
            ],
            url: "https://shop.myvrn.de/TicketShop/Shop/ListOrdersV2",
            body: listRequestBodyJSON
        )
        
        let clientResponse = try await client.send(request: clientRequest)
        
        guard let listResponseBody = clientResponse.body else {
            throw OEPNVWalletPluginError.parsingFailed(description: "Kein HTTP-Body vorhanden.")
        }
        
        let listResponseBodyJSON = try JSONDecoder().decode(ListResponseBody.self, from: listResponseBody)
        
        guard listResponseBodyJSON.Error == nil else {
            throw OEPNVWalletPluginError.endpointFailed(description: "\(listResponseBodyJSON.Error!.Subject): \(listResponseBodyJSON.Error!.Message)")
        }
        
        var tickets = [ListData.Ticket]()
        let dateFormatter = ISO8601DateFormatter()
        for order in listResponseBodyJSON.Orders ?? [] {
            for ticket in order.Tickets {
                for detail in ticket.Details {
                    
                    guard let validFrom = dateFormatter.date(from: ticket.ValidFrom),
                          let validUntil = dateFormatter.date(from: ticket.ValidTo),
                          let birthday = dateFormatter.date(from: detail.Dob) else {
                        throw OEPNVWalletPluginError.parsingFailed(description: "ValidFrom (\(ticket.ValidFrom)), ValidTo (\(ticket.ValidTo)), Dob (\(detail.Dob)) konnte nicht in Date umgewandelt werden.")
                    }
                    
                    let newTicket = ListData.Ticket(
                        id: ticket.Id,
                        type: ticket.TicketName,
                        validFrom: validFrom,
                        validUntil: validUntil,
                        price: ticket.Price,
                        holder: detail.Holder,
                        holderGender: detail.Gender,
                        holderBirthday: birthday
                    )
                    tickets.append(newTicket)
                    
                }
            }
        }
        
        return ListData(tickets: tickets)
        
    }
    
}
