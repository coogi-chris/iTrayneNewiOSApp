//
//  CardFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/5/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct CardFormView: View {
    
    @Binding var title:String
    var cardID:String? = nil
    @ObservedObject var viewModel:CardFormViewModel = CardFormViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var goBack:Bool = false
    @State var card:Card = Card()
    @State var saving:Bool = false
    @State var loaded:Bool = false
    
    func getDebitCard() {
        if let id = self.cardID {
            self.viewModel.cardStore.getCardByID(cardId: id, success: { card in
                self.card = card
                self.loaded.toggle()
            }, error: { errMessage in
                self.loaded.toggle()
            })
        }else{
            self.loaded.toggle()
        }
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment:.leading, spacing: 0) {
                HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: $title, exitScreen: .constant(false))
                if self.loaded {
                        Spacer().frame(height:5)
                        VStack(alignment:.leading, spacing:10) {
                                VStack(spacing:0) {
                                    ZStack {
                                        if self.isUpdatingCard() {
                                            TextField("16 digit card number \(self.card.last4)", text: self.$card.last4).foregroundColor(.gray).padding(10).disabled(true)
                                        }else{
                                            TextField("16 digit card number", text: self.$card.number).foregroundColor(.white).padding(10)
                                        }
                
                                    }.padding(.horizontal, 20)
                                    Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                }
                                
                                Group{
                                    HStack(spacing:0) {
                                        VStack(spacing:0) {
                                            ZStack {
                                                TextField("Exp Month", text: self.$card.exp_month).foregroundColor(.white).padding(10)
                                            }.padding(.horizontal, 20)
                                            Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                        }
                                        VStack(spacing:0) {
                                            ZStack {
                                                TextField("Exp Year", text: self.$card.exp_year).foregroundColor(.white).padding(10)
                                            }.padding(.horizontal, 20)
                                            Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                        }
                                    }
                                }
                                if !self.isUpdatingCard() {
                                    VStack(spacing:0) {
                                        ZStack {
                                            TextField("CVC", text: self.$card.cvc).foregroundColor(.white).padding(10)
                                        }.padding(.horizontal, 20)
                                        Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                    }
                                }
                            
                        }
                }else{
                    Text("Loading...").foregroundColor(Color.white).padding(20)
                }

                Spacer().frame(height:40)
                
                
                if self.loaded {
                   self.actionBtn()
                }
            
        
                Spacer()
            }.onAppear(perform: {
                self.getDebitCard()
            }).onDisappear {

            }
        }.navigationBarHidden(true).navigationBarTitle("")
    }
    
    private func isUpdatingCard() -> Bool {
        return self.cardID != nil
    }
    
    private func actionBtn() -> some View {
        Button(action:{
                           
                           if !self.isUpdatingCard() {
                               guard !self.card.number.isEmpty else{
                                   self.viewModel.alertMessage = "Number Required"
                                   self.viewModel.showAlert.toggle()
                                   return
                               }
                               

                               guard !self.card.cvc.isEmpty else{
                                   self.viewModel.alertMessage = "CVC Required"
                                   self.viewModel.showAlert.toggle()
                                   return
                               }
                           }
                           
                           guard !self.card.exp_month.isEmpty else{
                               self.viewModel.alertMessage = "Exp Month Required"
                               self.viewModel.showAlert.toggle()
                               return
                           }
                           
                           guard !self.card.exp_year.isEmpty else{
                               self.viewModel.alertMessage = "Exp Year"
                               self.viewModel.showAlert.toggle()
                               return
                           }
                           
                           if self.isUpdatingCard() {
                               self.update()
                           }else{
                               self.create()
                           }
                           
                           
                        }, label: {
                           Text(self.saving ? "Saving..." : "Save").fontWeight(.semibold)
                               .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                       })
                       .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                       .alert(isPresented: self.$viewModel.showAlert){
                           Alert(title: Text(self.viewModel.alertTitle), message: Text(self.viewModel.alertMessage), dismissButton: .cancel(Text("Got it"), action: {
                               if self.goBack {
                                   self.presentationMode.wrappedValue.dismiss()
                               }
                           }))
                       }
                       .cornerRadius(50)
                       .padding(.horizontal, 20)
                        .disabled(self.saving)
    }
    
    func update() {
        self.saving.toggle()
        self.viewModel.cardStore.updateCard(cardId:self.cardID ?? "", card: self.card, success: { card in
            self.goBack.toggle()
            //self.viewModel.clearForm()
            self.viewModel.alertTitle = "Success"
            self.viewModel.alertMessage = "Card Updated"
            self.viewModel.showAlert.toggle()
            self.saving.toggle()
        }, error: { errMess in
            self.viewModel.showAlert.toggle()
            self.viewModel.alertTitle = "Error"
            self.viewModel.alertMessage = errMess
            self.saving.toggle()
        })
    }
    
    
    
    func create() {
        self.saving.toggle()
        self.viewModel.cardStore.createCard(card: self.card, success: {
            self.goBack.toggle()
            self.saving.toggle()
            self.viewModel.alertTitle = "Success"
            self.viewModel.alertMessage = "Card Created"
            self.viewModel.showAlert.toggle()
        }, error: { errMess in
            self.viewModel.showAlert.toggle()
            self.viewModel.alertTitle = "Error"
            self.viewModel.alertMessage = errMess
            self.saving.toggle()
        })
    }
    
}

struct CardFormView_Previews: PreviewProvider {
    static var previews: some View {
        CardFormView(title: .constant("Update card"))
    }
}
