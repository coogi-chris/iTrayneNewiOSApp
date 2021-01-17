//
//  CellHeaderView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct CellHeaderView: View {
    
    @Binding var label:String
    
    var body: some View {
        ZStack(alignment:.leading) {
            Color.white.opacity(0.1)
            Text(self.label).foregroundColor(Color.white).padding(.horizontal).font(.system(size: 12, weight: .bold, design: .default))
        }
        .frame(height:55)
    }
}

struct CellHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CellHeaderView(label: .constant("General"))
    }
}
