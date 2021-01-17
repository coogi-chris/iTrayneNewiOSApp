//
//  ProfileFormView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 2/25/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import PhoneNumberKit
import SwiftDate
import Firebase
import CurrencyText

struct ProfileFormView: View {
    
    @State private var firstname:String = ""
    @State private var lastname:String = ""
    @State private var dob:Date = Date()
    @State private var dobString:String = ""
    @State private var phone:String = ""
    @State private var profilePhoto:String = ""
    @State private var bdayTimestamp:Timestamp = Timestamp()
    @State private var bio:String = ""
    @State private var hourlyRate:Int = 1000
    @State private var gender:String = ""
    
    @ObservedObject var fileStore:FileUploadStore = FileUploadStore()
    @EnvironmentObject var profileStore:ProfileStore
    @EnvironmentObject var session:SessionStore
    @State var uploadedImage:UIImage? = nil
    var canExit:Bool = false
    @State var data:[String:Any]? = nil
    @State var isUpdating:Bool = false
    @State var didUpdateProfilePicture:Bool = false
    @State var showAlert:Bool = false
    @State var emptyFields:Bool = false
    @State var success:Bool = false
    @State var showPicker:Bool = false
    @State var countryCode:String = "+1"
    @State var alertTitle:String = ""
    @State var alertMessage:String = ""
    @State var phoneNumberError:Bool = false
    let phoneNumberKit = PhoneNumberKit()
    @State var profile:Profile? = nil
    
    
    enum Gender {
        case male, female
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

    
    func onAppear() {
        self.session.listen {
            if let user = self.session.session {
                self.profileStore.getProfileByUserId(userId: user.uid, success: { profile in
                    if let profile = profile {
                        self.profile = profile
                        self.setForm(profile:profile)
                    }
                })
            }
        }
    }
    
    func setForm(profile:Profile) {
        self.firstname = profile.firstName
        self.lastname = profile.lastName
        self.phone = profile.phone
        self.dobString = profile.birthday.dateValue().date.toFormat("MM / dd / yyyy")
        self.dob = profile.birthday.dateValue()
        self.profilePhoto = profile.profileURL
        self.bio = profile.bio ?? ""
        self.hourlyRate = profile.hourlyPrice
        self.gender = profile.gender
    }
    
    func avatar(profileURL:URL) -> some View {
        VStack {
            ThumbnailImageView(imageURL: .constant(profileURL))
        }
    }
    
    
    

    
    var body: some View {
        ZStack {
            Color("backgroundBlack").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                              VStack {
                    
                                  if self.canExit {
                                    HeaderView(includeMenu: .constant(false), menuBtnToggle: .constant(false), hasLogo: .constant(false), hasBackBtn: .constant(true), title: .constant("Profile"), exitScreen: .constant(false))
                                  }else{
                                      Image("logo").resizable().aspectRatio(contentMode: .fit).frame(width:117)
                                      Rectangle()
                                          .fill(Color("input_color"))
                                      .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                                      Spacer().frame(height:30)
                                      
                                      Text("Complete your profile to continue")
                                          .font(.headline)
                                          .foregroundColor(.white)
                                           .frame(minWidth:0, maxWidth: .infinity)
                                          .multilineTextAlignment(.leading)
                                      Spacer().frame(height:40)
                                  }
                                  VStack {
                                    #if TrainerApp
                                        Text("TRAINER")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    #else
                                        Text("CUSTOMER")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    #endif
    
                                    Text("profile picture").foregroundColor(Color.white).font(.system(size: 10, weight: .light, design: .default))
                                      Group {
                                        if self.hasProfilePhoto() {
                                            ImageUploadThumbnail(onSelected: .constant({ (uiimage) in
                                              self.uploadedImage = uiimage
                                              self.didUpdateProfilePicture = true
                                            }), defaultButtonLabel:AnyView(self.avatar(profileURL: URL(string: self.profile!.profileURL)!))).frame(width:100, height:100)
                                        }else{
                                            Text("new image")
                                             ImageUploadThumbnail(onSelected: .constant({ (uiimage) in
                                                 self.didUpdateProfilePicture = true
                                                 self.uploadedImage = uiimage
                                             })).frame(width:100, height:100)
                                        }
                                      }
                                      Spacer().frame(height:50)

                                  }.padding(.horizontal, 20)
                                
                                VStack{
                                    ZStack {
                                      TextField("First name", text: $firstname).foregroundColor(.white).padding(10)
                                    }.padding(.horizontal, 20)
                                    
                                    Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                    
                                    ZStack {
                                      TextField("Last name", text: $lastname).foregroundColor(.white).padding(10)
                                    }.padding(.horizontal, 20)
                                    
                                    Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                    ZStack {
                                        TextField("Date of Birth", text: $dobString, onEditingChanged: {_ in
                                            self.updateBday()
                                            })
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .disabled(false)
                                        
                                    }.padding(.horizontal, 20)
                                    
                                    Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                    ZStack {
                                        TextField("Phone", text: $phone).foregroundColor(.white).padding(10)
                                    }.padding(.horizontal, 20)
                                    
                                    Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                    
                                    #if TrainerApp
                                    Group {
                                        
                                        HStack {
                                            
                                            Button(action:{
                                                self.gender = "male"
                                            }, label:{
                                                Text("Male").foregroundColor(self.gender == "male" ? Color("green") : Color.white) .frame(minWidth:0, maxWidth: .infinity, minHeight: 40)
                                            })
                                            .cornerRadius(5)
                                            .border(self.gender == "male" ? Color("green") : Color.white, width: 1)
                                            
                                            Button(action:{
                                                self.gender = "female"
                                            }, label:{
                                                Text("Female").foregroundColor(self.gender == "female" ? Color("green") : Color.white).frame(minWidth:0, maxWidth: .infinity, minHeight: 40)
                                            })
                                            .cornerRadius(5)
                                            .border(self.gender == "female" ? Color("green") : Color.white, width: 1)
                                            
                                        }.padding(20)
                                        
                                        Text("About me")
                                            .foregroundColor(.white)
                                            .font(.system(size: 25, weight: .bold, design: .default))
                                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                            .padding(20)
                                        
                                                ZStack {
                                                  TextField("Bio", text: $bio).foregroundColor(.white).padding(10)
                                                }.padding(.horizontal, 20)
                                                Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
                                        Text("Hourly Rate")
                                            .foregroundColor(.white)
                                            .font(.system(size: 25, weight: .bold, design: .default))
                                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                                            .padding(20)
                                        
                                        ZStack {
                                                TextField("Hourly Ratye", value: self.$hourlyRate, formatter: NumberFormatter()).foregroundColor(.white).padding(10)
                                            }.padding(.horizontal, 20)
                                            Rectangle().fill(Color("dividerColor")).frame(height:1).padding(.horizontal, 20)
            
                                    
                                    }

                                    #endif
                                }
                                
                                  Spacer().frame(height:30)
                                  
                                  self.buttonSaveView()
                                
                                  Spacer().frame(height:50)
                             
                                  
                                  //UIButton("CREATE ACCOUNT", .primary)
                                  
                              }
                    Spacer().frame(height:300)
                          }.onAppear(perform: onAppear)
            }
            if self.showPicker {
                VStack(alignment:.leading, spacing:0) {
                    Spacer()
                    VStack(spacing:0) {
                        Rectangle().fill(Color("dividerColor")).frame(height:1)
                        HStack(spacing:0){
                            Spacer()
                            Text("What's your birthday?").font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(.white).padding(20)
                            Spacer()
                        }.background(Color.black)
                        Rectangle().fill(Color("dividerColor")).frame(height:1)
                    }
                    ZStack(alignment:.topLeading) {
                        Rectangle().frame(height:200).background(Color.black)
                        DatePicker(selection: $dob, in: ...Date()) { Text("")
                        }.colorInvert()
                    }
                }
            }

        }.navigationBarHidden(true).navigationBarTitle("")
    }
    

    private func updateBday() {
        self.showPicker.toggle()
        self.dobString = self.dob.date.toFormat("MM / dd / yyyy")
        self.bdayTimestamp = Timestamp(date: self.dob)
    }
    
    func validate(value: String) -> Bool {
            let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
            let result = phoneTest.evaluate(with: value)
            return result
    }
    
    private func buttonSaveView() -> some View {
        Button(action:{

            var profile = Profile(firstName: self.firstname, lastName: self.lastname, phone: self.phone, birthday: self.bdayTimestamp, profileURL: self.profilePhoto, gender: self.gender , bio:self.bio, hourlyPrice:self.hourlyRate)
            
            profile.phone = self.phone
            
            guard !profile.firstName.isEmpty else {
                self.alertTitle = "Sorry"
                self.alertMessage = "First name is required"
                self.showAlert.toggle()
                return
            }
            
            guard !profile.lastName.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Last name is required"
                return
            }
            
            guard !self.dobString.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Date of Birth is required"
                return
            }
            
            guard !profile.phone.isEmpty else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertMessage = "Phone number is required"
                return
            }
            
            #if TrainerApp
                guard !(profile.bio ?? "").isEmpty else {
                    self.showAlert.toggle()
                    self.alertTitle = "Sorry"
                    self.alertMessage = "A bio is required"
                    return
                }

            #endif
            
            guard self.validate(value: profile.phone) else {
                self.showAlert.toggle()
                self.alertTitle = "Sorry"
                self.alertTitle = "Phone number should be formmated like this 555-555-5555"
                return
            }
            
            self.save(profile: profile)
            
        }, label: {
            Text(self.isUpdating ? "Saving..." : "Save").fontWeight(.semibold)
                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
        })
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Done"), action: {
                
            }))
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(50)
        .padding(.horizontal, 20)
        .disabled(self.isUpdating)

    }
    
    func save(profile:Profile) {

        var _profile = profile
        
        guard let user = self.session.session else {
            print("No user")
            return
        }

        guard let newUploadedImage = self.uploadedImage else {
             self.setProfile(profile:_profile)
             return
        }
        
        let photo:ImageUploadFile = ImageUploadFile(image:newUploadedImage, folderName:user.uid, imageName:"profilePhoto")
        
        self.fileStore.uploadImg(imageUpload:photo, success: { imageURL in
            if let imageURL = imageURL {
                _profile.profileURL = imageURL
                self.setProfile(profile:_profile)
            }else{
                print("No image URL");
            }
        }, failed:self.onSetDataError)

    }

    private func isFieldEmpty() -> Bool {
        return self.firstname.isEmpty || self.lastname.isEmpty || self.phone.isEmpty
    }
    
    private func setProfile(profile:Profile) {
        self.isUpdating = true
        self.profileStore.updateOrCreateProfile(profile: profile, success:self.onSetDataSuccess, error:self.onSetDataError)
    }
    
    private func onSetDataSuccess() {
        self.isUpdating = false
        self.alertTitle = "Success"
        self.alertMessage = "Your profile saved"
        self.showAlert.toggle()
    }
    
    private func onSetDataError(error:Error) {
        self.isUpdating = false
        self.alertTitle = "Error"
        self.alertMessage = error.localizedDescription
        self.showAlert.toggle()
    }
    
    private func hasProfilePhoto() -> Bool {
        return (self.profile != nil && URL(string: self.profile!.profileURL) != nil)
    }
}

struct ProfileFormView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFormView().environmentObject(SessionStore()).environmentObject(ProfileStore())
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
