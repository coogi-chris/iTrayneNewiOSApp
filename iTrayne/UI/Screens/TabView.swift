//
//  TabView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase

struct TabView: View {
   
    @State var isMapViewOn:Bool = false
    @State var isMenuOpen:Bool = false
    @EnvironmentObject var session:SessionStore
    @EnvironmentObject var profileStore:ProfileStore
    @EnvironmentObject var locationStore:LocationStore
    @State var menuItems:[MenuItem] = []
    @State var tabItems:[TabItem] = []
    @State var loading:Bool = true
    @State var currentSearchAddress:String = "Location..."
    @State var showBookForm:Bool = false
    @State var showAppointment:Bool = false
    @State var showAddresses:Bool = false
    @State var appp:Store<Appointment2> = Store(collection: "appointments")
    @State var showOrder:Bool = false
    @EnvironmentObject var mapmvv:MapListViewModel
    @State var profile:Profile? = nil
    
    func onAppear() {

        self.appp.listen()
        self.getAddress()
        self.initTabView()
        self.initData()
    }
    
    func getAddress() {
        self.locationStore.getCurrentUserLocationAddress(completion: { address in
            self.currentSearchAddress = address
        })
    }
    
    func initData() {
        
        
        
        self.session.listen(callback: {
            if let user = self.session.session {
                
                self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                    if let profile = profile {
                        self.profile = profile
                        self.addMenuItems()
                        self.addAvatarToMenu(profile: profile)
                        self.loading = false
                        
                    }else{
                        self.loading = false
                    }
                    
                    
                    
                }, error: { error in
                    self.loading = false
                })
            }
        })
    }
    
    //InputSearch(value: $currentSearchAddress, isOn: $isMapViewOn);
    func initTabView() {
        
        #if TrainerApp
        self.tabItems = [
            TabItem(name: "YOUR APPOINTMENTS", view: AnyView(VStack(spacing:0){
                MapListView(isMapViewOn: $isMapViewOn, openMenu: self.$isMenuOpen, showAppointment: self.$showOrder)
            }), onTap: {}, iconImageName: "gym")
        ]
        #else
            self.tabItems = [
                TabItem(name: "TRAIN NOW", view: AnyView(VStack(spacing:0){
                    MapListView(isMapViewOn: $isMapViewOn, openMenu: self.$isMenuOpen, showAppointment: self.$showOrder)
                }), onTap: {}, iconImageName: "gym"),
                TabItem(name: "Book", onTap: {
                    self.showBookForm = true
                }, buttonLabel: AnyView(centerButton().offset(x:0,y:5)), dontChangeTabs:true),
                TabItem(name: "WORKOUTS", view: AnyView(ScheduleListView()), onTap: {}, iconImageName: "calendar")
            ]
        #endif
        

    }
    
    func centerButton() -> some View {
         Button(action: {
            self.showBookForm = true
         }, label: {
                   Text("Book Trainer")
                    .frame(width:100, height: 50)
                    .padding(.horizontal,9)
                    .background(Color("green"))
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .cornerRadius(10)
                    
            })
    }
    
    var body: some View {
        NavigationView {
            Group {
                ZStack{
                    if self.loading {
                        LoadingView()
                    }else{
                        if self.profile != nil {
                                NavigationView {
                                    ZStack(alignment:.topLeading) {
                                        Color.black.edgesIgnoringSafeArea(.all)
                                        VStack(alignment:.leading, spacing:0) {
                                            TabGroupView(tabs: $tabItems)
                                            Spacer()
                                        }
                                        MenuView(menuItems: $menuItems, isOpen: $isMenuOpen)
                                    }.navigationBarTitle("")
                                     .navigationBarHidden(true)
                                }.sheet(isPresented: self.$showAppointment) {
                                    AppointmentDetailView(appointmentId: .constant("1234"), showProfile: .constant(true), showAppointment:self.$showAppointment)
                                }
                            }else{
                                ProfileFormView()
                            }
                    }
                } 

                }.navigationBarHidden(true).navigationBarTitle("")
                .onAppear(perform: onAppear)

        }

    }
    
    func addMenuItems(){
        self.menuItems.removeAll()
        menuItems.append(contentsOf: [
            MenuItem(name: "Settings", isNavigationLink:true, navigationLinkDestination:AnyView(SettingsView())),
            MenuItem(name: "Logout", action:{ _ = self.session.logout() })
        ])
    } //navigation view
    
    func addAvatarToMenu(profile:Profile) {
        if let profileURL = URL(string:profile.profileURL) {
            let avatar = self.avatar(profileURL: profileURL)
            let avatarMenuItems = MenuItem(name: "Avatar", action: {}, buttonLabel: AnyView(avatar))
            self.menuItems.insert(avatarMenuItems, at: 0)
        }else{
            let defaultAvatar = noAvatar()
            let avatarMenuItems = MenuItem(name: "No Avatar", action: {}, buttonLabel: AnyView(defaultAvatar))
            self.menuItems.insert(avatarMenuItems, at: 0)
        }
    }
    
    func avatar(profileURL:URL) -> some View {
        VStack {
            ThumbnailImageView(imageURL: .constant(profileURL)).frame(width:100, height:100)
            Spacer().frame(height:30)
            Hr()
        }
    }
    func noAvatar() -> some View {
        VStack {
            Image("image-placeholder").renderingMode(.original).resizable().frame(width:100, height: 100).cornerRadius(100)
            Spacer().frame(height:30)
            Hr()
        }
    }
}

struct VerifyButton : View{
    @State var showAlert:Bool = false
    @EnvironmentObject var session:SessionStore
    
    func getSession() {
        self.session.listen()
    }
    
    var body: some View {
        Button(action: {
            self.showAlert.toggle()
        }, label: {
            Text(self.session.session != nil && self.session.session!.isEmailVerified ? "" : "Verify Account").foregroundColor(Color.red).font(.system(size: 10, weight: .regular, design: .default))
        }).alert(isPresented: $showAlert){
            Alert(title: Text("Verification"), message: Text("We need to send a verification email to \(self.session.session?.email ?? "")."), primaryButton:.default(Text("Send verification email"), action: {
                self.session.sendEmailVerification(success: {
                                   self.showAlert = false
                                    
                               }) { (error) in
                                
                                self.showAlert = false
                            
                               }
            }), secondaryButton: .cancel({
                self.showAlert = false
            }))
        }.onAppear(perform: getSession)
    }
}



struct InputSearch:View {
    @Binding var value:String
    @Binding var isOn:Bool
    var body:some View {
        ZStack {
            Color.black
            ZStack {
                HStack {
                    ZStack {
                        Rectangle()
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        TextField("Search a location", text: $value).padding(.horizontal)
                    }
                    Spacer()
                    SwitchView(isOn: $isOn)
                }
            }.padding(.all, 13)
        }.frame(height:70)
    }
}

struct Vr : View {
    var body:some View {
        Rectangle().foregroundColor(.red).frame(minWidth:1, maxWidth: 1, minHeight:0, maxHeight: .infinity)
    }
}

struct Hr : View {
    var body:some View {
        Rectangle().foregroundColor(Color("Hr")).frame(height:1)
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView().environmentObject(SessionStore())
//    }
//}
