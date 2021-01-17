//
//  ContentView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/5/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginForm: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var error:Bool = false
    @EnvironmentObject var signIn:SessionStore
    @State private var showingAlert:Bool = false
    @State private var alertErrorMessage:String = ""
    @State private var alertTitle:String = ""
    @State private var loading:Bool = false
    var body: some View {
        NavigationView {
            ZStack {
            Color("backgroundBlack").edgesIgnoringSafeArea(.all)
                    VStack {
                        VStack {
                            Image("logo").resizable().aspectRatio(contentMode: .fit).frame(width:180)
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
                                self.loading = true
                                self.signIn.signInUser(email: self.email, password: self.password,
                                success: { auth in
                                    self.loading = false
                                }, error:{ error in
                                    self.loading = false
                                })
                            }, label: {
                                Text(self.loading ? "Logging in..." : "Log In").fontWeight(.semibold)
                                    .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                            })
                            .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(50)
                            .padding(.horizontal, 20)
//                                .alert(isPresented:self.$signIn.showHTTPAlert){
//                                Alert(title: Text(self.signIn.HTTPAllertTitle), message: Text(self.signIn.HTTPAlertMessage), dismissButton: .default(Text("Got it!")){
//
//                                })
//                            }
                            .disabled(self.loading)
                        }
                        Spacer().frame(height:50)
                       NavigationLink(destination:ForgotPasswordView(), label: {
                           return Text("Forgot your password?")
                           .foregroundColor(Color("link_color"))
                       
                       })
                        Spacer()
                        VStack {
                            HStack {
                                Rectangle()
                                    .fill(Color("input_color"))
                                .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                                Text("OR")
                                    .foregroundColor(.white)
                                Rectangle()
                                    .fill(Color("input_color"))
                                .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                            }.padding(.horizontal, 20)
                            Spacer().frame(height:15)
                            NavigationLink(destination: SignupFormView(), label: {
                                Text("Create New Account").fontWeight(.semibold)
                                    .foregroundColor(Color("link_color"))
                            })
                            .frame(minWidth:0, maxWidth: .infinity, minHeight: 55)
                            .background(Color("secondaryBtnColor"))
                            .cornerRadius(50)
                            .padding(.horizontal, 20)
                        }
                        Spacer().frame(height:25)
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top])
        }


}



//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//         LoginForm()
//    }
//}

