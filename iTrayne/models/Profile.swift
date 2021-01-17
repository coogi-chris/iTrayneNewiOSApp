//
//  Profile.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/4/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

protocol ProfileInfo {
    var id:String? { get set }
    var firstName:String{ get set }
    var lastName:String { get set }
    var phone:String { get set }
    var profileURL:String { get set }
}

struct Profile: Codable, Equatable, Hashable, ProfileInfo{
    var id: String?
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var birthday: Timestamp
    var profileURL: String = ""
    var defaultAddress:String?
    var gender:String = ""
    var bio:String?
    var hourlyPrice:Int = 0
    var isOnline:Bool = false
    
    enum CodingKeys:String, CodingKey {
        case id = "uid"
        case firstName = "first_name"
        case lastName = "last_name"
        case phone = "phone"
        case birthday = "dob"
        case profileURL = "profileURL"
        case defaultAddress = "defaultAddress"
        case bio = "bio"
        case isOnline = "isOnline"
        case hourlyPrice = "hourlyPrice"
        case gender = "gender"
    }
}



enum ProfileValidation:Error {
    case isEmpty(name:String)
}
