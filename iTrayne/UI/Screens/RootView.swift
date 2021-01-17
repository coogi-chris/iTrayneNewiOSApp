//
//  RootView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/24/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import SwiftLocation

struct RootView: View {
    
    @EnvironmentObject var session:SessionStore
    @EnvironmentObject var placeStore:PlacesStore
    @EnvironmentObject var profileStore:ProfileStore
    @State var loading:Bool = true
    @State var profile:Profile? = nil
    @State var locationRequest:LocationRequest? = nil
    
    func getUser() {        
        self.session.listen(callback: {
            self.loading = false
            
            guard let user = self.session.session else {
                print("No User")
                return
            }
            self.profileStore.getProfileByUserId(userId:user.uid, success: { profile in
                self.profile = profile
                self.getAppGPS(userId: user.uid)
            })
        })
    }
    
    func getAppGPS(userId:String) {
        
        if let profile = self.profile{
            if profile.isOnline {
                
                self.locationRequest = LocationManager.shared.locateFromGPS(.continous, accuracy: .city) { result in
          switch result {
            case .failure(let error):
              debugPrint("Received error: \(error)")
            case .success(let location):
                        let loc = Location(location: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                        self.placeStore.updateUserCurrentLocation(userId: userId, location: loc)
                    }
                }
            }else{
                self.locationRequest?.pause()
            }
        }
    }
    
    var body: some View {
        Group {
            ZStack(alignment:.topLeading) {
                if !self.loading {
                    if self.session.session != nil {
                        TabView().environmentObject(MapListViewModel())
                    }else {
                        LoginForm()
                    }
                }else{
                    LoadingView()
                }

            }
           
        }.onAppear(perform: getUser)
    }
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView().environmentObject(SessionStore())
//    }
//}
