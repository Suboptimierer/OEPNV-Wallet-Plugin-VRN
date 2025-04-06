//
//  ListData.swift
//  OEPNV-Wallet-Plugin-VRN
//
//  Created by Jonas Sannewald on 06.04.25.
//

import Foundation

struct ListData {
    let tickets: [Ticket]
    
    struct Ticket {
        let id: Int
        let type: String
        let validFrom: Date
        let validUntil: Date
        let price: Double
        let holder: String
        let holderGender: String
        let holderBirthday: Date
    }
}
