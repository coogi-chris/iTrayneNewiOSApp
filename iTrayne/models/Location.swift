//
//  Location.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation


struct Location: Codable, Hashable, Identifiable {
    var id:String? = nil
    var name:String = ""
    var street:String = ""
    var street2:String = ""
    var city:String = ""
    var state:String = ""
    var zip:String = ""
    var location: GeoPoint?
    
    enum CodingKeys:String, CodingKey {
        case id = "uid"
        case name
        case street
        case street2
        case city
        case state
        case zip
        case location
    }
}



struct onlineTrainer:Codable, Hashable, Identifiable {
    var id:String? = nil
    var trainer:Trainer?
    var location:Location?
}







