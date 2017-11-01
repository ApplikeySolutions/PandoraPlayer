//
//  Array.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/8/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {
	
	mutating func shuffleInPlace() {
		
		if count < 2 { return }
		
		for i in startIndex ..< endIndex - 1 {
			let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
			if i != j {
				self.swapAt(i, j)
			}
		}
	}
}
