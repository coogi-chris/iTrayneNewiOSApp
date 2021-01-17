//
//  Trainer.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase



struct Trainer: Codable, Identifiable, Hashable {
    var id: String? = nil
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var birthday: String = ""
    var avatarURL: String = ""
    var city: String = ""
    var location: GeoPoint? = nil
    var bio:String = ""
    var hourlyPrice:Int = 0
    var isOnline:Bool = false
    
    enum CodingKeys:String, CodingKey {
        case id = "uid"
        case isOnline = "isOnline"
        case firstName = "first_name"
        case lastName = "last_name"
        case phone = "phone"
        case bio = "bio"
        case city = "city"
        case birthday = "dob"
        case avatarURL = "avatarURL"
        case hourlyPrice = "hourlyPrice"
    }
}

struct Appointment2: Codable, Hashable, Identifiable {
    var id:String?
    var chargeID:String = ""
    var trainer:DocumentReference
    var location:DocumentReference
    var canceled:Bool = false
    var created:Timestamp?
    var arriveAt:Timestamp?
    var pending:Bool = true
    var gender:String = ""
    var productID:String?
    var priceID:String?
}

struct Checkout {
    var type:String = ""
    var length:String = ""
    var gender:String = ""
    var productID:String = ""
    var priceID:String = ""
    var arriveAt:Timestamp?
}


extension Trainer {
    
//    static func GetMockData() -> [Trainer] {
//        var trainers:[Trainer] = []
//
//        trainers = [
//            Trainer(id: "1234", firstName: "Christopher", lastName: "Kendrick", phone: "3233303083", birthday: "07301988", profileURL: "google.com", location: GeoPoint(latitude: 34.20222829179181, longitude: -118.22291040257689))
//        ]
//
//        return trainers
//    }
    
}




