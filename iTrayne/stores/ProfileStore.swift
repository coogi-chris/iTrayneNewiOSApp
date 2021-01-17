//
//  ProfileStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//



import Foundation
import Firebase
import SwiftUI
import FirebaseFirestoreSwift

class ProfileStore: HTTPErrorHandler, ObservableObject {
    @Published var profileRef:CollectionReference = db.collection("Profiles")
    @Published var profile:Profile? = nil
    
    func getBusinesses(success: (([Profile])->Void)? = nil ) {
        let q = self.profileRef
            .whereField("role", isEqualTo: "business")
            .whereField("isOnline", isEqualTo: true)
        q.addSnapshotListener { documentSnapshot, err in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching documents: \(err)")
                return
            }
            var trainers:[Profile] = []
            documents.forEach { document in
                do {
                    let trainer = try document.data(as: Profile.self)
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
    
    func getProfileByUserId(userId:String, success:((Profile?)->Void)? = nil, error:((Error)->Void)? = nil) {
        
        self.profileRef.document(userId)
            .addSnapshotListener { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                do {
                    let profile = try document.data(as: Profile.self)
                    if let profile = profile {
                        if let success = success{ success(profile) }
                    }else{
                         if let success = success{ success(nil) }
                    }
                }catch {
                    print(error)
                }
        }
    }
    
    func updateOrCreateProfile(profile:Profile, success:(()->Void)? = nil, error:((Error)->Void)? = nil) {

        do {
            let functions = Functions.functions()
            functions.httpsCallable("createUserProfile").call([
                "first_name":profile.firstName,
                "last_name":profile.lastName,
                "phone":profile.phone,
                "dob":profile.birthday.nanoseconds,
                "profileURL":profile.profileURL,
                "bio":profile.bio ?? "",
                "hourlyPrice":profile.hourlyPrice,
                "isOnline":profile.isOnline,
                "gender":profile.gender
            ]) { (result, err) in
                //print(result?.data, err?.localizedDescription)
                guard let err = err else {
                    if let success = success {
                        success()
                    }
                    return
                }
                if let error = error {
                    error(err)
                }
            }
        }catch{
            print(error)
        }
    }
}






