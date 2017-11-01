//
//  WaveVisualizer.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/6/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit
import AudioKitUI

class WaveVisualizer: ViewWithXib {

    private let lineWidth: CGFloat = 2.2

	@IBOutlet private weak var leftWave: EZAudioPlot!
	@IBOutlet private weak var rightWave: EZAudioPlot!

	
	func setColors(left: UIColor, right: UIColor) {
		leftWave.color = left
		rightWave.color = right
	}
	
	func updateWaveWithBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        VisualisationHelper.shared.updateWaveWithBuffer(buffer, withBufferSize: bufferSize, withNumberOfChannels: numberOfChannels, leftWave: leftWave, rightWave: rightWave)
	}
	
    
    // MARK: UI
	
	override func initUI() {
		super.initUI()
		leftWave.color = UIColor.red
		rightWave.color = UIColor.green
		leftWave.waveformLayer.lineWidth = lineWidth
		rightWave.waveformLayer.lineWidth = lineWidth
	}
}

