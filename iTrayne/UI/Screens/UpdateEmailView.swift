//
//  UpdateEmailView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/4/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct UpdateEmailView: View {
    @State var email:String = ""
    @State var isUpdating:Bool = false
    @EnvironmentObject var session:SessionStore
    
    
    func getUser(){
        self.session.listen()
        if let user = self.session.session {
            self.email = user.email!
        }
    }
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Update email"), exitScreen: .constant(false))
                ZStack {
                  TextField("Email", text: $email).foregroundColor(.white).padding(10)
                }.padding(.horizontal, 20)
                Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                Spacer().frame(height:30)
                Button(action: {
                    self.isUpdating = true
                    self.session.updateEmail(email: self.email, success: {
                        self.isUpdating = false
                    }, error: { error in
                        self.isUpdating = false
                    })
                }, label: {
                    Text(self.isUpdating ? "Saving..." : "Save")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                }).background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(50)
                .padding(.horizontal, 20)
                .disabled(self.isUpdating)
                .alert(isPresented:self.$session.showHTTPAlert){
                        Alert(title: Text(self.session.HTTPAllertTitle), message: Text(self.session.HTTPAlertMessage), dismissButton: .default(Text("Got it!")){
                    })
                }
            }
            }.navigationBarHidden(true).navigationBarTitle("").onAppear(perform: getUser)
    }
}

struct UpdateEmailView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateEmailView()
    }
}
