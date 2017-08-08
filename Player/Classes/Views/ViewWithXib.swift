//
//  ViewWithXib.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

class ViewWithXib: UIView {

	func initUI() {}
	
	private func xibSetup() {
		let view = loadViewFromNib()
		view.frame = bounds
		view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
		addSubview(view)
		initUI()
	}
	
	private func loadViewFromNib() -> UIView {
		let thisName = String(describing: type(of: self))
		let view = Bundle(for: self.classForCoder).loadNibNamed(thisName, owner: self, options: nil)?.first as! UIView
		return view
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		xibSetup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		xibSetup()
	}

}
