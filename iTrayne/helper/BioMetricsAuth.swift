//
//  BioMetricsAuth.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/12/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

import LocalAuthentication

protocol Biometrical:ObservableObject  {
    var isSuccessfullyAuthenticated:Bool{ get set }
}

class BioMetricsAuth:Biometrical, ObservableObject {
    
    internal init(isSuccessfullyAuthenticated: Bool = false) {
        self.isSuccessfullyAuthenticated = isSuccessfullyAuthenticated
    }
    
    var isSuccessfullyAuthenticated: Bool
    
    static func Authenticate() {
        let context = LAContext()
        var error: NSError?
         
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
        
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                    } else {
                        // there was a problem
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
}



