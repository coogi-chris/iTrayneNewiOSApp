//
//  CardListView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/4/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct CardListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var isSelectable:Bool = false
    var onSelect:((Card)->Void)? = nil
    @ObservedObject var cardStore:CardStore = CardStore()
    @State var isLoading:Bool = true
    @State var cards:[Card] = []
    
    func onAppear() {
        self.getCards()
    }
    
    func getCards() {
        self.isLoading = true
        self.cardStore.getAllCards(success: { cards in
            self.cards = cards
            self.isLoading = false
        }, error: { errMessage in
            self.isLoading = false
        })
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment:.leading,spacing:0) {
                if self.isSelectable {
                    HStack {
                        Text("Select a card").foregroundColor(.white).padding()
                        Spacer()
                    }
                    Hr()
//                     HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(false), title: .constant("Select a card"))
                }else{
                     HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Cards"), rightView:createCardButton(), exitScreen: .constant(false))
                }
                VStack(alignment:.leading, spacing: 0) {
                    if self.isLoading {
                        Text("Loading...").foregroundColor(Color.white).padding(20)
                    }else{
                        if !self.cards.isEmpty {
                            ForEach(self.cards) { (card:Card) in
                                if self.isSelectable {
                                    if self.onSelect != nil {
                                        Button(action: {
                                            if let onSelect = self.onSelect {
                                                onSelect(card)
                                            }
                                            self.presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            CardCell(last4:card.last4)
                                        })
                                    }
                                }else{
                                    NavigationLink(destination: PaymentDetailView(cardID: card.id), label: {
                                        CardCell(last4:card.last4)
                                    })
                                }
                            }
                        }else{
                            Text("No cards").foregroundColor(Color.white).padding(20)
                        }
                    }
                }
            }.onAppear(perform: {
                self.onAppear()
            })
        }.navigationBarHidden(true).navigationBarTitle("")
    }
    
    func createCardButton() -> AnyView {
        let btn = NavigationLink(destination: CardFormView(title: .constant("Add card")), label: {
            Text("+").foregroundColor(Color.green).font(.largeTitle)
        })
        return AnyView(btn)
    }
}

struct CardCell: View {
    var last4:String = ""
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack(alignment:.top) {
                 Image("card").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:20, height: 20)
                 Spacer().frame(width:20)
                 Text(self.last4).foregroundColor(Color.white)
                 Spacer()
                Image("chevron").resizable().frame(width:18, height:18).foregroundColor(.gray)
             }.padding()
            Rectangle().fill(Color("dividerColor")).frame(height:1)
        }

    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
