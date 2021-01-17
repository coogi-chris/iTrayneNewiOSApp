//
//  PaymentDetailView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/5/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct PaymentDetailView: View {
    
    var cardID:String? = nil
    @ObservedObject var cardStore:CardStore = CardStore()
    @State var card:Card? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var confirmDelete:Bool = false
    @State var alertTitle:String = ""
    @State var alertMess:String = ""
    
    @State var didDelete:Bool = false
    
    func getDebitCard() {
        if let id = self.cardID {
            self.cardStore.getCardByID(cardId: id, success: { card in
                self.card = card
            }, error: { errMessage in
                print(errMessage)
            })
        }
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment:.leading, spacing: 0) {
                
                HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("\(self.card?.brand ?? "Payment") Card"), rightView:editCardButton(), exitScreen: .constant(false))
                
                Spacer().frame(height:25)
                
                if self.card != nil {
                    self.cardInfoView()
                }else{
                    Text("Loading...").foregroundColor(Color.white).padding(.horizontal, 20)
                }
                
                Spacer().frame(height:40)
                Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                Spacer().frame(height:20)
                if self.card != nil {
                    HStack {
                        Spacer()
                        Button(action:{
                            self.alertTitle = "Are you sure?"
                            self.alertMess = "Delete this card"
                            self.confirmDelete.toggle()
                        }, label:{
                            Text("Delete").foregroundColor(Color.red)
                        }).padding(.horizontal, 20)
                            .alert(isPresented: $confirmDelete) {
                                if self.didDelete {
                                    return Alert(title: Text(self.alertTitle), message: Text(self.alertMess), dismissButton: .cancel(Text("Okay"), action: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }))
                                }else{
                                   return  Alert(title: Text(self.alertTitle), message: Text(self.alertMess), primaryButton: .default(Text("Delete Card"), action: {
                                        self.delete()
                                    }), secondaryButton: .cancel())
                                }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }.onAppear(perform: {
                self.getDebitCard()
            })
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
    
    func delete() {
        self.cardStore.deleteCardByID(cardId: self.cardID ?? "", success: { conf in
            self.didDelete.toggle()
            self.alertTitle = "Card Delete"
            self.alertMess = "Your card has been removed"
            self.confirmDelete.toggle()
        }, error: { errMessage in
            print(errMessage)
        })
    }
    
    func cardInfoView() -> some View {
        VStack(alignment:.leading, spacing:15) {
            Text("**** **** **** **** \(self.card?.last4 ?? "")").foregroundColor(Color.white).padding(.horizontal, 20)
            HStack{
                Text("Exp Month").foregroundColor(Color.gray)
                Text(self.card?.exp_month.description ?? "").foregroundColor(Color.white)
                Text("Exp Year").foregroundColor(Color.gray)
                Text(self.card?.exp_year.description ?? "").foregroundColor(Color.white)
            }.padding(.horizontal, 20)
        }
    }
    
    func editCardButton() -> AnyView {
        let btn = NavigationLink(destination: CardFormView(title: .constant("Update card"), cardID: self.cardID), label: {
            Text("EDIT").foregroundColor(Color.green)
        }).disabled(self.cardID == nil)
        return AnyView(btn)
    }
}

struct PaymentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentDetailView()
    }
}
