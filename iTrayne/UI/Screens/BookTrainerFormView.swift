//
//  BookTrainerFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase

struct BookTrainerFormView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var dateString:String = ""
    @State private var bdayTimestamp:Timestamp = Timestamp()
    @State private var dob:Date = Date()
    @EnvironmentObject var checkout:CheckoutStore
    @State var productStore:ProductStore = ProductStore()
    @State var products:[Product] = []
    
    @State var selectedNicknames:[String] = []
    
    @State var loading:Bool = true
    @State var loadingPrices:Bool = false
    @State var date:Date = Date()
    @EnvironmentObject var locationStore:LocationStore
    @Binding var exit:Bool
    
    var onlyShowService:Bool = false
    
    func getProducts() {
        self.loading = true
        
        self.productStore.getProducts(success: { products in
            self.products = products
            self.loading = false
            
            if !self.checkout.checkout.productID.isEmpty {
                self.getPrices(productId: self.checkout.checkout.productID)
                self.checkout.checkout.priceID = self.checkout.checkout.priceID
            }
            if !self.checkout.checkout.priceID.isEmpty {
                self.checkout.checkout.priceID = self.checkout.checkout.priceID
            }
            
        }, error: { errMessage in
            
        })
    }
    
    func getPrices(productId:String) {
        self.loadingPrices = true
        self.productStore.getPrices(productId:productId, success: { prices in
            self.checkout.selectedPrices = prices
            let nicknames = self.checkout.selectedPrices.map{
                return $0.nickname
            }
            self.selectedNicknames = nicknames
            self.loadingPrices = false
        }, error: { message in
            self.loadingPrices = false
        })
    }
    
    
    var body: some View {
        NavigationView {
                    ZStack(alignment:.topLeading) {
                        Color.black.edgesIgnoringSafeArea(.all)
                        ScrollView {
                            VStack(alignment:.leading, spacing:0) {
                                
                                HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(true), hasBackBtn: .constant(true), title: .constant(""), isModal:true, onClickBack:{
                                    self.presentationMode.wrappedValue.dismiss()
                                }, exitScreen: .constant(false))
                                
                                
                                
                                if self.loading {
                                    Text("Loading Services...")
                                        .foregroundColor(.white)
                                        .padding()
                                }else{
                                    ForEach(self.products, id:\.id) { (product:Product) in
                                        Group {
                                            self.TraningTypeSelect(product.name, onclick: {
                                                self.checkout.checkout.type = product.name
                                                self.checkout.checkout.productID = product.id
                                                self.getPrices(productId: product.id)
                                            })
                                            Hr()
                                        }
                                    }
                                }
                                
                                if self.loadingPrices {
                                    Text("Loading prices...")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                }else{
                                    if !self.checkout.selectedPrices.isEmpty {
                                        VStack(spacing:0) {
                                            Text("Training Length").foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, alignment: .leading).padding()
                                            ButtonGroup(prices: self.$checkout.selectedPrices, onclick: { price in
                                                self.checkout.checkout.priceID = price.id
                                            })
                                        }
                                        Hr()
                                    }
                                }

                                if !self.checkout.selectedPrices.isEmpty {
                                    VStack(spacing:0) {
                                        Text("Gender").foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, alignment: .leading).padding()
                                        SelectGender()
                                    }
                                    Hr()
                                }
                                
                                if self.isValid() {
                                    Group {
                                        Spacer().frame(height:30)
                                        NavigationLink(destination:DateTimePicker(date: self.$date, title:"Select a date and time you want the trainer to arrive.", navigateOnClickTo:AnyView(ConfirmationView(showProfile:self.$exit, showAppointment: .constant(false))
                                            .environmentObject(LocationStore())
                                            .environmentObject(ProfileStore())
                                            .environmentObject(SessionStore())
                                            .environmentObject(MapListViewModel())
                                            .onAppear(perform: {
                                            let timestamp = Timestamp(date:self.date)
                                            self.checkout.checkout.arriveAt = timestamp
                                        }))), label: {
                                            Text("Next").fontWeight(.semibold)
                                                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                                        })
                                        .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(50)
                                        .padding(.horizontal, 20)
                                    }
                                }

                                
                                
                                
                                
                                
                            }.frame(minWidth:0, maxWidth: .infinity)
                        }.frame(minWidth:0, maxWidth: .infinity)
                    }.navigationBarHidden(true)
                    .navigationBarTitle("")
        }.onAppear(perform: self.getProducts)
        
    }
    
    
    func isValid() -> Bool {
       if( self.checkout.checkout.length.isEmpty ||
            self.checkout.checkout.gender.isEmpty ||
        self.checkout.checkout.type.isEmpty){
        return false
        }
        return true
    }
    

    
    func TraningTypeSelect(_ type:String, selected:Bool = false, onclick: (()->Void)? = nil ) -> some View {
            VStack(alignment:.leading) {
                HStack(spacing:0) {
                    Button(action:{
                        self.checkout.checkout.type = type
                        if let click = onclick {
                            click()
                        }
                    }, label:{
                        VStack {
                            Spacer().frame(height:15)
                            HStack {
                              Text(type).foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                                Circle()
                                    .foregroundColor(self.checkout.checkout.type == type ? Color.gray : Color.white.opacity(0.2))
                                    .frame(width:20, height: 20)
                                
                                    
                            }
                            Spacer().frame(height:15)
                        }.padding(.horizontal)
                    })
                    Spacer()
                }
            }
    }
    
    func selectableBtn() -> some View {
        HStack {
            ForEach(self.checkout.selectedPrices, id:\.id) { (price:Price) in
                Button(action:{
                    
                    self.checkout.checkout.length = "60 min"
                    print(self.checkout.checkout)
                }, label:{
                    Text(price.nickname).frame(minWidth:0, maxWidth: .infinity).padding(7).foregroundColor(.white)
                }).border(Color.white)
            }
        }.padding()
    }
    
    func SelectGender() -> some View {
        HStack {
            Button(action:{
                self.checkout.checkout.gender = "Male"
            }, label:{
                Text("Male").frame(minWidth:0, maxWidth: .infinity).padding(7).foregroundColor(.white)
            })
            .background(self.checkout.checkout.gender == "Male" ? Color.gray : Color.black)
            .border(Color.white)
            Button(action:{
                self.checkout.checkout.gender = "Female"
            }, label:{
                Text("Female").frame(minWidth:0, maxWidth: .infinity).padding(7).foregroundColor(.white)
            })
            .background(self.checkout.checkout.gender == "Female" ? Color.gray : Color.black)
            .border(Color.white)
            Button(action:{
                self.checkout.checkout.gender = "other"
            }, label:{
                Text("Other").frame(minWidth:0, maxWidth: .infinity).padding(7).foregroundColor(.white)
            })
            .background(self.checkout.checkout.gender == "other" ? Color.gray : Color.black)
            .border(Color.white)
        }.padding()
    }
}



struct ButtonGroup:View {
    
    @Binding var prices:[Price]
    var onclick:((Price)->Void)
    @State var selectedPrice:Price? = nil
    @EnvironmentObject var checkout:CheckoutStore
    
    var body: some View {
        HStack {
            ForEach(self.prices, id:\.id) { (price:Price) in
                Button(action:{
                    self.checkout.checkout.length = price.nickname
                    self.selectedPrice = price
                    self.onclick(price)
                }, label:{
                    Text(price.nickname).frame(minWidth:0, maxWidth: .infinity).padding(7).foregroundColor(.white)
                })
                .background(self.isSelected(price: price) ? Color.gray : Color.black)
                .border(Color.white)
            }
        }
        .onAppear(perform: {
            
        })
        .padding()
    }
    
    func isSelected(price:Price) -> Bool {
        if let selectedPrice = self.selectedPrice {
            return selectedPrice.id == price.id
        }
        return false
//        let isSelected = self.prices.filter{
//            if let selectedPrice = self.selectedPrice {
//                return $0.id == selectedPrice.id
//            }
//            return false
//        }
    }
}


struct BookTrainerFormView_Previews: PreviewProvider {
    static var previews: some View {
        BookTrainerFormView(exit: .constant(false))
    }
}
