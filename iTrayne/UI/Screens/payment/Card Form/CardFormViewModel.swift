//
//  CardFormViewModel.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

class CardFormViewModel:ObservableObject {
    @Published var cardStore:CardStore = CardStore()
    
    @Published var alertTitle:String = "One Problem"
    @Published var alertMessage:String = ""
    @Published var showAlert:Bool = false
    
    
//    func clearForm() {
//        self.number = ""
//        self.exp_month = ""
//        self.exp_year = ""
//        self.cvc = ""
//    }
    
}
