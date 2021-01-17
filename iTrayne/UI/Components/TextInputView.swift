//
//  TextInputView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct TextInputView: View {
    
    var placeholder:String = ""
    @Binding var value:String
    
    var body: some View {
        ZStack {
            Color.black
            VStack(alignment:.leading) {
                if !self.value.isEmpty {
                   TextField("", text: $value)
                    .foregroundColor(.white)
                    .padding(10)
                }else{
                    if !self.placeholder.isEmpty {
                        Text(self.placeholder)
                        .foregroundColor(.gray)
                        .padding(10)
                    }
                }
                Rectangle()
                    .fill(Color("dividerColor"))
                .frame(minWidth:0, maxWidth: .infinity, maxHeight: 1)
                }.padding(.horizontal, 20)
        }
    }
}

struct TextInputView_Previews: PreviewProvider {
    static var previews: some View {
        TextInputView(placeholder: "Email", value: .constant("chris.kendricks07@gmail.com"))
    }
}
