//
//  AddressStore.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

struct UserAddress:Codable, Hashable {
    var id:String? = nil
    var location:GeoPoint? = nil
    var address:String? = nil
    var userID:String? = nil
}

class AddressStore:ObservableObject {
    
    let collectionRef = db.collection("addresses")
   
    func create(address:UserAddress, success:(()->Void)? = nil, error:((Error)->Void)? = nil) {
        do {
            try self.collectionRef.document().setData(from:address, merge: true, completion: { err in
                guard let err = err else {
                    if let success = success {
                        success()
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
            })
        }catch{
            print(error)
        }
    }
    
    func get(userId:String, success:(([UserAddress])->Void)? = nil) {
        self.collectionRef
        .whereField("userID", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, err in
                
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(err)")
                return
            }
            var trainers:[UserAddress] = []
            documents.forEach { document in
                do {
                    let trainer = try document.data(as: UserAddress.self)
                    if var trainer = trainer {
                        trainer.id = document.documentID
                        trainers.append(trainer)
                    }
                }catch {
                    print(error)
                }
            }
            if let success = success {
                success(trainers)
            }
        }
    }
    
    func getAdddressById(id:String, success:((UserAddress)->Void)? = nil, error:((Error)->Void)? = nil) {
        self.collectionRef.document(id)
            .addSnapshotListener { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                do {
                    let addy = try document.data(as: UserAddress.self)
                    if let success = success, let addy = addy{ success(addy) }
                }catch {
                    print(error)
                }
        }
    }
    
    
    
    
    
    func delete(documentID:String, error:((String)->Void)? = nil, success:@escaping (()->Void)) {
        self.collectionRef.document(documentID).delete(completion: { err in
            if let error = error {
                error(err?.localizedDescription ?? "")
            }else{
               success()
            }
            
        })
    }
    
}
