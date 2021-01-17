//
//  AppState.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/2/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

class AppState : ObservableObject {
    @Published var system = System()
    
}

extension AppState {
    struct System : Equatable {
        var showLoading:Bool = false
    }
}
