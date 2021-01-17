//
//  UserListView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/15/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct UserListView: View {
    
    @Binding var trainers:[Profile]
    @Binding var onTap:((String)->Void)
    @Binding var openMenu:Bool
    @Binding var showAddresses:Bool
    
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color.black
            if self.trainers.isEmpty {
                Spacer().frame(height:60)
                Hr()
                Spacer().frame(height:50)
                Text("No trainers are available right now").foregroundColor(.white).font(.system(size: 22, weight: .regular, design: .default)).padding()
            }else{
                VStack(alignment:.leading, spacing: 0) {
                    ScrollView(.vertical) {
                        VStack(spacing:0) {
                            Spacer().frame(height:40)
                            Text("On-Demand Trainers").font(.system(size: 20, weight: .black, design: .default)).foregroundColor(.white).frame(minWidth:0, maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                            Spacer().frame(height:20)
                            
                            ForEach(self.trainers, id:\.id){ (trainer:Profile) in
                                Button(action: {
                                    self.onTap(trainer.id ?? "No ID")
                                }, label: {
                                    UserCell(trainer: .constant(trainer))
                                })

                            }
                        }
                    }
                }
            }
            
        }
    }
}

struct UserCell : View {
    
    @Binding var trainer:Profile
    
    var body : some View {
        ZStack(alignment:.topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack (spacing:0) {
                ProfileInfoView(trainer: $trainer)
                Hr()
            }
        }
    }
    
}

struct ProfileInfoView: View {
    
    @Binding var trainer:Profile
    
    var body: some View {
        HStack {
            HStack {
                if self.trainer.profileURL.isEmpty {
                    Image("avatar").resizable().frame(width:40, height: 40)
                }else{
                    self.avatar(profileURL: URL(string:self.trainer.profileURL)!)
                }
                Spacer().frame(width:15)
                VStack(alignment:.leading, spacing: 2) {
                    Text(trainer.firstName).foregroundColor(.white).font(.system(size: 18, weight: .bold, design: .default))
//                    Text(trainer.city).foregroundColor(.gray).font(.system(size: 12, weight: .regular, design: .default)).foregroundColor(.gray)
                }
                Spacer()
            }
            VStack {
                Spacer()
                Text("\(self.centsToDollars(cents: self.trainer.hourlyPrice)) / hr").foregroundColor(.white).font(.system(size: 20, weight: .light, design: .default))
                Spacer()
            }
        }.padding(15)
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
    
    func noAvatar() -> some View {
        VStack {
            Image("image-placeholder").renderingMode(.original).resizable().frame(width:100, height: 100).cornerRadius(100)
            Spacer().frame(height:30)
            Hr()
        }
    }
    
    func avatar(profileURL:URL) -> some View {
        ThumbnailImageView(imageURL: .constant(profileURL)).frame(width:40, height: 40)
    }
    
    
}

//struct UserListView_Previews: PreviewProvider {
//    static var previews: some View {
//        //UserListView(trainer: .constant(nil))
//    }
//}
