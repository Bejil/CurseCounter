//
//  CC_Menu_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_Menu_ViewController : CC_ViewController {
	
	private lazy var bannerView = CC_Ads.shared.presentBanner(Ads.Banner.Menu, self)
	private lazy var classicGameButton:CC_Button = {
		
		$0.image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill")
		return $0
		
	}(CC_Button(String(key: "menu.button.game.classic.title")) { [weak self] _ in
		
		self?.prensentGameAd {
			
			let navigationController:CC_NavigationController = .init(rootViewController: CC_Game_Classic_ViewController())
			navigationController.navigationBar.prefersLargeTitles = false
			UI.MainController.present(navigationController, animated: true)
		}
	})
	
	private lazy var survivalGameButton:CC_Button = {
		
		$0.image = UIImage(systemName: "timer")
		$0.type = .secondary
		return $0
		
	}(CC_Button(String(key: "menu.button.game.survival.title")) { [weak self] _ in
		
		self?.prensentGameAd {
			
			let navigationController:CC_NavigationController = .init(rootViewController: CC_Game_Survival_ViewController())
			navigationController.navigationBar.prefersLargeTitles = false
			UI.MainController.present(navigationController, animated: true)
		}
	})
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.rightBarButtonItem = .init(customView: CC_Settings_Button())
		
		let titleImageView:UIImageView = .init(image: UIImage(systemName: "smallcircle.filled.circle"))
		titleImageView.tintColor = Colors.Content.Text.withAlphaComponent(0.75)
		titleImageView.contentMode = .scaleAspectFit
		titleImageView.snp.makeConstraints { make in
			make.size.equalTo(6*UI.Margins)
		}
		
		let titleLabel:CC_Label = .init([String(key: "menu.title.0"),String(key: "menu.title.1")].joined(separator: " "))
		titleLabel.font = Fonts.Content.Title.H1
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		titleLabel.set(color: Colors.Primary, string: String(key: "menu.title.1"))
		
		let subtitleLabel:CC_Label = .init(String(key: "menu.subtitle"))
		subtitleLabel.textAlignment = .center
		
		let inAppButton:CC_Button = .init(String(key: "menu.button.inApp")) { _ in
			
//			CM_InAppPurchase.shared.promptInAppPurchaseAlert(withCapping: false)
		}
		inAppButton.type = .navigation
		inAppButton.titleFont = Fonts.Content.Button.Title
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleImageView,titleLabel,subtitleLabel,classicGameButton,survivalGameButton,inAppButton])
		stackView.axis = .vertical
		stackView.spacing = 1.5*UI.Margins
		stackView.setCustomSpacing(2*stackView.spacing, after: subtitleLabel)
		stackView.setCustomSpacing(2*stackView.spacing, after: survivalGameButton)
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
		
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
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		let bestScoreClassic:Int = (UserDefaults.get(.gameClassicBestScore) as? Int) ?? 0
		classicGameButton.subtitle = bestScoreClassic > 0 ? String(key: "menu.button.game.classic.subtitle") + " \(bestScoreClassic)" : nil
		
		let bestScoreSurvival:Int = (UserDefaults.get(.gameSurvivalBestScore) as? Int) ?? 0
		survivalGameButton.subtitle = bestScoreSurvival > 0 ? String(key: "menu.button.game.survival.subtitle") + " \(bestScoreSurvival)" : nil
		
		bannerView?.refresh()
	}
	
	private func prensentGameAd(_ completion:(()->Void)?) {
		
		CC_Alert_ViewController.presentLoading { alertController in
			
			CC_Ads.shared.presentInterstitial(Ads.FullScreen.Game.Start, nil, {
				
				alertController?.close(completion)
			})
		}
	}
}
