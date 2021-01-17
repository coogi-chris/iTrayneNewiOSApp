//
//  SettingsView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var title:String = "Settings"
    @State private var hasBackBtn:Bool = true
    @State var locationSearchService = LocationSearchService()
    
    var stackItems:[VStackMenuItem] = [
        VStackMenuItem(
            header: AnyView(CellHeaderView(label: .constant("General"))),
            views: [
                AnyView(CellView(label: .constant("Update Email"), isDestinationLink: true, destination: AnyView(UpdateEmailView()), rightLabel: .constant(""))),
                AnyView(CellView(label: .constant("Addresses"), isDestinationLink: true, destination: AnyView(AddressListView(locationSearchService: LocationSearchService())), rightLabel: .constant(""))),
                AnyView(CellView(label: .constant("Edit Profile"), isDestinationLink: true, destination: AnyView(ProfileFormView(canExit:true)), rightLabel: .constant(""))),
                AnyView(CellView(label: .constant("Change Password"), isDestinationLink: true, destination:AnyView(PasswordUpdateView()), rightLabel: .constant(""))),
                AnyView(CellView(label: .constant("Payment"), isDestinationLink: true, destination: AnyView(CardListView()), rightLabel: .constant("")))
            ]
        )
    ]
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(alignment:.leading) {
                HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: $hasBackBtn, title: $title, exitScreen: .constant(false))
                ScrollView {
                   VStackMenuView(stackItems: .constant(stackItems))
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
