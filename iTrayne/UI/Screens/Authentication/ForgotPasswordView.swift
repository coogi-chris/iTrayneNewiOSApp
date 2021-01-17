//
//  ForgotPasswordView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/24/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var email:String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var session = SessionStore()
    @State private var showingAlert:Bool = false
    @State private var signupAlertErrorMessage:String = ""
    @State private var signupAlertTitle:String = ""
    @State private var didSendResetEmail:Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundBlack").edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    Image("logo").resizable().frame(width:217, height: 91)
                    Rectangle()
                        .fill(Color("input_color"))
                    .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    Spacer().frame(height:30)
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.headline)
                        .foregroundColor(.white)
                         .frame(minWidth:0, maxWidth: .infinity)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                    VStack {
                        TextField("Email", text: $email)
                            .foregroundColor(.white)
                            .padding(10)
                        Rectangle()
                            .fill(Color("dividerColor"))
                        .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    }.padding(.horizontal, 20)
                    Button(action:{
                        self.session.resetPassword(email: self.email) { error in
                            if let error = error {
                                self.signupAlertTitle = "Reset Password error"
                                self.signupAlertErrorMessage = error.localizedDescription
                                self.showingAlert = true
                            }else{
                                self.didSendResetEmail = true
                                self.showingAlert = true
                                self.signupAlertTitle = "Check your email"
                                self.signupAlertErrorMessage = "Check your email for a link to get back into your account."
                            }
                        }
                    }, label: {
                        Text("Next").fontWeight(.semibold)
                            .foregroundColor(.black)
                    })
                    .frame(minWidth:0, maxWidth: .infinity, minHeight: 55)
                    .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(50)
                    .padding(.horizontal, 20)
                    .alert(isPresented:$showingAlert){
                        Alert(title: Text(self.signupAlertTitle), message: Text(self.signupAlertErrorMessage), dismissButton: .default(Text("Got it!")){
                            if self.didSendResetEmail {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        })
                    }
                    Spacer().frame(height:50)
                    Button(action : {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        return Text("Already have account? Log in.")
                        .foregroundColor(Color("link_color"))
                    
                    })
                }
                Spacer()
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
