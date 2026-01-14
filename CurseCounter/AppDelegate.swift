//
//  AppDelegate.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Background.Application
		
		let navigationController:CC_NavigationController = .init(rootViewController: CC_Menu_ViewController())
		navigationController.navigationBar.prefersLargeTitles = false
		window?.rootViewController = navigationController
		
		window?.makeKeyAndVisible()
		
		CC_Audio.shared.playMusic()
		
		return true
	}
}
