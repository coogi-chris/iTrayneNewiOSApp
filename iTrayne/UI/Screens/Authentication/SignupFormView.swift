//
//  SignupFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/7/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import Firebase

struct SignupFormView: View {
    
    @State private var fullname:String = ""
    @State private var email:String = "test@gmail.com"
    @State private var password:String = "password"
    @State private var passwordConfirm:String = ""
    
    @State private var showingSignupAlert:Bool = false
    @State private var signupAlertErrorMessage:String = ""
    @State private var signupAlertTitle:String = ""
    
    @State private var signupComplete:Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sessionStore:SessionStore
    @State private var loading:Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundBlack").edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                     Image("logo").resizable().aspectRatio(contentMode: .fit).frame(width:180)
                    Rectangle()
                        .fill(Color("input_color"))
                    .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    Spacer().frame(height:30)
        
                    
                    Text("Maximize the way you train")
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
                        Rectangle()
                            .fill(Color("input_color"))
                        .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    }.padding(.horizontal, 20)
                    
                    VStack {
                        SecureField("Enter password again", text: $passwordConfirm)
                        .foregroundColor(.white)
                        .padding(10)
                    }.padding(.horizontal, 20)
                    
                    Button(action:{
                        self.loading = true
                        
                        #if TrainerApp
                        self.sessionStore.signupBusiness(email: self.email, password: self.password,err:{ error in
                            self.loading = false
                        })
                        #else
                            self.sessionStore.signupCustomer(email: self.email, password: self.password,err:{ error in
                                self.loading = false
                            })
                        #endif

                    }, label: {
                        Text(self.loading ? "Creating Account..." : "Create Account").fontWeight(.semibold)
                            .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                    })
                    .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(50)
                    .padding(.horizontal, 20)
                    }.disabled(self.loading)
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


//struct SignupFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignupFormView().environmentObject(SessionStore())
//    }
//}
