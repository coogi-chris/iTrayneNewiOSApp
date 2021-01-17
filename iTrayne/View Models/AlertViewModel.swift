//
//  AlertViewModel.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/10/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation


class AlertViewModel: ObservableObject {
    @Published var title:String = ""
    @Published var message:String = ""
    @Published var showAlert:Bool = false
}
