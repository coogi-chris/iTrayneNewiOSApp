//
//  ConfirmationView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/12/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import PhoneNumberKit

struct ConfirmationView: View {
    
    @State var selectCard:Bool = false
    var trainerId:String?
    @State var location:Location = Location()
    @State var trainer:Profile? = nil
    @ObservedObject var trainerStore:TrainerStore = TrainerStore()
    @ObservedObject var placeStore:PlacesStore = PlacesStore()
    @EnvironmentObject var checkout:CheckoutStore
    @EnvironmentObject var locationStore:LocationStore
    @State var productStore:ProductStore = ProductStore()
    
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    @State var showAlert:Bool = false
    @State var exit:Bool = false
    @Binding var showProfile:Bool
    @State var saving:Bool = false
    @State var card:Card?
    @State var loadingTitle:String = "Booking Appointment..."
    var isBooking:Bool = false
    @State var isAppointment:Bool = false
    @State var stackItems:[VStackMenuItem] = []
    @EnvironmentObject var session:SessionStore
    @State var currentSearchAddress:String = "Location..."
    @EnvironmentObject var profileStore:ProfileStore
    @State var phoneNumber:String = ""
    @State var price:Price? = nil
    @Binding var showAppointment:Bool
    @EnvironmentObject var mapmvv:MapListViewModel
    
    func getAddress() {
        self.locationStore.getCurrentUserLocationAddress(completion: { address in
            self.currentSearchAddress = address
        })
    }
    
    func getUserProfile() {
        self.session.listen {
            if let user = self.session.session {
                self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                    if let profile = profile {
                        self.phoneNumber = profile.phone
                        self.formateNumber(number: self.phoneNumber)
                    }
                })
            }
        }
    }
    
    func getPrice() {
        self.productStore.getPriceByID(id: self.checkout.checkout.priceID, success: { (price:Price) in
            self.price = price
        })
    }
    
    func formateNumber(number:String) {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            self.phoneNumber = phoneNumber.nationalNumber.description
        }catch {
            print(error)
        }
    }
    
    func apptDate() -> String {
        if let arriveAtDate = self.checkout.checkout.arriveAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US")
            return dateFormatter.string(from: arriveAtDate.dateValue())
        }
        return ""
    }
    
    
    
    func getTrainer() {
        
        self.getAddress()
        self.getUserProfile()
        
        
        guard let id = self.trainerId else {
            
            self.getPrice()
            
            self.stackItems = [
                VStackMenuItem(
                    header: AnyView(CellHeaderView(label: .constant("Order details"))),
                    views: [
                        AnyView(CellView(label: .constant("Service"), isDestinationLink: true, destination: AnyView( BookTrainerFormView(exit: self.$exit).environmentObject(self.checkout)), rightLabel: self.$checkout.checkout.type)),
                        
                        AnyView(CellView(label: .constant("Date & Time"), isDestinationLink: true, destination: AnyView( BookTrainerFormView(exit: self.$exit).environmentObject(self.checkout)), rightLabel: .constant(self.apptDate()))),
                        
                        AnyView(CellView(label: .constant("Gender"), isDestinationLink: true, destination: AnyView( BookTrainerFormView(exit: self.$exit).environmentObject(self.checkout)), rightLabel: self.$checkout.checkout.gender)),
                        AnyView(CellView(label: .constant("Address"), isDestinationLink: true, destination: AnyView(UpdateEmailView()), rightLabel: self.$currentSearchAddress, rightSubtitle:"")),
                        AnyView(CellView(label: .constant("Length"), isDestinationLink: true, destination: AnyView( BookTrainerFormView(exit: self.$exit).environmentObject(self.checkout)), rightLabel: self.$checkout.checkout.length)),
                        AnyView(CellView(label: .constant("Phone"), isDestinationLink: true, destination: AnyView(ProfileFormView(canExit:true)), rightLabel: $phoneNumber))
                    ]
                )
            ]

            self.isAppointment = true
            return
        }
        
       
        self.profileStore.getProfileByUserId(userId: id, success: { trainer in
            self.trainer = trainer
            print(self.trainer)
        }, error: { err in
            print(err)
        })
    }
    
    
       var body: some View {
           ZStack(alignment:.topLeading) {
               Color.black.edgesIgnoringSafeArea(.all)
               ZStack(alignment:.topLeading) {
                VStack(alignment:.leading, spacing:0) {
                    HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Checkout"), centerTitle:true, exitScreen: .constant(false))
                    
                    ScrollView(.vertical) {
                        if self.isAppointment {
                            VStackMenuView(stackItems: .constant(stackItems))
                        }else{
                            TextLayoutView(headline: .constant("ORDER DETAILS"), title: .constant("\(self.isAppointment ? "Future Training" : "On-Demand training") with \(self.trainer?.firstName ?? "")"), subtitle: .constant(""), footerText: .constant("Trainer is 6 miles away from you"))
                            
                        }
                        
//                           Group {
//                               HStack(alignment:.top, spacing: 0) {
//                                if self.isAppointment {
//                                   TextLayoutView(headline: .constant("DETAILS"), title: .constant(""), largeTitle: self.checkout.checkout.length, subtitle: .constant(""), footerText: .constant(""))
//                                }
//                                TextLayoutView(headline: .constant("GRAND TOTAL"), title: .constant(""), largeTitle: self.centsToDollars(cents: self.trainer.hourlyPrice), subtitle: .constant(""), footerText: .constant(""))
//                               }
//                           }
//
                        
                        
//                        Button(action: {
//                            self.selectCard.toggle()
//                        }, label: {
//                            if self.card != nil {
//                                CardCell(last4: self.card?.last4 ?? "")
//                            }else{
//                                self.noCardCell()
//                            }
//
//                        })
//                        .alert(isPresented: self.$showAlert) {
//                            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Got it"), action: {
//                                if self.exit {
//                                    self.showProfile = false
//                                    //self.presentationMode.wrappedValue.dismiss()
//                                }
//                            }))
//                        } //end button
                        
                    }
                
                    Spacer()
                   }
               }.zIndex(1)
               ZStack(alignment:.bottomLeading) {
                   VStack {
                       Spacer()
                       ZStack {
                           VStack(alignment:.leading, spacing: 0) {
                               Spacer().frame(height:10)
                            
                               Button(action: {
                                   self.selectCard.toggle()
                               }, label: {
                                   if self.card != nil {
                                    CardCell(last4: "\(self.card?.last4 ?? "") \(self.card?.brand ?? "")")
                                   }else{
                                       self.noCardCell()
                                   }
                                   
                               })
                               .alert(isPresented: self.$showAlert) {
                                   Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Got it"), action: {
                                       if self.exit {
                                           self.showProfile = false
                                        self.mapmvv.showAppointment = true
                                       }
                                   }))
                               } //end button
                               
                            
                            
                            if self.isAppointment {
                                Button(action:self.payAndComplete,
                                    label: {
                                     HStack(spacing:0) {
                                         Spacer()
                                         
                                        Text(self.saving ? "Booking appointment..." : "Pay \(self.centsToDollars(cents: self.price?.unitAmount ?? 0))").font(.system(size: 28, weight: .bold, design: .default))
                                         .foregroundColor(.black)
                                         Spacer()
                                     }.frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                                     
                                })
                                .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(50).padding()
                                 .disabled(self.saving)
                            }else{
                                Button(action:self.payAndComplete,
                                    label: {
                                     HStack(spacing:0) {
                                         Spacer()
                                        Text(self.saving ? "Booking appointment..." : "Pay \(self.centsToDollars(cents: self.trainer?.hourlyPrice ?? 0))").font(.system(size: 28, weight: .bold, design: .default))
                                         .foregroundColor(.black)
                                         Spacer()
                                     }.frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                                     
                                })
                                .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(50).padding()
                                 .disabled(self.saving)
                            }
                            
                               Spacer().frame(height:30)
                           }
                       }.background(Color("Hr"))
                   }
               }.zIndex(10).edgesIgnoringSafeArea(.all)
            
            if self.saving {
                ZStack {
                    LoadingView(title: self.loadingTitle)
                }.zIndex(20).edgesIgnoringSafeArea(.all)
            }

           }
           .onAppear(perform: getTrainer)
           .navigationBarHidden(true).navigationBarTitle("").sheet(isPresented: $selectCard) {
            CardListView(isSelectable: true, onSelect: { (card:Card) in
                self.card = card
            })
        }
    }
    
    func payAndComplete() {
        
        guard let card = self.card else {
            self.alertTitle = "Error"
            self.alertMessage = "You have to select a card"
            self.exit = false
            self.showAlert.toggle()
            return
        }
        
        self.saving.toggle()
        
        // Future Appoints
        
        if self.isAppointment {
            guard let arriveDate = self.checkout.checkout.arriveAt else {
                print("no arrive at");
                return
            }

            self.checkout.createAppointment(productID: self.checkout.checkout.productID, cardId: card.id, priceID: self.checkout.checkout.priceID, gender: self.checkout.checkout.gender, arriveAt: arriveDate.dateValue().toString(), success: {
                self.afterBookTrainer()
            }, error: { err in
                 self.viewError(errorMess: err)
            })
        }else{
            
            guard let trainerID = self.trainerId else {
                return
            }
  
            self.checkout.checkout(trainerID: trainerID, cardId: card.id, success:{
                self.afterBookTrainer()
            }, error: { errorMess in
                self.viewError(errorMess: errorMess)
            })
        }

    }
    
    func viewError(errorMess:String) {
        self.alertTitle = "Issue"
        self.alertMessage = errorMess
        self.exit = false
        self.saving.toggle()
        self.showAlert = true
    }
    
    func afterBookTrainer() {
        self.loadingTitle = "Appointment Booked"
        self.alertTitle = "Successful"
        self.alertMessage = "You've successly booked a training session."
        self.exit = true
        self.showAlert = true
    }
    
    func noCardCell() -> some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack(alignment:.top) {
                 Image("card").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:20, height: 20)
                 Spacer().frame(width:20)
                 Text("Select a card for payment").foregroundColor(Color.white)
                 Spacer()
                Image("chevron").resizable().frame(width:18, height:18).foregroundColor(.gray)
             }.padding()
            Rectangle().fill(Color("dividerColor")).frame(height:1)
        }
    }
    
    func centsToDollars(cents:Int) -> String {
       let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        let number = cents/100
        if let formattedTipAmount = formatter.string(from: number as NSNumber) {
            return formattedTipAmount
        }
        return ""
    }
}

//struct ConfirmationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmationView(trainerId: "", checkout: <#CheckoutStore#>)
//    }
//}
