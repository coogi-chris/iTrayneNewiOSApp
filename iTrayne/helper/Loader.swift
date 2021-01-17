//
//  Loader.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/12/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation



enum Loader<T> {
    case notRequested
    case loading(last:T?)
    case loaded
    case error
}
