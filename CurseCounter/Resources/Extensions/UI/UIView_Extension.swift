//
//  UIView_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit
import SnapKit

extension UIView {
	
	static func animation(_ duration:TimeInterval? = 0.3, _ animations:@escaping (()->Void), _ completion: (()->Void)? = nil) {
		
		UIView.animate(withDuration: duration ?? 0.3, delay: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: animations) { state in
			
			completion?()
		}
	}
	
	func stopPulse(){
		
		layer.removeAllAnimations()
		transform = .identity
	}
	
	func pulse(_ color:UIColor = UIColor.white, _ completion:(()->Void)? = nil){
		
		stopPulse()
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		view.subviews.first(where: {$0.accessibilityLabel == "pulseView"})?.removeFromSuperview()
		
		let initialScale = transform
		let initialScaleX = initialScale.a
		let initialScaleY = initialScale.d
		
		superview?.layoutIfNeeded()
		
		let pulseView:UIView = .init()
		pulseView.accessibilityLabel = "pulseView"
		pulseView.isUserInteractionEnabled = false
		
		if color != .clear {
			
			pulseView.backgroundColor = color.withAlphaComponent(0.25)
			pulseView.layer.cornerRadius = frame.size.width/2
			pulseView.layer.borderColor = color.cgColor
			pulseView.layer.borderWidth = 2.0
			pulseView.alpha = 0.0
			pulseView.transform = .init(scaleX: initialScaleX * 0.01, y: initialScaleY * 0.01)
			pulseView.clipsToBounds = true
			addSubview(pulseView)
			
			pulseView.snp.makeConstraints { (make) in
				make.centerX.centerY.width.equalTo(self)
				make.height.equalTo(snp.width)
			}
		}
		
		let pulseDuration:TimeInterval = 0.3
		
		UIView.animate(withDuration: pulseDuration, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
			
			pulseView.transform = .init(scaleX: initialScaleX * 2.0, y: initialScaleY * 2.0)
			
		}, completion: nil)
		
		UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
			
			pulseView.alpha = 0.5
			self?.transform = .init(scaleX: initialScaleX * 1.15, y: initialScaleY * 1.15)
			
		}) { [weak self] _ in
			
			UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
				
				pulseView.alpha=0.0;
				
				self?.transform = initialScale
				
			}) { _ in
				
				if pulseView.superview != nil {
					
					pulseView.removeFromSuperview()
				}
				
				completion?()
			}
		}
	}
	
	func findFirstResponder() -> UIView? {
		
		if isFirstResponder {
			
			return self
		}
		
		for subview in subviews {
			
			if let firstResponder = subview.findFirstResponder() {
				
				return firstResponder
			}
		}
		
		return nil
	}
}
