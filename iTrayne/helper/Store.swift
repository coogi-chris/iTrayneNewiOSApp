//
//  Store.swift
//  iTrayne_Trainer
//
//  Created by Chris on 6/1/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

protocol Storable {
    func listen()
}

class Store<T:Codable> : Storable {
    
    typealias Model = T
    var collectionRef:CollectionReference?
    
    init(collection:String) {
        self.collectionRef = db.collection(collection)
    }
    
    func listen() {
            if let collectionRef = self.collectionRef {
                collectionRef
                    .addSnapshotListener { querySnapshot, err in
                        
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(err)")
                        return
                    }
                    documents.forEach({ doc in
                        do {
                            print(doc.documentID)
                                print(doc.data())
                        }catch {
                                print(error)
                        }
                    })
                        
                }
            }

    }
    
}
