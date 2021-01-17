//
//  ProfileView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/7/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @State var selectCard:Bool = false
    @State var trainer:Profile? = nil
    @State var location:Location = Location()
    @ObservedObject var trainerStore:TrainerStore = TrainerStore()
    @ObservedObject var placeStore:PlacesStore = PlacesStore()
    @State var didGoOffline:Bool = false
    @Binding var trainerId:String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var showProfile:Bool
    @Binding var showAppointment:Bool
    @EnvironmentObject var profileStore:ProfileStore
    
    func getTrainer() {
        self.profileStore.getProfileByUserId(userId: self.trainerId, success: { trainer in
            self.trainer = trainer
        })
    }
    
    private func isOnline() {
        guard let trainer = self.trainer else{ return } 
        if trainer.isOnline {
            self.didGoOffline = false
        }else{
            self.didGoOffline = true
        }
    }
    
    var body: some View {
        NavigationView {
                ZStack(alignment:.topLeading) {
                    Color.black.edgesIgnoringSafeArea(.all)
                    ZStack(alignment:.topLeading) {
                        VStack(alignment:.leading) {
                            HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(true), hasBackBtn: .constant(true), title: .constant(""), isModal:true, onClickBack:{
                                self.showProfile.toggle()
                            }, exitScreen: .constant(false))
                            
                             ScrollView {
                                
                                if (self.trainer != nil) {
                                    ProfileInfoView(trainer: .constant(self.trainer!))
                                }
                                
                               
                                Spacer().frame(height:10)
                                HStack(alignment:.top, spacing: 0) {
                                    Text(self.trainer?.bio ?? "No bio").foregroundColor(Color.white)
                                    Spacer()
                                }.padding(.horizontal).frame(minWidth: 0, maxWidth: .infinity)
                                Spacer().frame(height:30)
                                Hr()
                                TextLayoutView(headline: .constant("TRAINING LOCATION"), title: .constant(self.location.name), subtitle: .constant("\(self.location.city), \(self.location.state)"), footerText: .constant("Location will be showen after you book and approve."))
        //                        HStack(alignment:.top) {
        //                            TextLayoutView(headline: .constant("TRAINING DATE"), title: .constant("07/30/2020"), subtitle: .constant(""), footerText: .constant(""))
        //                            TextLayoutView(headline: .constant("TRAINING LENGTH"), title: .constant("1 hour training"), subtitle: .constant(""), footerText: .constant(""))
        //                        }
                                Spacer()
                            }
                        }
                    }.zIndex(1)
                    ZStack(alignment:.bottomLeading) {
                        VStack {
                            Spacer()
                            ZStack {
                                VStack(alignment:.leading, spacing: 0) {
                                    Spacer().frame(height:10)
                                    NavigationLink(destination:ConfirmationView(trainerId: self.trainerId, showProfile: self.$showProfile, showAppointment: self.$showAppointment)
                                        .environmentObject(MapListViewModel())
                                        .environmentObject(CheckoutStore()).environmentObject(LocationStore()).environmentObject(SessionStore()).environmentObject(ProfileStore()) ,
                                        label: {
                                        Text("Book Now and checkout").fontWeight(.semibold)
                                            .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                                    })
                                    .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(50).padding()
                                        .alert(isPresented: $didGoOffline) {
                                            Alert(title: Text("Sorry"), message: Text("The trainer went offline and ended this training session, sorry."), dismissButton: .cancel(Text("Find another trainer"), action: {
                                                self.presentationMode.wrappedValue.dismiss()
                                            }))
                                    }
                                    Spacer().frame(height:30)
                                }
                            }.background(Color("Hr"))
                        }
                    }.zIndex(10).edgesIgnoringSafeArea(.all)
                }
                .navigationBarHidden(true)
                .navigationBarTitle("")
                .onAppear(perform: self.getTrainer)
        }
    }
}

struct TextLayoutView: View {
    
    @Binding var headline:String
    @Binding var title:String
    var largeTitle:String = ""
    @Binding var subtitle:String
    @Binding var footerText:String
    var showDivider:Bool = true
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack(alignment:.top) {
                VStack(alignment:.leading, spacing: 0) {
                    
                    
                    if !self.headline.isEmpty {
                         Spacer().frame(height:30)
                         Text(self.headline).font(.system(size: 12, weight: .bold, design: .default)).foregroundColor(Color("green"))
                    }
                    
                    if self.headline.isEmpty {
                        Spacer().frame(height:30)
                    }else{
                        Spacer().frame(height:20)
                    }
                   
                    if !self.title.isEmpty {
                        
                        Text(self.title).font(.system(size: 22, weight: .bold, design: .default)).foregroundColor(Color.white)
                    }
                    
                    if !self.largeTitle.isEmpty {
                        Text(self.largeTitle).font(.system(size: 30, weight: .bold, design: .default)).foregroundColor(Color.white)
                    }
                    
                    
                    if !self.subtitle.isEmpty {
                        Spacer().frame(height:5)
                        Text(self.subtitle).font(.system(size: 20, weight: .ultraLight, design: .default)).foregroundColor(Color.white)
                    }
                    if !self.footerText.isEmpty {
                        Spacer().frame(height:20)
                        Text(self.footerText).font(.system(size: 12, weight: .regular, design: .default)).foregroundColor(Color.gray)
                    }
                    
                    Spacer().frame(height:30)
                }
                Spacer()
            }.padding(.horizontal).frame(minWidth: 0, maxWidth: .infinity)
            if self.showDivider {
                Hr()
            }
        }

    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(trainerId: .constant(""))
//    }
//}
