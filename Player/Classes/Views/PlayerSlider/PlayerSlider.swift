//
//  PlayerSlider.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

protocol PlayerSliderProtocol: class {
	func onValueChanged(progress: Float, timePast: TimeInterval)
}

class PlayerSlider: ViewWithXib {

    // MARK: Constants
    
    private let maximumUnitCount = 2
    private let sliderMinimumValue: Float = 0
    private let sliderMaximumValue: Float = 1.0
    
    // MARK: Properties
    
    var delegate: PlayerSliderProtocol?
    var duration: TimeInterval = TimeInterval() {
        didSet {
            updateProgress(self.progress)
        }
    }
    
    var progress: Float {
        set(newValue) {
            guard !isDragging else {
                return
            }
            updateProgress(newValue)
        }
        
        get {
            return _progress
        }
    }
    
    private var _progress: Float = 0
    private var isDragging = false
    
    // MARK: Outlets
    
	@IBOutlet private weak var pastLabel: UILabel!
	@IBOutlet private weak var remainLabel: UILabel!
    @IBOutlet private weak var sliderView: UISlider!
    @IBAction private func sliderValueDidChanged(_ sender: Any) {
        updateProgress(sliderView.value)
    }
    
    // MARK:
	private func updateProgress(_ progress: Float) {
		var actualValue = progress >= sliderMinimumValue ? progress: sliderMinimumValue
		actualValue = progress <= sliderMaximumValue ? actualValue: sliderMaximumValue
		
		self._progress = actualValue
	
		self.sliderView.value = actualValue
		
		let pastInterval = Float(duration) * actualValue
		let remainInterval = Float(duration) - pastInterval

		self.pastLabel.text = intervalToString(TimeInterval(pastInterval))
		self.remainLabel.text = intervalToString(TimeInterval(remainInterval))
	}
	
	private func intervalToString (_ interval: TimeInterval) -> String? {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.minute, .second]
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = .pad
		formatter.maximumUnitCount = maximumUnitCount
		return formatter.string(from: interval)
	}
	
	override func initUI() {
		super.initUI()
		self.sliderView.addTarget(self, action: #selector (dragDidBegin), for: .touchDragInside)
		self.sliderView.addTarget(self, action: #selector (dragDidEnd), for: .touchUpInside)
		self.sliderView.setThumbImage(UIImage(named: Images.sliderThumb, in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
	}
	
	@objc private func dragDidBegin() {
		isDragging = true
	}
	
	@objc private func dragDidEnd() {
		self.isDragging = false
		self.notifyDelegate()
	}
	
	private func notifyDelegate() {
		let timePast = self.duration * Double(sliderView.value)
		self.delegate?.onValueChanged(progress: sliderView.value, timePast: timePast)
	}
	
}
