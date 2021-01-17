//
//  ImageUploadThumbnail.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct ImageUploadThumbnail: View {
    @State private var isImageGalleryOpen:Bool = false
    @State private var selectedImage:UIImage? = nil
    @State private var uploadedImageThumbnail:Image? = nil
    @Binding var onSelected:((UIImage)->Void)
    var defaultButtonLabel:AnyView? = nil
    var body: some View {
        ZStack {
            Button(action:{
                self.isImageGalleryOpen.toggle()
            }, label:{
                if self.selectedImage == nil {
                    ZStack {
                        Group {
                            if self.defaultButtonLabel != nil {
                                self.defaultButtonLabel
                            }else{
                                Circle().stroke(Color.white, lineWidth: 1) .frame(width:90, height:90).foregroundColor(Color.black)
                                VStack(spacing:0) {
                                    Text("+").foregroundColor(Color.white)
                                    Text("upload").font(.system(size: 12, weight: .light, design: .default)).foregroundColor(Color.white)
                                }
                            }
                        }
                    }
                }else{
                    VStack(spacing:0) {
                        Image(uiImage: self.selectedImage!)
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:100)
                            .clipShape(Circle())
                            .overlay(Circle().frame(width:100, height:100).opacity(0)).clipped()
                        
                        Button(action: {
                            self.isImageGalleryOpen.toggle()
                        }, label: {
                            Text("Update")
                        })
                    }
                }
            })
        }.sheet(isPresented: self.$isImageGalleryOpen, onDismiss: onSelectedImage) {
            ImagePickerView(image: self.$selectedImage)
        }
    }
    private func onSelectedImage() {
        if let selectedImage = self.selectedImage {
            self.onSelected(selectedImage)
            self.uploadedImageThumbnail = Image(uiImage: selectedImage)
        }
    }
}

struct ImageUploadThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadThumbnail(onSelected: .constant({ image in
            
        }))
    }
}
