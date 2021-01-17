//
//  AppointmentDetailView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 5/16/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
//
//  ConfirmationView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/12/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import SwiftDate
import MapKit

struct AppointmentDetailView: View {
    
    @State var selectCard:Bool = false
    @Binding var appointmentId:String
    @State var location:Location = Location()
    @State var trainer:Trainer = Trainer()
    @State var appointment:Appointment2? = nil
    @ObservedObject var appointmentStore:AppointmentStore = AppointmentStore()
    @ObservedObject var placeStore:PlacesStore = PlacesStore()
    @EnvironmentObject var checkout:CheckoutStore
    
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    @State var showAlert:Bool = false
    @State var exit:Bool = false
    @Binding var showProfile:Bool
    @State var saving:Bool = false
    @State var card:Card?
    @State var loadingTitle:String = "Cancelling appointment..."
    @State var charge:Charge? = nil
    @Binding var showAppointment:Bool
    @State var confirm:Bool = false
    @State var chargeID:String = ""
    @State var showReceipt:Bool = false
    
    
    func getTrainer() {
        self.appointmentStore.getAppointmentByID(appointmentId:appointmentId, success: { app in
            self.appointment = app
            self.getLocation(docRef: app.location)
            self.getTrainer(docRef: app.trainer)
            self.chargeID = app.chargeID
        })
    }

    func created(appt:Appointment2) -> String {
        if let date = appt.created {
            return date.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
        return "nil"
    }
    
    func apptDate() -> String? {
        if let arriveAtDate = self.appointment?.arriveAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US")
            return dateFormatter.string(from: arriveAtDate.dateValue())
        }
        return ""
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
    
    func avatar(profileURL:URL) -> some View {
        ThumbnailImageView(imageURL: .constant(profileURL)).frame(width:26, height: 26)
    }
    
    var body: some View {
           ZStack(alignment:.topLeading) {
               Color.black.edgesIgnoringSafeArea(.all)
               ZStack(alignment:.topLeading) {
                VStack(alignment:.leading) {
                    Spacer().frame(height:10)
                    HStack {
                        Button(action:{
                            self.showAppointment.toggle()
                        }, label:{
                            Image("exit").renderingMode(.original).resizable().frame(width:14, height: 14)
                        })
                        Spacer().frame(width:15)
                        VStack {
                            Text("Your Order").font(.system(size: 22, weight: .bold, design: .default)).foregroundColor(.white)
                        }
                        Spacer()
                        Button(action:{
                            self.showReceipt.toggle()

                        }, label:{
                            Text("View Receipt").foregroundColor(.white)
                        })
                    }.padding(.horizontal)
                    Hr()
                    ScrollView(.vertical) {
                        
                        Spacer().frame(height:20)
                        Text("YOUR TRAINER").font(.system(size: 12, weight: .bold, design: .default)).foregroundColor(Color("green")).frame(minWidth:0, maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                        
                        HStack {
                             if self.trainer.avatarURL.isEmpty {
                                 Image("avatar").resizable().frame(width:18, height: 18)
                            }else{
                                self.avatar(profileURL: URL(string:self.trainer.avatarURL)!)
                            }
                            Spacer().frame(width:15)
                            VStack {
                                Text("\(self.trainer.firstName) \(self.trainer.lastName)").font(.system(size: 24, weight: .bold, design: .default)).foregroundColor(.white)
                            }
                            Spacer()
                            Button(action:{}, label: {
                                ZStack {
                                    Circle().stroke(Color.gray).frame(width:40, height: 40).foregroundColor(.black)
                                    Image("phone").resizable().frame(width:18, height: 18).padding(15).foregroundColor(Color("green"))
                                }
                            })
                            Button(action:{}, label: {
                                ZStack {
                                    Circle().stroke(Color.gray).frame(width:40, height: 40).foregroundColor(.black)
                                    Image("chat").resizable().frame(width:18, height: 18).padding(15).foregroundColor(Color("green"))
                                }
                            })
                        }.padding(.horizontal)
                        Hr()
                        ZStack {
//                            VStack {
//                                MapView(annotations: self.$annotations, centerCoordinate: self.$locationStore.centerCordinate, onTapPoint: { annotation in
//
//                                }).frame(minWidth:0, maxWidth: .infinity, minHeight: 200)
//                            }
                            VStack {
                                Rectangle().frame(height:175).opacity(0.8)
                                Spacer()
                            }
                            HStack {
                                TextLayoutView(headline: .constant("MEETUP LOCATION"), title: .constant("\(self.location.name)"), subtitle: .constant("\(self.location.street)\n\(self.location.city), \(self.location.state)"), footerText: .constant(""), showDivider:false)
                                Spacer()
                                Button(action:{
                                    
                                }, label: {
                                    ZStack {
                                        Circle().stroke(Color.gray).frame(width:40, height: 40).foregroundColor(.black)
                                        Image("right-turn").resizable().frame(width:18, height: 18).padding(15).foregroundColor(Color("green"))
                                    }
                                })
                                Spacer().frame(width:15)
                            }
                        }
                        Hr()
                        HStack {
                            TextLayoutView(headline: .constant("ARRIVAL DATE & TIME"), title: .constant("\(self.apptDate() ?? "")"), subtitle: .constant(""), footerText: .constant(""))
                            Spacer()
                        }
                        if self.appointment != nil {
                           TextLayoutView(headline: .constant("ORDER STATUS"), title: .constant( self.appointment!.pending ? "PENDING" : "ACCEPTED"), subtitle: .constant(""), footerText: .constant("Waiting on trainer to accept this order."))
                        }
                        
                        Spacer()
                    }
    
                    Spacer()
                    
                   }
               }.zIndex(1)
            
            if self.saving {
                ZStack {
                    LoadingView(title: self.loadingTitle)
                }.zIndex(20).edgesIgnoringSafeArea(.all)
            }

           }
           .onAppear(perform: getTrainer)
           .sheet(isPresented: self.$showReceipt){
                if !self.chargeID.isEmpty {
                    if self.appointment != nil {
                        RecieptView(appointment: .constant(self.appointment!), chargeID: self.$chargeID, showReceipt: self.$showReceipt)
                    }
                   
                }
           }
           .navigationBarHidden(true)
           .navigationBarTitle("")
    }
    
    func getTrainer(docRef:DocumentReference) {
        self.appointmentStore.getTrainer(documentReference: docRef, trainer: { trainer in
            self.trainer = trainer
        })
    }
    
    func getLocation(docRef:DocumentReference) {
        self.appointmentStore.getLocation(documentReference: docRef, location:{ location in
            self.location = location
        })
    }
    
    func confirmCancel() {
        self.confirm.toggle()
        self.showAlert.toggle()
    }
    
    func cancelAndRefund() {
        if let appt = self.appointment, let apptId = appt.id {
            self.saving.toggle()
            self.appointmentStore.cancel(appointmentID: apptId, error:{ errMess in
                self.saving.toggle()
                self.confirm.toggle()
                self.alertTitle = "Error Canceling"
                self.alertMessage = errMess
                self.exit.toggle()
                self.showAlert.toggle()
            }, success: {
                self.saving.toggle()
                self.confirm.toggle()
                self.alertTitle = "Appointment Successfully Cancelled"
                self.alertMessage = "Your appointment was cancelled and you've been refunded"
                self.showAlert.toggle()
            })
        }
    }
    
    func noCardCell() -> some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack(alignment:.top) {
                 Image("card").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:20, height: 20)
                 Spacer().frame(width:20)
                 Text("Select a card for payment").foregroundColor(Color.red)
                 Spacer()
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



//struct AppointmentDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppointmentDetailView(trainerId: "1", showProfile: .constant(true))
//    }
//}
