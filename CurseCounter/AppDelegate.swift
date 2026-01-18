//
//  AppDelegate.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import UserMessagingPlatform

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		CC_Ads.shared.start()
		CC_Audio.shared.playMusic()
		
		let parameters = RequestParameters()
		parameters.isTaggedForUnderAgeOfConsent = false
		
		ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] _ in
			
			ConsentForm.load { [weak self] form, _ in
				
				if ConsentInformation.shared.consentStatus == .required {
					
					form?.present(from: UI.MainController)
				}
				else if ConsentInformation.shared.consentStatus == .obtained {
					
					self?.afterLaunch()
					NotificationCenter.post(.updateAds)
				}
			}
		}
		
		return true
	}
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	public func applicationWillEnterForeground(_ application: UIApplication) {
		
		afterLaunch()
	}
	
	private func presentAdAppOpening() {
		
		CC_Ads.shared.presentAppOpening(nil, nil)
	}
	
	private func afterLaunch() {
		
		presentAdAppOpening()
	}
}
