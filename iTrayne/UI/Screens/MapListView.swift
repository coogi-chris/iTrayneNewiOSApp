//
//  MapListView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase

enum ActiveSheet {
    case location, trainer, appointment
}

class MapListViewModel:ObservableObject {
    @Published var showAppointment:Bool = false
}

struct MapListView: View {
    //@ObservedObject var locationSearchService: LocationSearchService
    @Binding var isMapViewOn:Bool
    @State var annotations:[TrainerAnnotation] = []
    @State var centerCordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
    @EnvironmentObject var locationStore:LocationStore
    @ObservedObject var trainerStore:TrainerStore = TrainerStore()
    @State var trainers:[Profile] = []
    @State var showProfile:Bool = false
    @State var selectedTrainerID:String = ""
    @EnvironmentObject var checkout:CheckoutStore
    @Binding var openMenu:Bool
    @State var showAddressView:Bool = false
    @State var showSheet:Bool = false
    @State var activeSheet:ActiveSheet = .trainer
    @State var selectedAddy:UserAddress? = nil
    @State var addressStore:AddressStore = AddressStore()
    @EnvironmentObject var profileStore:ProfileStore
    @EnvironmentObject var session:SessionStore
    @State var profile:Profile? = nil
    @Binding var showAppointment:Bool
    @State var appointment:Appointment2? = nil
    
    func getTrainers() {
        
        #if TrainerApp
            
        #endif
        
        self.session.listen {
            if let user = self.session.session {
                self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                    self.profile = profile
                })
            }
        }
        
        self.profileStore.getBusinesses(success:{ trainers in
            self.trainers = trainers
        })
        
    }
    
    func dummyData() {
        self.locationStore.getUserCurrentCLLocation { (location) in
            var annotations:[TrainerAnnotation] = []
            let randLocations = randomLocations().getMockLocationsFor(location:location, itemCount:20)
            for location in randLocations {
                let annot = TrainerAnnotation()
                annot.profile = Profile(firstName: "sdvsd", lastName: "dsvsvs", phone: "ssdvdsv", birthday: Timestamp(), profileURL: "sdvsdv")
                let cordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                annot.coordinate = cordinate
                annotations.append(annot)
            }
            self.annotations = annotations
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action:{
                    withAnimation {
                        self.openMenu.toggle()
                    }
                    
                }, label:{
                   Image("menu").renderingMode(.original)
                })
               
                Spacer()
                    #if TrainerApp
                        if self.profile != nil {
                            if self.profile!.isOnline {
                                Button(action:{
                                    self.profile!.isOnline = false
                                    self.profileStore.updateOrCreateProfile(profile: self.profile!)
                                }, label:{
                                    Text("Go Offline")
                                         .padding(5)
                                        .foregroundColor(.white)
                                        .background(Color("green"))
                                       
                                    }).cornerRadius(5)
                                Spacer().frame(width:2)
                            }else{
                                Button(action:{
                                    self.profile!.isOnline = true
                                    self.profileStore.updateOrCreateProfile(profile: self.profile!)
                                }, label:{
                                    Text("Go Online")
                                         .padding(5)
                                        .foregroundColor(.white)
                                        .background(Color("green"))
                                       
                                    }).cornerRadius(5)
                                Spacer().frame(width:2)
                            }
                        }
                    #else
                        Button(action: {
                            self.activeSheet = .location
                            self.showSheet = true
                        }, label: {
                            VStack(spacing:0) {
                                Text("WORKOUT LOCATION").font(.system(size: 10)).foregroundColor(.green)
                                HStack {
                                    Text(self.selectedAddy == nil ? "Select Address" : self.selectedAddy?.address ?? "")
                                    .lineLimit(1)
                                        .foregroundColor(.white)
                                        .frame(width:150)
                                    Spacer().frame(width:10)
                                    Image("down-arrow").resizable(
                                    )
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width:14)
                                        .foregroundColor(.green)
                                }

                            }
                        })
                        Spacer()
                    #endif

                
                        }.padding(.horizontal)
            
            #if TrainerApp
             ScheduleListView(onClickCell: { appt in
                self.appointment = appt
                self.activeSheet = .appointment
                self.showSheet = true
            })
            #else
                Group {
                    if !self.isMapViewOn {
                        UserListView(trainers: self.$trainers, onTap: .constant({ trainerID in
                            self.selectedTrainerID = trainerID
                            self.activeSheet = .trainer
                            self.showSheet.toggle()
                        }), openMenu: self.$openMenu, showAddresses: self.$showSheet)
                    }else{
                        MapView(annotations: self.$annotations, centerCoordinate: self.$locationStore.centerCordinate, onTapPoint: { annotation in
                        })
                    }
                }
            #endif

        }
        .onAppear(perform: self.getTrainers)
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .trainer {
                ProfileView(trainerId: self.$selectedTrainerID, showProfile: self.$showSheet, showAppointment: self.$showAppointment).environmentObject(ProfileStore())
            }
            if self.activeSheet == .location {
                AddressListView(locationSearchService: locationSearchService, onSelect:{ addy in
                    self.selectedAddy?.address = addy.address ?? "No address"
                }).environmentObject(ProfileStore()).environmentObject(SessionStore())
            }
            if self.activeSheet == .appointment {
                AppointmentDetailView(appointmentId: .constant(self.appointment?.id ?? ""), showProfile: .constant(true), showAppointment:self.$showSheet)
                 
            }

        }
    }
}

//struct MapListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapListView()
//    }
//}
