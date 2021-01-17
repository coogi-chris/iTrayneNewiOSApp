//
//  CheckoutStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 5/10/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import FirebaseFunctions
import Firebase

class CheckoutStore: ObservableObject {
    @Published var selectedCard:Card? = nil
    @Published var userId:String? = nil
    lazy var functions = Functions.functions()
    @Published var checkout:Checkout = Checkout()
    @Published var selectedPrices:[Price] = []
    
    func checkout(trainerID:String, cardId:String, type:String = "general", gender:String = "", success:(()->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("checkout").call(
            ["cardID":cardId, "trainerID":trainerID, "type":type, "gender":gender]
        ) { (result, err) in
            guard let err = err as NSError? else {
                if let success = success {
                    success()
                }
                return
          }
        if err.domain == FunctionsErrorDomain {
          let _ = FunctionsErrorCode(rawValue: err.code)
          let message = err.localizedDescription
          let _ = err.userInfo[FunctionsErrorDetailsKey]
            if let error = error {
                error(message)
            }
        }
        }
    }
    
    func createAppointment(productID:String, cardId:String, priceID:String, gender:String, arriveAt:String, success:(()->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("searchForTrainer").call(
            ["cardID":cardId, "productID":productID, "priceID":priceID, "gender":gender, "arriveAt":arriveAt]
        ) { (result, err) in

            guard let err = err as NSError? else {
                if let success = success {
                    //print(result?.data)
                    success()
                }
                return
          }
        if err.domain == FunctionsErrorDomain {
          let _ = FunctionsErrorCode(rawValue: err.code)
          let message = err.localizedDescription
          let _ = err.userInfo[FunctionsErrorDetailsKey]
            if let error = error {
                error(message)
            }
        }
        }
    }
    
}
