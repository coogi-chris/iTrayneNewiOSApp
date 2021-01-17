//
//  PlaceStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 5/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

class PlacesStore:ObservableObject {
    
    private var placesCollectionRef:CollectionReference = db.collection("locations")
    
    func getPlaceById(id:String, success:((Location)->Void)? = nil, error:((Error)->Void)? = nil) {
        self.placesCollectionRef.document(id)
            .addSnapshotListener { documentSnapshot, err in
                guard let document = documentSnapshot else {
                    if let err = err, let error = error {
                        error(err)
                    }
                    return
                }
                let _ = document.metadata.hasPendingWrites ? "Local" : "Server"
                do {
                    let location = try document.data(as: Location.self)
                    if let location = location, let success = success {
                            success(location)
                    }
                }catch {
                    print(error)
                }
        }
    }
    
    func updateUserCurrentLocation(userId:String, location:Location) {
        
        
        guard let _location = location.location else {
            print("No cordinates")
            return
        }
        
        self.placesCollectionRef.document(userId).setData([
            "userId":userId,
            "location":_location
        ])
    }
}

