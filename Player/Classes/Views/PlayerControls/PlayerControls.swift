//
//  PlayerControls.swift
//  Player
//
//  Created by Boris Bondarenko on 6/1/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit


protocol PlayerControlsDelegate: class {
	func onRepeat()
	func onRewindBack()
	func onPlay()
	func onRewindForward()
	func onShuffle()
}

class PlayerControls: ViewWithXib {
    
    enum Status {
        case Loading
        case Ready
    }
    
    // MARK: Constants
    
    private let defaultAlpha: CGFloat = 0.5

    // Properties
    
	weak var delegate: PlayerControlsDelegate?
    
    var status: Status = .Loading {
        didSet {
            updateStatus()
        }
    }
    
	var isPlaying: Bool = false {
		didSet {
			let imageStr = isPlaying ? Images.pause: Images.play
            self.playButton.setImage(UIImage(named: imageStr, in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
		}
	}
    
    var isRepeatModeOn: Bool = false {
        didSet {
            repeatButton.tintColor = isRepeatModeOn ? .white: UIColor.white.withAlphaComponent(defaultAlpha)
        }
    }
    
    var isShuffleModeOn: Bool = false {
        didSet {
            shuffleButton.tintColor = isShuffleModeOn ? .white: UIColor.white.withAlphaComponent(defaultAlpha)
        }
    }
    
    
    // MARK: Outlets
    
	@IBOutlet private weak var repeatButton: UIButton!
	@IBOutlet private weak var rewindBackButton: UIButton!
	@IBOutlet private weak var playButton: UIButton!
	@IBOutlet private weak var rewindForwardButton: UIButton!
	@IBOutlet private weak var shuffleButton: UIButton!
	
    // MARK: UI
    
	override func initUI() {
		isPlaying = false
        isRepeatModeOn = false
        isShuffleModeOn = false
		backgroundColor = .clear
	}

    // MARK: IBActions
    
	@IBAction private func repeatDidTap(_ sender: Any) {
		delegate?.onRepeat()
	}
	
	@IBAction private func rewindBackDidTap(_ sender: Any) {
		delegate?.onRewindBack()
	}
	
	@IBAction private func playDidTap(_ sender: Any) {
		delegate?.onPlay()
	}
	
	@IBAction private func rewindForwardDidTap(_ sender: Any) {
		delegate?.onRewindForward()
	}
	
	@IBAction private func shuffleDidTap(_ sender: Any) {
		delegate?.onShuffle()
	}
    
    // MARK: Private
    
    private func updateStatus() {
        switch status {
        case .Loading:
            let image = UIImage(named: Images.playLoading, in: Bundle(for: self.classForCoder), compatibleWith: nil)
            playButton.setImage(image, for: .normal)
            
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            playButton.addSubview(activityIndicatorView)
            
            let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerX, relatedBy: .equal, toItem: activityIndicatorView, attribute: .centerX, multiplier: 1, constant: 0)
            playButton.addConstraint(xCenterConstraint)
            
            let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerY, relatedBy: .equal, toItem: activityIndicatorView, attribute: .centerY, multiplier: 1, constant: 0)
            
            playButton.addConstraint(yCenterConstraint)
            
            activityIndicatorView.startAnimating()
            self.isUserInteractionEnabled = false
        case .Ready:
            playButton.subviews.forEach({if $0.isKind(of: UIActivityIndicatorView.self) { $0.removeFromSuperview() } })
            let image = UIImage(named: Images.play, in: Bundle(for: self.classForCoder), compatibleWith: nil)
            playButton.setImage(image, for: .normal)
            self.isUserInteractionEnabled = true
        }
    }
}
