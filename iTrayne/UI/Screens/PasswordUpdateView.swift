//
//  PasswordUpdateView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/31/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct PasswordUpdateView: View {

    @State private var newPassword:String = ""
    @State private var confirmNewPassword:String = ""
    @ObservedObject var password = SessionStore.UpdatePassword()
    @State var success:Bool = false
    @State var error:Bool = false
    @State var passwordDontMatch:Bool = false
    @State var showAlert:Bool = false
    @State var emptyField:Bool = false
    @State var isLoading:Bool = false
    
    var body: some View {
    ZStack {
              Color("backgroundBlack").edgesIgnoringSafeArea(.all)
              VStack {
                  VStack {
                      
                     HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Change password"), exitScreen: .constant(false))

                    VStack {
                        TextField("New Password", text: $newPassword)
                            .foregroundColor(.white)
                            .padding(10)

                        Rectangle().fill(Color("dividerColor")).frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    }.padding(.horizontal, 20)
                    

                    VStack {
                        TextField("Confirm New Password", text: $confirmNewPassword)
                            .foregroundColor(.white)
                            .padding(10)

                        Rectangle().fill(Color("dividerColor")).frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                    }.padding(.horizontal, 20)
                      
                      Spacer().frame(height:30)
                      
                      Button(action:{
                        
                        self.success = false
                        self.showAlert = false
                        self.passwordDontMatch = false
                        
                        if self.newPassword.isEmpty || self.confirmNewPassword.isEmpty {
                            self.emptyField = true
                            self.showAlert = true
                        }else{
                            if self.newPassword != self.confirmNewPassword {
                                self.passwordDontMatch = true
                                self.showAlert = true
                                self.emptyField = false
                            }else{
                                self.isLoading = true
                                self.emptyField = false
                                self.password.update(password:self.newPassword, success: {
                                    self.isLoading = false
                                    self.success = true
                                    self.showAlert = true
                                    
                                    self.newPassword = ""
                                    self.confirmNewPassword = ""
                                    
                                }, error: { error in
                                    self.isLoading = false
                                    self.success = false
                                    self.showAlert = true
                                })
                            }

                        }

                      }, label: {
                        Text(self.isLoading ? "Updating..." : "Update").fontWeight(.semibold)
                              .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                      })
                      
                      .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                      .cornerRadius(50)
                      .padding(.horizontal, 20)
                        .disabled(self.isLoading)
                        .alert(isPresented:$showAlert) {
 
                            if self.success {
                               return Alert(title: Text("Success"), message: Text("Password Updated"), dismissButton: .cancel(Text("Got it!")))
                            }else if self.emptyField {
                                 return Alert(title: Text("Error"), message: Text("Complete password and password confirm field"), dismissButton: .cancel(Text("Got it!")))
                            }else if self.passwordDontMatch {
                                return Alert(title: Text("Error"), message: Text("Passwords dont match"), dismissButton: .cancel(Text("Got it!")))
                            }else{
                                return Alert(title: Text("Error"), message: Text(self.password.HTTPAlertMessage), dismissButton: .cancel(Text("Got it!")))
                            }
                    
                        }
                    
                      Spacer().frame(height:50)

                      
                  }
                  Spacer()
              }
              
          }.navigationBarHidden(true).navigationBarTitle("")
    }
}

struct PasswordUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordUpdateView()
    }
}
