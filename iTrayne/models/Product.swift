//
//  Product.swift
//  iTrayne_Trainer
//
//  Created by Christopher Kendrick on 7/8/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

struct Product {
    var id:String = ""
    var name:String = ""
    var description:String = ""
}

struct Price {
    var id:String = ""
    var nickname:String = ""
    var unitAmount:Int = 0
    var unitAmountDecimal:String = ""
    var selected:Bool = false
}
