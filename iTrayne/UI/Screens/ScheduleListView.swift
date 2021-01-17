//
//  ScheduleListView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase
import SwiftDate

struct ScheduleListView: View {
    
    @ObservedObject var appointmentStore:AppointmentStore = AppointmentStore()
    @EnvironmentObject var session:SessionStore
    @State var isLoading:Bool = false
    @State var showAppointment:Bool = false
    @State var appointmentID:String = ""
    @State var appointments:[Appointment2] = []
    @State var today:[Appointment2] = []
    
    var onClickCell:((Appointment2)->Void)? = nil
    
    func getSchedule() {
        
    
        
        #if TrainerApp
            if let user = self.session.session {
                self.appointmentStore.getBusinessOrders(userId: user.uid, appointmentListener: { appts in
        
                    
                    self.appointments = appts
                    self.today = self.appointments.filter{
                        return self.createdToday(appt: $0) && !$0.canceled
                    }
                    self.appointments = self.appointments.filter{
                        return !self.createdToday(appt: $0) || $0.canceled
                    }
                })
            }
        #else
            if let user = self.session.session {
                self.appointmentStore.getCustomerOrders(userId: user.uid, appointmentListener: { appts in
                    self.appointments = appts
                    self.today = self.appointments.filter{
                        return self.createdToday(appt: $0) && !$0.canceled
                    }
                    self.appointments = self.appointments.filter{
                        return !self.createdToday(appt: $0) || $0.canceled
                    }
                })
            }
        #endif
        

    }

    private func createdToday(appt:Appointment2) -> Bool {
        if let created =  appt.created {
            let createdToday = created.dateValue().compare(.isToday)
            return createdToday
        }
        return false
    }

    var body: some View {
        ZStack {
            Color.black
            ScrollView(.vertical, showsIndicators: false) {
                HStack{
                    Text("Training Sessions").font(.system(size: 30, weight: .bold, design: .default)).foregroundColor(.white)
                    Spacer()
                }.padding([.top, .leading], 15)
                VStack(alignment: .leading, spacing:0) {
                    if self.isLoading {
                        Text("Loading...").foregroundColor(.white).padding()
                    }else{
                        Spacer().frame(height:30)
                        Text("NOW")
                        .padding(.horizontal)
                        .frame(minWidth:0, maxWidth: .infinity, minHeight: 40, alignment:.leading)
                        .foregroundColor(.white)
                        .background(Color.black)
                            .font(.title)
                        Spacer().frame(height:30)
                        if self.today.isEmpty {
                            Text("No appointments today").foregroundColor(.white).padding()
                        }else{
                            ForEach( self.today, id: \.id){ app in
                                Button(action: {
                                    if let id = app.id{
                                        if let onClick = self.onClickCell {
                                            onClick(app)
                                        }else{
                                            self.appointmentID = id
                                            self.showAppointment.toggle()
                                        }
                                        
                                    }
                                }, label: {
                                    CellOne(past:.constant(false), appoinntment: app)
                                })
                            }
                        }
                        Spacer().frame(height:30)
                        Text("PAST")
                        .padding(.horizontal)
                        .frame(minWidth:0, maxWidth: .infinity, minHeight: 40, alignment:.leading)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .font(.title)
                        Spacer().frame(height:30)
                        if self.appointments.isEmpty {
                            Text("No past appointments").foregroundColor(.white).padding()
                        }else{
                            ForEach( self.appointments, id: \.id){ app in
                                Button(action: {
                                    if let id = app.id, let onClick = self.onClickCell {
                                        onClick(app)
                                        self.appointmentID = id
                                        self.showAppointment.toggle()
                                    }
                                }, label: {
                                    CellOne(past:.constant(true), appoinntment: app)
                                })
                            }
                            
                        }
                    }
                }
            }
        }
        .onAppear(perform: self.getSchedule)
        .sheet(isPresented: $showAppointment) {
            AppointmentDetailView(appointmentId: self.$appointmentID, showProfile: .constant(true), showAppointment:self.$showAppointment)
        }
    }
}


struct CellOne : View {
    @Binding var past:Bool
    var appoinntment:Appointment2
    @State var trainer:Trainer?
    @State var location:Location?
    @ObservedObject var appointmentStore:AppointmentStore = AppointmentStore()
    @State var price:Price? = nil
    @State var productStore:ProductStore = ProductStore()
    
    func avatar(profileURL:URL) -> some View {
        ThumbnailImageView(imageURL: .constant(profileURL)).frame(width:40, height: 40)
    }
    
    func onAppear() {
        if let priceID = self.appoinntment.priceID {
            self.productStore.getPriceByID(id: priceID, success: {
                price in
                self.price = price
            }) { (errMess) in
                print(errMess)
                
            }
        }
        self.getTrainer(docRef: self.appoinntment.trainer)
        self.getLocation(docRef: self.appoinntment.location)
    }
    
    var body : some View {
        ZStack(alignment:.leading) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack (spacing:0) {
                Spacer().frame(height:12)
                HStack {
                    VStack {
                        if self.trainer != nil {
                            if self.trainer!.avatarURL.isEmpty {
                                Image("avatar").resizable().frame(width:40, height: 40)
                            }else{
                                self.avatar(profileURL: URL(string:self.trainer?.avatarURL ?? "")!)
                            }
                        }
                        Spacer()
                    }
                    Spacer().frame(width:20)
                    HStack {
                        VStack(alignment:.leading, spacing: 2) {
                            Text("\(self.trainer?.firstName ?? "") \(self.trainer?.lastName ?? "")").foregroundColor(.white).font(.system(size: 16, weight: .bold, design: .default))
                            if !self.past {
                                Text("\(self.location?.street ?? "")").foregroundColor(.gray).font(.system(size: 16, weight: .light, design: .default)).lineLimit(1)
                            }
                            Text("\(self.location?.city ?? "") \(self.location?.state ?? "")").foregroundColor(.gray).font(.system(size: 16, weight: .light, design: .default)).lineLimit(1)
                            Spacer()
                        }
                        Spacer()
                        VStack(spacing:5) {
                                Text(self.centsToDollars(cents: self.appoinntment.priceID != nil ? self.price?.unitAmount ?? 0 : self.trainer?.hourlyPrice ?? 0))
                                .frame(minWidth:0, maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold, design: .default))
                            Spacer()
                        }.frame(width:80)
                    }
                    Spacer()
                }.padding(.horizontal)
            }
        }.onAppear(perform: onAppear)
    }
    
    func apptDate() -> String? {
        return self.appoinntment.arriveAt?.dateValue().toFormat("dd MMM yyyy 'at' HH:mm")
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
    
    func created(appt:Appointment2) -> String {
        if let date = appt.created {
            return date.dateValue().toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
        return "nil"
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
}

//struct ScheduleListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleListView().environmentObject(SessionStore())
//    }
//}
