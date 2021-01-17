//
//  ProductStore.swift
//  iTrayne_Trainer
//
//  Created by Christopher Kendrick on 7/8/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions

class ProductStore: ObservableObject {
    
    lazy var functions = Functions.functions()
    
    func getProducts(success:(([Product])->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getProducts").call() { (result, err) in
            guard let err = err as NSError? else {
                if let res = result {
                    if let responseDic = res.data as? [String:Any]{
                        let data = responseDic["data"]
                        if let array = data as? NSArray {
                            var products:[Product] = []
                            for item in array {
                                let item = item as! [String:Any]
                                let product = self.createProductObj(data: item)
                                products.append(product)
                            }
                            if let success = success {
                                success(products)
                            }
                        }
                    }
                }
            return
          }
            if err.domain == FunctionsErrorDomain {
              let _ = FunctionsErrorCode(rawValue: err.code)
              let message = err.localizedDescription
              let _ = err.userInfo[FunctionsErrorDetailsKey]
              //print(details, message, code)
                if let error = error {
                    error(message)
                }
            }
        }
    }
    
    func createProductObj(data:[String:Any]) -> Product {
        let id:String = data["id"] as! String
        let name:String = data["name"] as! String
        let description:String = data["description"] as? String ?? "No Description"
        return Product(id: id, name: name, description: description)
        
    }
    
    func getPrices(productId:String, success:(([Price])->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getPrices").call(["productID":productId]) { (result, err) in
            guard let err = err as NSError? else {
                if let res = result {
                    if let responseDic = res.data as? [String:Any]{
                        let data = responseDic["data"]
                        if let array = data as? NSArray {
                            var prices:[Price] = []
                            for item in array {
                                let item = item as! [String:Any]
                                let price:Price = self.priceObj(data: item)
                                prices.append(price)
                            }
                            if let success = success {
                                success(prices)
                            }
                        }
                    }
                }
            return
          }
            if err.domain == FunctionsErrorDomain {
              let _ = FunctionsErrorCode(rawValue: err.code)
              let message = err.localizedDescription
              let _ = err.userInfo[FunctionsErrorDetailsKey]
              //print(details, message, code)
                if let error = error {
                    error(message)
                }
            }
        }
    }
    
    func getPriceByID(id:String, success:((Price)->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getPriceByID").call(["priceID":id]) { (result, err) in
            guard let err = err as NSError? else {
                if let res = result {
                    if let responseDic = res.data as? [String:Any]{
                        let price:Price = self.priceObj(data: responseDic)
                        if let success = success {
                            success(price)
                        }
                    }
                }
            return
          }
            if err.domain == FunctionsErrorDomain {
              let _ = FunctionsErrorCode(rawValue: err.code)
              let message = err.localizedDescription
              let _ = err.userInfo[FunctionsErrorDetailsKey]
              //print(details, message, code)
                if let error = error {
                    error(message)
                }
            }
        }
    }
    
    func priceObj(data:[String:Any]) -> Price {
        let nickname:String = data["nickname"] as! String
        let id:String = data["id"] as! String
        let unitAmount:Int = data["unit_amount"] as! Int
        let unitAmountDecimal:String = data["unit_amount_decimal"] as! String
        return Price(id: id, nickname: nickname, unitAmount: unitAmount, unitAmountDecimal: unitAmountDecimal)
    }

}
