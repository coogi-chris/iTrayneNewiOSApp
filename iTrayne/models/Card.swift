//
//  Card.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

struct AllCardsResponse: Codable{
    var data:[Card]
    var hasMore:Int = 0
    var url:String
}

struct Card: Codable, Hashable, Identifiable {
    var id:String = ""
    var last4:String = ""
    var number:String = ""
    var cvc:String = ""
    var exp_month:String = ""
    var exp_year:String = ""
    var brand:String = ""
    var country:String = ""
    var funding:String = ""
    var customer:String = ""
    var address_line:String?
    var address_line2:String?
    var address_city:String?
    var address_state:String?
    var address_zip:String?
}


struct Confirmation {
    var id:String = ""
    var object:String = ""
    var deleted:Bool
}

struct CardToken: Codable {
    var number:String
    var exp_month:String
    var exp_year:String
    var cvc:String
}


// MARK: - Welcome
struct Charge:Codable {
    let id, object: String
    let amount, amountRefunded: Int
    var refunded: Bool
    let captured: Bool
    let created: Int
    let currency, customer, welcomeDescription: String
    let payment_method:String
    let paymentMethodDetails: PaymentMethodDetails
}


struct PaymentMethodDetails: Codable {
    let card: Card
    let type: String
}


struct Refund: Codable {
    let id: String = ""
    let amount: Int? = nil
    let charge: String
    let status: String
    
    enum CodingKeys:String, CodingKey {
        case id
        case amount
        case charge
        case status
    }
    
}

struct Metadata {
}
