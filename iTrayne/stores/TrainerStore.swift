//
//  TrainerProfileStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 5/3/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

class TrainerStore: ObservableObject {
    var trainerCollectionRef:CollectionReference = db.collection("trainers")
    var onlineTrainersCollectionRef:CollectionReference = db.collection("online_trainers")
    
    func getTrainers(success:(([Trainer])->Void)? = nil, error:((Error)->Void)? = nil) {
        self.trainerCollectionRef
        .whereField("isOnline", isEqualTo: true)
            .addSnapshotListener { querySnapshot, err in
                
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(err)")
                return
            }
            var trainers:[Trainer] = []
            documents.forEach { document in
                do {
                    let trainer = try document.data(as: Trainer.self)
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
    
    func getTrainerById(id:String, success:((Profile)->Void)? = nil, error:((Error)->Void)? = nil) {
        self.trainerCollectionRef.document(id)
            .addSnapshotListener { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                
                do {
                    let trainer = try document.data(as: Profile.self)
                    
                    if var trainer = trainer, let success = success {
                        trainer.id = document.documentID
                            success(trainer)
                    }
                }catch {
                    print(error)
                }
                
        }
    }
    
}
