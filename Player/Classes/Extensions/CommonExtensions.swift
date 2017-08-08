//
//  CommonExtensions.swift
//  Player
//
//  Created by user on 6/7/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import Foundation
import UIKit

fileprivate let defaultDuration = 0.3

extension UIImageView {
    
    func changeImageWithExpandingAnimation(_ image: UIImage, duration: TimeInterval = defaultDuration) {
        guard image != self.image, let container = superview else { return }
        let topImageView = UIImageView(image: image)
        topImageView.frame = frame
        topImageView.contentMode = .scaleAspectFill
        container.insertSubview(topImageView, aboveSubview: self)
        self.image = image
        UIView.animate(withDuration: duration, animations: {
            topImageView.transform = topImageView.transform.scaledBy(x: 1.5, y: 1.5)
            topImageView.alpha = 0
        }) { (completed) in
            topImageView.removeFromSuperview()
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        draw(in: rect)
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}

extension UILabel {
    func changeAnimated(_ text: String, color: UIColor, duration: TimeInterval = defaultDuration) {
        let animation = "TextAnimation"
        if layer.animation(forKey: animation) == nil {
            let transition = CATransition()
            transition.duration = duration
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            layer.add(transition, forKey: animation)
        }
        self.text = text
        self.textColor = color
    }
}

extension CATransition {
    
    static func fading(_ duration: TimeInterval) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return transition
    }
}
