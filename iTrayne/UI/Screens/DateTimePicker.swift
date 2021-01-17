//
//  DateTimePicker.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 7/18/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct DateTimePicker: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var checkout:CheckoutStore
    @Binding var date:Date
    var title:String = ""
    var buttonLabel:String = "Next"
    var onClickButton:((Date)->Void)? = nil
    var navigateOnClickTo:AnyView? = nil
    
    var body: some View {
        ZStack {
             Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}, label:{
                        Image("back")
                        .renderingMode(.original)
                         .resizable().frame(width:18, height:18)
                    })
                    Spacer()
                    Text("Date & Time").foregroundColor(.white).fontWeight(.bold)
                    Spacer()
                }.padding()
                Spacer().frame(height:30)
                Text(self.title)
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .foregroundColor(Color.white)
                    .padding()
                Spacer().frame(height:30)
                DatePicker("sacsvdsvsdvs", selection: self.$date).labelsHidden()
                .colorInvert()
                Spacer()
                Group {
                    Spacer().frame(height:30)
                    
                    if self.navigateOnClickTo != nil {
                            NavigationLink(destination:self.navigateOnClickTo!.environmentObject(self.checkout), label: {
                                Text(self.buttonLabel).fontWeight(.semibold)
                                    .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                            })
                            .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(50)
                            .padding(.horizontal, 20)
                    }else{
                        Button(action:{
                            if let onclickBtn = self.onClickButton {
                                onclickBtn(self.date)
                            }
                        }, label: {
                            Text(self.buttonLabel).fontWeight(.semibold)
                                .foregroundColor(.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 60)
                        })
                        .background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(50)
                        .padding(.horizontal, 20)
                    }
                    

                    
                    

                    
                }
            }
        }.navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

struct DateTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        DateTimePicker(date: .constant(Date()))
    }
}
