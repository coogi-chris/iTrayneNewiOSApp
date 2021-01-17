//
//  AppointmentStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 5/12/20.
//  Copyright © 2020 Chris. All rights reserved.
//
//  1. What job task would you want her to do?
//  2. 

import Foundation
import FirebaseFunctions
import Firebase
import SwiftDate

class AppointmentStore: ObservableObject {

    var appointmentRef:CollectionReference = db.collection("appointments")
    var profileRef:CollectionReference = db.collection("Profiles")
    lazy var functions = Functions.functions()
    
    func getAppointmentsByUserId(userId:String, appointmentListener:(([Appointment2])->Void)? = nil, error:((Error)->Void)? = nil) {
        let userDoc:DocumentReference = profileRef.document(userId)
        self.appointmentRef.whereField("userID", isEqualTo: userDoc)
            .addSnapshotListener { querySnapshot, err in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(err)")
                    return
                }
                var appts:[Appointment2] = []
                for document in documents {
                    do {
                        let appt = try document.data(as: Appointment2.self)
                        if var appt = appt {
                            appt.id = document.documentID
                            appts.append(appt)
                        }
                    }catch { print(error) }
                }
                if let appointmentListener = appointmentListener {
                    appointmentListener(appts)
                }
             }
    }
    
    func getCustomerOrders(userId:String, appointmentListener:(([Appointment2])->Void)? = nil, error:((Error)->Void)? = nil) {
        self.appointmentRef.whereField("customerUserID", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, err in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(err)")
                    return
                }
                var appts:[Appointment2] = []
                for document in documents {
                    do {
                        let appt = try document.data(as: Appointment2.self)
                        if var appt = appt {
                            appt.id = document.documentID
                            appts.append(appt)
                        }
                    }catch { print(error) }
                }
                if let appointmentListener = appointmentListener {
                    appointmentListener(appts)
                }
             }
    }
    func getBusinessOrders(userId:String, appointmentListener:(([Appointment2])->Void)? = nil, error:((Error)->Void)? = nil) {
        self.appointmentRef.whereField("businessUserID", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, err in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(err)")
                    return
                }
                var appts:[Appointment2] = []
                for document in documents {
                    do {
                        let appt = try document.data(as: Appointment2.self)
                        if var appt = appt {
                            appt.id = document.documentID
                            appts.append(appt)
                        }
                    }catch { print(error) }
                }
                if let appointmentListener = appointmentListener {
                    appointmentListener(appts)
                }
             }
    }
    
    func getAppointmentByID(appointmentId:String, success:((Appointment2)->Void)? = nil, error:((Error)->Void)? = nil) {
        self.appointmentRef.document(appointmentId)
            .addSnapshotListener { documentSnapshot, err in
                
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                do {
                    let appt = try document.data(as: Appointment2.self)
                    if var appt = appt {
                        appt.id = document.documentID
                        if let success = success {
                            success(appt)
                        }
                    }
                }catch { print(error) }
                    
        }
    }
    
    func cancel(appointmentID:String, error:((String)->Void)? = nil, success:(()->Void)? = nil) {
        functions.httpsCallable("cancelAppointment").call(
            ["appointmentID":appointmentID]
        ) { (result, err) in

            guard let err = err as NSError? else {
                if let res = result, let success = success {
                    let resDic = res.data as! [String:Any]
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
    
    func getCharge(chargeID:String, success:((Charge)->Void)? = nil, error:((String)->Void)? = nil) {
        functions.httpsCallable("getCharge").call(
            ["chargeID":chargeID]
        ) { (result, err) in
            guard let err = err as NSError? else {
                
                if let res = result, let success = success {
                    let resDic = res.data as! [String:Any]
                    let charge = self.getCharge(charge: resDic)
                    success(charge)
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
    
    func getCharge(charge:[String:Any]) -> Charge {
        let id = charge["id"] as! String
        let amount = charge["amount"] as! Int
        let amountRefunded = charge["amount_refunded"] as! Int
        let refunded = charge["refunded"] as! Bool
        let captured = charge["captured"] as! Bool
        let created = charge["created"] as! Int
        let paymentDetails = charge["payment_method_details"] as! [String:Any]
        let cardDetails = paymentDetails["card"] as! [String:Any]
        let card = self.createCardObj(data: cardDetails)
        let details = PaymentMethodDetails(card: card, type: "")
        let charge = Charge(id:id, object: "", amount:amount, amountRefunded:amountRefunded, refunded:refunded, captured:captured, created:created, currency: "USD", customer: "", welcomeDescription: "", payment_method: "", paymentMethodDetails: details)
        return charge
    }
    
    func createCardObj(data:[String:Any]) -> Card {
        let id = data["id"] as? String ?? ""
        let brand = data["brand"] as! String
        let last4 = data["last4"] as! String
        let exp_month = data["exp_month"] as! Int
        let exp_year = data["exp_year"] as! Int
        let cvc_check = data["cvc_check"] as? String ?? ""
        let country = data["country"] as? String ?? ""
        let customer = data["customer"] as? String ?? ""
        let funding = data["funding"] as? String ?? ""
        return Card(id: id, last4: last4, exp_month: exp_month.description, exp_year: exp_year.description, brand: brand, country: country, funding: funding, customer: customer)
    }
    
    func getTrainer(documentReference:DocumentReference, trainer: @escaping ((Trainer)->Void)) {
            documentReference.getDocument(completion: { (doc, err) in
                
                guard let document = doc else{
                    print(err)
                    return
                }
                
                do {
                    let model = try document.data(as: Trainer.self)
                    if let model = model {
                        trainer(model)
                    }
                }catch {
                    print(error)
                }
                
            })
        }
    
    func getLocation(documentReference:DocumentReference, location: @escaping ((Location)->Void)) {
            documentReference.getDocument(completion: { (doc, err) in
                
                guard let document = doc else{
                    print(err)
                    return
                }
                
                do {
                    let model = try document.data(as: Location.self)
                    if let model = model {
                        location(model)
                    }
                }catch {
                    print(error)
                }
                
            })
        }
    
    }
    

    

