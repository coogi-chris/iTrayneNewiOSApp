//
//  CardStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions


class CardStore:ObservableObject {
    
    lazy var functions = Functions.functions()
    
    func getAllCards(success:(([Card])->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getCards").call() { (result, err) in
            //print(result?.data)
            guard let err = err as NSError? else {
                if let res = result {
                    if let responseDic = res.data as? [String:Any]{
                        let data = responseDic["data"]
                        if let cardArr = data as? NSArray {
                            var cards:[Card] = []
                            for card in cardArr {
                                let newCard = card as! [String:Any]
                                let card:Card = self.createCardObj(data: newCard)
                                cards.append(card)
                            }
                            if let success = success {
                                success(cards)
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
    
    func createCardObj(data:[String:Any]) -> Card {
        let id = data["id"] as! String
        let brand = data["brand"] as! String
        let last4 = data["last4"] as! String
        let exp_month = data["exp_month"] as! Int
        let exp_year = data["exp_year"] as! Int
        let cvc_check = data["cvc_check"] as! String
        let country = data["country"] as! String
        let customer = data["customer"] as! String
        let funding = data["funding"] as! String
        return Card(id: id, last4: last4, exp_month: exp_month.description, exp_year: exp_year.description, brand: brand, country: country, funding: funding, customer: customer)
    }
    
    func createConfirmObj(data:[String:Any]) -> Confirmation {
        let id = data["id"] as! String
        let object = data["object"] as! String
        let deleted = data["deleted"] as! Bool
        return Confirmation(id: id, object: object, deleted: deleted)
    }
    
    func getCardByID(cardId:String, success:((Card)->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getCardByID").call(
            ["id":cardId]
        ) { (result, err) in
            guard let err = err as NSError? else {
                let data = self.responseDic(result: result)
                if let data = data {
                    let card = self.createCardObj(data: data)
                    if let success = success {
                        success(card)
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
    
    func deleteCardByID(cardId:String, success:((Confirmation)->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("deleteCardById").call(
            ["id":cardId]
        ) { (result, err) in
            guard let err = err as NSError? else {
                let data = self.responseDic(result: result)
                if let data = data {
                    let confirm = self.createConfirmObj(data: data)
                    if let success = success {
                        success(confirm)
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
    
    private func responseDic(result:HTTPSCallableResult? = nil) -> [String:Any]? {
          if let res = result {
              if let responseDic = res.data as? [String:Any]{
                  return responseDic
              }
          }
        
        return nil
    }
    
    func updateCard(cardId:String, card:Card, success:((Card)->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("updateCardById").call(
            ["id":cardId, "card":["exp_month":card.exp_month, "exp_year":card.exp_year] ]
        ) { (result, err) in
            guard let err = err as NSError? else {
                let data = self.responseDic(result: result)
                if let data = data {
                    let card = self.createCardObj(data: data)
                    if let success = success {
                        success(card)
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
    
    func createCard(card:Card, success:(()->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("addCard").call(
            ["number":card.number, "exp_month":card.exp_month, "exp_year":card.exp_year, "cvc":card.cvc]
        ) { (result, err) in
          print(err)
            guard let err = err as NSError? else {
                if let success = success {
                    success()
                }
            return
          }
        if err.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: err.code)
          let message = err.localizedDescription
          let _ = err.userInfo[FunctionsErrorDetailsKey]
            if let error = error {
                error(message)
            }
        }
        }
    }
    
    func append(card:CardToken) {
        //self.cards.append(card)
    }
    
}
