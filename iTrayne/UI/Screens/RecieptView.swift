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

struct RecieptView: View {
    
    @State var selectCard:Bool = false

    @State var location:Location = Location()
    @State var trainer:Trainer = Trainer()
    @Binding var appointment:Appointment2
    @ObservedObject var appointmentStore:AppointmentStore = AppointmentStore()
    @ObservedObject var placeStore:PlacesStore = PlacesStore()
    @EnvironmentObject var checkout:CheckoutStore
    
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    @State var showAlert:Bool = false
    @State var exit:Bool = false
    @State var saving:Bool = false
    @State var card:Card?
    @State var loadingTitle:String = "Cancelling appointment..."
    @State var charge:Charge? = nil
    @State var confirm:Bool = false
    @Binding var chargeID:String
    @Binding var showReceipt:Bool
    @State var showConfirmation:Bool = false
    
    func getTrainer() {
        self.appointmentStore.getCharge(chargeID: self.chargeID, success: { charge in
            self.charge = charge
        })
    }

    func created(appt:Appointment2) -> String {
        if let date = appt.created {
            return date.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
        return "nil"
    }
    
    func apptDate() -> String? {
        return self.appointment.arriveAt?.dateValue().toFormat("dd MMM yyyy 'at' HH:mm")
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
                            self.showReceipt.toggle()
                        }, label:{
                            Image("exit").renderingMode(.original).resizable().frame(width:14, height: 14)
                        })
                        Spacer().frame(width:15)
                        VStack {
                            Text("Receipt").font(.system(size: 22, weight: .bold, design: .default)).foregroundColor(.white)
                        }
                        Spacer()
//                        Text("Help").foregroundColor(.white)
                    }.padding(.horizontal)
                    Hr()
                    ScrollView(.vertical) {
                        if self.charge != nil {
                            Group {
                                   HStack(alignment:.top, spacing: 0) {
                                    TextLayoutView(headline: .constant("CHARGE"), title: .constant(""), largeTitle: self.centsToDollars(cents: self.charge?.amount ?? 0), subtitle: .constant(""), footerText: .constant("Paid with \(self.charge?.paymentMethodDetails.card.brand ?? "Debit Card") ending in \(self.charge?.paymentMethodDetails.card.last4 ?? "")"))
                                   }
                               }
                            Group {
                                   HStack(alignment:.top, spacing: 0) {
                                    TextLayoutView(headline: .constant("CHARGE ID"), title: .constant(""), subtitle: .constant(self.charge?.id ?? ""), footerText: .constant(""))
                                   }
                            }
                            if self.appointment.canceled {
                                VStack(alignment:.leading, spacing: 12) {
                                            Text(self.charge!.refunded ? "This order has been cancelled and the charge was refunded" : "").foregroundColor(.red)
                                                .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                }
                                .padding(15)
                                .alert(isPresented: self.$showAlert) {
                                    Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Done"), action: {
                                    }))
                                }
                            }

                            if self.charge != nil {
                                if  !self.appointment.canceled {
                                    Button(action:self.confirmCancel,
                                            label: {
                                             Text(self.saving ? "Canceling Appointment..." : "Cancel Appointment")
                                                .fontWeight(.semibold)
                                             .foregroundColor(.red)
                                                .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                        })
                                        .disabled(self.saving)
                                        .alert(isPresented: self.$showConfirmation) {
                                          Alert(title: Text("Confirmation"), message: Text("Are you sure you want to cancel this appointment?"),
                                                             primaryButton: .cancel(Text("Cancel Appointment"), action: { self.cancelAndRefund() }) ,
                                                             secondaryButton: .default(Text("Nevermind"))
                                                )
                                            
                                        }
                                    }
                            }
                        }else{
                            Text("Loading...").foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, alignment: .leading).padding(15)
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
           .navigationBarHidden(true).navigationBarTitle("").sheet(isPresented: $selectCard) {
            CardListView(isSelectable: true, onSelect: { (card:Card) in
                self.card = card
            })
        }
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
        self.confirm = true
        self.showConfirmation.toggle()
    }
    
    func cancelAndRefund() {
        if let apptId = self.appointment.id {
            
            
            self.saving.toggle()
            self.showConfirmation = false
            
            self.appointmentStore.cancel(appointmentID: apptId, error:{ errMess in
                self.saving.toggle()
                self.confirm = false
                self.alertTitle = "Error Canceling"
                self.alertMessage = errMess
                self.exit.toggle()
                self.showConfirmation = false
                self.showAlert = true
            }, success: {
                self.saving.toggle()
                self.alertTitle = "Appointment Successfully Cancelled"
                self.alertMessage = "Your appointment was cancelled and you've been refunded"
                self.charge?.refunded.toggle()
                self.showConfirmation = false
                self.showAlert = true
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


struct RecieptView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
