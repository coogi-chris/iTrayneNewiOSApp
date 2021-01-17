//
//  AuthFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/31/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct AuthFormView: View {
    
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var error:Bool = false
    @ObservedObject var reAuth = SessionStore.ReAuth()
    @State private var showingAlert:Bool = false
    @State private var alertErrorMessage:String = ""
    @State private var alertTitle:String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Image("logo").resizable().frame(width:217,height:91)
                Rectangle()
                    .fill(Color("input_color"))
                .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                Spacer().frame(height:30)
                Text("Log in to your account")
                    .font(.headline)
                    .foregroundColor(.white)
                     .frame(minWidth:0, maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                VStack {
                    TextField("Email", text: $email)
                        .foregroundColor(.white)
                        .padding(10)
                    Rectangle()
                        .fill(Color("dividerColor"))
                    .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                }.padding(.horizontal, 20)
                VStack {
                    SecureField("Password", text: $password)
                        .foregroundColor(.white)
                        .padding(10)
                    
                }.padding(.horizontal, 20)
                Button(action:{
                    self.reAuth.withEmailAndPassword(email: self.email, password: self.password,
                    success:{ auth in
                        print(auth)
                    },
                    error: { error in
                        print(error)
                    })
                }, label: {
                    Text("Log In").fontWeight(.semibold)
                        .foregroundColor(.black)
                })
                .frame(minWidth:0, maxWidth: .infinity, minHeight: 55)
                .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(50)
                .padding(.horizontal, 20)
                    .alert(isPresented:self.$reAuth.showHTTPAlert){
                    Alert(title: Text(self.reAuth.HTTPAllertTitle), message: Text(self.reAuth.HTTPAlertMessage), dismissButton: .default(Text("Got it!")){
                       
                    })
                }
            }
        }
    }
}

struct AuthFormView_Previews: PreviewProvider {
    static var previews: some View {
        AuthFormView()
    }
}
