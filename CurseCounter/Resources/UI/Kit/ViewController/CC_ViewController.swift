//
//  CC_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_ViewController: UIViewController {

	public var isModal:Bool = false {
		
		didSet {
			
			if navigationController?.viewControllers.count ?? 0 < 2 {
				
				navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"), primaryAction: .init(handler: { [weak self] _ in
					
					CC_Feedback.shared.make(.Off)
					CC_Audio.shared.play(.Button)
					
					self?.close()
				}))
			}
		}
	}
	
	public override func loadView() {
		
		super.loadView()
		
		view.backgroundColor = Colors.Background.View
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .fullScreen
		modalTransitionStyle = .coverVertical
		
		let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
			
			if let weakSelf = self {
				
				let touchLocation = sender.location(in: weakSelf.view)
				
				let view:UIView = .init()
				view.isUserInteractionEnabled = false
				weakSelf.view.addSubview(view)
				view.snp.makeConstraints { make in
					make.centerX.equalTo(touchLocation.x)
					make.centerY.equalTo(touchLocation.y)
					make.size.equalTo(2*UI.Margins)
				}
				view.pulse(.white) {
					
					view.removeFromSuperview()
				}
			}
		}
		tapGestureRecognizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureRecognizer)
		
		let width = view.bounds.width
		let height = view.bounds.height
		let lineColor = UIColor.white.withAlphaComponent(0.05)
		let cometColor = UIColor.white.withAlphaComponent(0.1)
		
		let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
							endPoint: CGPoint(x: 0, y: 100),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
							endPoint: CGPoint(x: width, y: 0.8 * width),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
							endPoint: CGPoint(x: width, y: 0.2 * width),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
							endPoint: CGPoint(x: 0, y: 0.25 * height),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
							endPoint: CGPoint(x: 0.6 * width, y: height),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: width - 100, y: height),
							endPoint: CGPoint(x: width, y: height - 100),
							lineColor: lineColor,
							cometColor: cometColor),
					  Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
							endPoint: CGPoint(x: width, y: 0.75 * height),
							lineColor: lineColor,
							cometColor: cometColor)]
		
			// draw track and animate
		for comet in comets {
			view.layer.addSublayer(comet.drawLine())
			view.layer.addSublayer(comet.animate())
		}
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func close() {
		
		dismiss()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		dismiss(animated: true, completion: completion)
	}
}
