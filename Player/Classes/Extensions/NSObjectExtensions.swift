//
//  NSObjectExtensions.swift
//  Player
//
//  Created by Boris Bondarenko on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
