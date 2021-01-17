//
//  AddressListView.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/7/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import SwiftUI

struct AddressListView:View {
    @ObservedObject var locationSearchService: LocationSearchService
    @State var addresses:[UserAddress] = []
    @State var stackItems:[VStackMenuItem] = []
    @State var addressStore:AddressStore = AddressStore()
    @State var showAddressSheet:Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var alertViewModel:AlertViewModel = AlertViewModel()
    @State var selectedAddress:UserAddress? = nil
    //@State var profileStore:ProfileStore = ProfileStore()
    @EnvironmentObject var profileStore:ProfileStore
    @EnvironmentObject var session:SessionStore
    @State var profile:Profile? = nil
    
    var onSelect:((UserAddress)->Void)? = nil
    
    func setMenu() {
        self.session.listen {
            if let user = self.session.session {
                self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                   
                })
                
                self.addressStore.get(userId: user.uid, success: { addresses in
                    self.addresses = addresses
                })
            }
        }
        

    }
    
    func addAddressButton() -> some View {
        Button(action: {
            self.showAddressSheet.toggle()
        }, label: {
            Text("+ Add Address").foregroundColor(Color("green"))
        })
    }
    
    func delete(at offset:IndexSet) {
        self.addresses.remove(atOffsets: offset)
        //let address = self.addresses.index(offset.count, offsetBy: )
    }
    
        var body:some View {
            ZStack(alignment:.topLeading) {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(alignment:.leading) {
                    HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Locations"), rightView:AnyView(self.addAddressButton()), exitScreen: .constant(false))
                    List {
                        ForEach(self.addresses, id:\.self){ (address:UserAddress) in
                            Button(action: {
                                self.alertViewModel.title = "Confirm"
                                self.alertViewModel.message = "Are you sure you want to make \(address.address ?? "") your default address for workouts?"
                                self.selectedAddress = address
                                
                                self.session.listen {
                                    

                    
                                    guard var profile:Profile = self.profileStore.profile else{
                                        print("no profile")
                                        return
                                    }
                                    
                                    profile.defaultAddress = address.id ?? "no address"
                                    
                                    self.profileStore.updateOrCreateProfile(profile: profile, success: {
                                        if let select = self.onSelect {
                                            select(address)
                                        }
                                        //self.onSelect(address)
                                        self.presentationMode.wrappedValue.dismiss()
                                    })
                                }
                                
                                //self.alertViewModel.showAlert = true
                                
                            }, label: {
                                VStack(alignment:.leading, spacing:0) {
                                    HStack {
                                        Image("gps").resizable().aspectRatio(contentMode: .fit).frame(width:20).foregroundColor(self.profileStore.profile?.defaultAddress == address.id ? .green : .white)
                                        Text(address.address ?? "").foregroundColor(self.profileStore.profile?.defaultAddress == address.id ? .green : .white).frame(minWidth:0, maxWidth:.infinity, alignment: .leading).padding()
                                    }
                                    
                                    Hr()
                                
                                }.listRowBackground(Color.black)
                                                               .foregroundColor(.white)
                            }).alert(isPresented: self.$alertViewModel.showAlert) {
                                
                                Alert(title: Text( self.alertViewModel.title), message: Text(self.alertViewModel.message), primaryButton: .default(Text("Use address"), action: {
                                    
                                   
                        

                                    
                                    
                                }), secondaryButton: .cancel())
                            }
                           
                        }.onDelete(perform: self.delete)
                    }

                    Spacer()
                }
            }
            .onAppear(perform: {
                
                self.setMenu()
            })
            .sheet(isPresented: self.$showAddressSheet){
                AddressSearchView(locationSearchService: self.locationSearchService).environmentObject(SessionStore())
            }
            .navigationBarHidden(true)
            .navigationBarTitle("")
    }
    

    
    func selectedAddress(address:UserAddress) {
        self.presentationMode.wrappedValue.dismiss()
    }
    
}
