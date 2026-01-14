//
//  CC_Menu_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_Menu_ViewController : CC_ViewController {
	
	public override func loadView() {
		
		super.loadView()
		
		let titleLabel:CC_Label = .init([String(key: "menu.title.0"),String(key: "menu.title.1")].joined(separator: " "))
		titleLabel.font = Fonts.Content.Title.H1
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		titleLabel.set(color: Colors.Primary, string: String(key: "menu.title.1"))
		
		let subtitleLabel:CC_Label = .init(String(key: "menu.subtitle"))
		subtitleLabel.textAlignment = .center
		
		let newGameStartButton:CC_Button = .init(String(key: "menu.button.newGame")) { _ in
			
			UI.MainController.present(CC_NavigationController(rootViewController: CC_Game_ViewController()), animated: true)
		}
		newGameStartButton.image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill")
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleLabel,subtitleLabel,newGameStartButton,CC_Settings_Button()])
		stackView.axis = .vertical
		stackView.spacing = 1.5*UI.Margins
		stackView.setCustomSpacing(1.5*stackView.spacing, after: subtitleLabel)
		
		let scrollView:CC_ScrollView = .init()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.isCentered = true
		scrollView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview().inset(UI.Margins/5)
		}
		
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		
		stackView.animate()
	}
}
