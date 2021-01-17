//
//  AddressSearchView.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase

struct AddressSearchView: View {
    @ObservedObject var locationSearchService: LocationSearchService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var addressStore:AddressStore = AddressStore()
    
    @State var selectedAddress:UserAddress? = nil
    @EnvironmentObject var session:SessionStore
    @State var showAlert:Bool = false
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing:0) {
                HStack {
                    Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Exit").padding()
                    })
                    Spacer()
                }
                SearchBar(text: $locationSearchService.searchQuery)
                    List(locationSearchService.completions) { completion in
                        Button(action: {
                            
                            let address = "\(completion.title) \(completion.subtitle)"
                            self.addressToCord(address: address, completionHandler: { location in
                                
                                self.session.listen {
                                    let address = UserAddress(location: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) , address: address, userID: self.session.session?.uid ?? "")
                                    
                                    self.selectedAddress = address
                                    
                                    self.alertTitle = "Confirm Address"
                                    self.alertMessage = "Are you sure you want to add \(self.selectedAddress?.address ?? "")"
                                    
                                    self.showAlert = true
                                }
                                

                                
                            })
                           
                        }, label: {
                            VStack(alignment:.leading) {
                                Text(completion.title).foregroundColor(.white)
                                Text(completion.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                        }).alert(isPresented: self.$showAlert) {
                            Alert(title: Text(self.alertTitle), message:Text( self.alertMessage), primaryButton: .default(Text("Add address"), action: {
                                
                                if let address = self.selectedAddress {
                                    self.addressStore.create(address: address , success: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }, error: { err in
                                        print(err.localizedDescription)
                                    })
                                }
                                
                                
                            }), secondaryButton: .cancel())
                        }
                    }
            }.navigationBarHidden(true)
            .navigationBarTitle("")
        }

    }
    
    func addressToCord(address:String, completionHandler: @escaping ((CLLocation)->Void) ){
        let address = address
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                return
            }
            completionHandler(location)
        }
    }
}

//struct AddressSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        //AddressSearchView(locationSearchService: )
//    }
//}
