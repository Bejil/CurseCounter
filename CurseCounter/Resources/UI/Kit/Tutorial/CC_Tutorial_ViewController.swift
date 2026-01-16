//
//  CC_Tutorial_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import UIKit
import SnapKit

public class CC_Tutorial_ViewController: CC_ViewController {
	
	public struct Item {
		
		public var sourceView:UIView?
		public var title:String?
		public var subtitle:String?
		public var attributedSubtitle:NSAttributedString?
		public var button:String?
		public var timeInterval:TimeInterval?
		public var closure:(()->Void)?
	}
	
	public var completion:(()->Void)?
	public var key:UserDefaults.Keys?
	public var force:Bool = false
	public var items: [Item]?
	private lazy var titleLabel: CC_Label = {
		
		$0.font = Fonts.Content.Title.H1.withSize(Fonts.Size + 30)
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(CC_Label())
	public lazy var subtitleLabel: CC_Label = {
		
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(CC_Label())
	
	private lazy var nextButton: CC_Button = .init() { [weak self] _ in
		
		self?.nextAction()
	}
	private lazy var contentStackView: UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.alpha = 0.0
		
		var transform = CGAffineTransform.identity
		transform = transform.translatedBy(x: 0, y: -500)
		transform = transform.scaledBy(x: 10, y: 10)
		$0.transform = transform
		
		let stackView: UIStackView = .init(arrangedSubviews: [titleLabel, subtitleLabel, nextButton])
		stackView.axis = .vertical
		stackView.spacing = 2*UI.Margins
		
		$0.addArrangedSubview(stackView)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, nextButton]))
	private var currentIndex: Int = -1
	private var pulseTimer:Timer?
	private lazy var maskLayer:CAShapeLayer = .init()
	public lazy var dimBackgroundView:UIVisualEffectView = {
		
		$0.alpha = 0.75
		return $0
		
	}(UIVisualEffectView(effect: UIBlurEffect.init(style: .dark)))
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	@MainActor deinit {
		
		resetPulseTimer()
	}
	
	public override func loadView() {
		
		super.loadView()
		
		view.backgroundColor = nil
		view.layer.sublayers?.forEach({
			
			$0.removeFromSuperlayer()
		})
		
		view.alpha = 0.0
		view.addSubview(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview()
		}
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			
			make.edges.equalToSuperview().inset(3 * UI.Margins)
		}
		
		let initialPath = UIBezierPath(rect: view.bounds)
		maskLayer.path = initialPath.cgPath
		maskLayer.fillRule = .evenOdd
		view.layer.mask = maskLayer
	}
	
	public func present(_ presentCompletion:(()->Void)? = nil) {
		
		let presentClosure:(()->Void) = { [weak self] in
			
			if let self {
				
				UI.MainController.present(self, animated: false) { [weak self] in
					
					UIView.animate(withDuration: 0.3) {
						
						self?.view.alpha = 1.0
					}
					
					self?.next()
					presentCompletion?()
				}
			}
		}
		
		if let key {
			
			if !(UserDefaults.get(key) as? Bool ?? false) || force {
				
				UserDefaults.set(true, key)
				
				presentClosure()
			}
			else {
				
				completion?()
			}
		}
		else {
			
			presentClosure()
		}
	}
	
	private func resetPulseTimer() {
		
		items?.forEach({
			
			$0.sourceView?.stopPulse()
		})
		
		pulseTimer?.invalidate()
		pulseTimer = nil
	}
	
	private func nextAction() {
		
		if currentIndex < (items?.count ?? 0) - 1 {
			
			items?[currentIndex].closure?()
			next()
		}
		else {
			
			dismiss(animated: true, completion: { [weak self] in
				
				if let currentIndex = self?.currentIndex {
					
					self?.items?[currentIndex].closure?()
				}
				
				self?.completion?()
			})
		}
	}
	
	private func next() {
		
		currentIndex += 1
		
		let animationDuration = 0.3
		
		if let title = items?[currentIndex].title {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			titleLabel.text = String(key: title)
			animation.duration = animationDuration
			titleLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		
		if let attributedSubtitle = items?[currentIndex].attributedSubtitle {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			subtitleLabel.attributedText = attributedSubtitle
			animation.duration = animationDuration
			subtitleLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		else if let subtitle = items?[currentIndex].subtitle {
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			subtitleLabel.text = subtitle
			animation.duration = animationDuration
			subtitleLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		
		if let button = items?[currentIndex].button {
			
			nextButton.isHidden = false
			
			if currentIndex == (items?.count ?? 0) - 1 {
				
				nextButton.style = .solid
				nextButton.type = .primary
			}
			else {
				
				nextButton.style = .tinted
				nextButton.type = .primary
			}
			
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			animation.type = .fade
			nextButton.title = String(key: button)
			animation.duration = animationDuration
			nextButton.titleLabel?.layer.add(animation, forKey: CATransitionType.push.rawValue)
		}
		else {
			
			nextButton.isHidden = true
		}
		
		UIView.animation(animationDuration) {
			
			self.titleLabel.isHidden = self.items?[self.currentIndex].title == nil
			self.titleLabel.superview?.layoutIfNeeded()
			
			self.subtitleLabel.isHidden = self.items?[self.currentIndex].subtitle == nil && self.items?[self.currentIndex].attributedSubtitle == nil
			self.subtitleLabel.superview?.layoutIfNeeded()
			
			self.nextButton.isHidden = self.items?[self.currentIndex].button == nil
			self.nextButton.superview?.layoutIfNeeded()
		}
		
		if let sourceView = items?[currentIndex].sourceView {
			
			resetPulseTimer()
			
			pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
				
				sourceView.pulse(.white)
			})
			
			guard let sourceWindow = sourceView.window else { return }
			
			let sourceFrameInWindow = sourceView.convert(sourceView.bounds, to: sourceWindow)
			var frameInView = view.convert(sourceFrameInWindow, from: sourceWindow)
			
			let margins = UI.Margins
			
			frameInView.origin.x -= margins
			frameInView.origin.y -= margins
			frameInView.size.width += 2*margins
			frameInView.size.height += 2*margins
			
			let finalPath = UIBezierPath(rect: view.bounds)
			let finalRadius = max(frameInView.width, frameInView.height) / 2
			let finalCirclePath = UIBezierPath(arcCenter: CGPoint(x: frameInView.midX, y: frameInView.midY), radius: finalRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
			finalPath.append(finalCirclePath)
			finalPath.usesEvenOddFillRule = true
			
			if currentIndex > 0 {
				
				let pathAnimation = CABasicAnimation(keyPath: "path")
				pathAnimation.fromValue = maskLayer.path
				pathAnimation.toValue = finalPath.cgPath
				pathAnimation.duration = animationDuration
				maskLayer.add(pathAnimation, forKey: "pathAnimation")
			}
			
			maskLayer.path = finalPath.cgPath
			
			UIView.animation(currentIndex > 0 ? animationDuration : 0.0) { [weak self] in
				
				self?.positionContentStackView(avoiding: frameInView)
				self?.view.layoutIfNeeded()
			}
		}
		
		UIView.animate(withDuration: animationDuration, animations: {
			
			self.contentStackView.alpha = 1.0
			self.contentStackView.transform = .identity
			
		}) { [weak self] _ in
			
			if let currentIndex = self?.currentIndex, let timeInterval = self?.items?[currentIndex].timeInterval {
				
				Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
					
					self?.nextAction()
				}
			}
		}
	}
	
	private func positionContentStackView(avoiding frameInView: CGRect) {
		
		let safeArea = view.safeAreaLayoutGuide.layoutFrame
		let margins = UI.Margins
		
		let topSpace = CGRect(
			x: safeArea.minX + margins,
			y: safeArea.minY + margins,
			width: safeArea.width - 2 * margins,
			height: frameInView.minY - safeArea.minY - margins
		)
		let bottomSpace = CGRect(
			x: safeArea.minX + margins,
			y: frameInView.maxY,
			width: safeArea.width - 2 * margins,
			height: safeArea.maxY - frameInView.maxY - margins
		)
		let leftSpace = CGRect(
			x: safeArea.minX + margins,
			y: safeArea.minY + margins,
			width: frameInView.minX - safeArea.minX - margins,
			height: safeArea.height - 2 * margins
		)
		let rightSpace = CGRect(
			x: frameInView.maxX,
			y: safeArea.minY + margins,
			width: safeArea.maxX - frameInView.maxX - margins,
			height: safeArea.height - 2 * margins
		)
		
		let spaces = [topSpace, bottomSpace, leftSpace, rightSpace]
		let largestSpace = spaces.max { $0.height * $0.width < $1.height * $1.width }
		
		contentStackView.snp.remakeConstraints { make in
			
			guard let largestSpace = largestSpace else { return }
			make.center.equalTo(CGPoint(x: largestSpace.midX, y: largestSpace.midY))
			make.width.lessThanOrEqualTo(largestSpace.width)
			make.height.lessThanOrEqualTo(largestSpace.height)
		}
	}
}
