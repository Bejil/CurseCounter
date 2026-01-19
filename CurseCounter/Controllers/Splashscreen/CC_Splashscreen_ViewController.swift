//
//  CC_Splashscreen_ViewController.swift
//  CinqMille
//
//  Created by BLIN Michael on 09/01/2026.
//

import UIKit
import SnapKit

public class CC_Splashscreen_ViewController : CC_ViewController {
	
	public var completion:(()->Void)?
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		
		let titleImageView:UIImageView = .init(image: UIImage(systemName: "smallcircle.filled.circle"))
		titleImageView.tintColor = Colors.Content.Text.withAlphaComponent(0.75)
		titleImageView.contentMode = .scaleAspectFit
		titleImageView.snp.makeConstraints { make in
			make.size.equalTo(6*UI.Margins)
		}
		$0.addArrangedSubview(titleImageView)
		
		let titleLabel:CC_Label = .init([String(key: "menu.title.0"),String(key: "menu.title.1")].joined(separator: " "))
		titleLabel.font = Fonts.Content.Title.H1
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		titleLabel.set(color: Colors.Primary, string: String(key: "menu.title.1"))
		$0.addArrangedSubview(titleLabel)
		
		let subtitleLabel:CC_Label = .init(String(key: "menu.subtitle"))
		subtitleLabel.textAlignment = .center
		$0.addArrangedSubview(subtitleLabel)
		
		return $0
		
	}(UIStackView())
	
	public override func loadView() {
		
		super.loadView()
		
		let containerStackView:UIStackView = .init(arrangedSubviews: [stackView])
		containerStackView.axis = .horizontal
		containerStackView.alignment = .center
		view.addSubview(containerStackView)
		containerStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		stackView.animate()
		
		UIApplication.wait(3.0) { [weak self] in
			
			self?.dismiss(self?.completion)
		}
	}
}
