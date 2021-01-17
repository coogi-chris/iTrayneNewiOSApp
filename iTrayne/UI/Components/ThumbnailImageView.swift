//
//  ThumbnailImageView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/31/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import URLImage

struct ThumbnailImageView: View {
    @State private var placeholder:String = "image-placeholder"
    @Binding var imageURL:URL
    
    var body: some View {
        ZStack {
            URLImage(imageURL,
            processors: [ Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale) ],
            placeholder: {_ in
                Image(self.placeholder).renderingMode(.original)
                    .resizable()                     // Make image resizable
                    .aspectRatio(contentMode: .fit).clipShape(Circle())
                    
                },
            content: {
                $0.image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit).clipShape(Circle())
                    
            })
        }
    }
}

struct ThumbnailImageView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailImageView(imageURL: .constant(URL(string: "gergerg")!))
    }
}
