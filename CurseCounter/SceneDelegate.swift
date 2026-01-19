//
//  SceneDelegate.swift
//  CurseCounter
//
//  Created by BLIN Michael on 16/01/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: windowScene)
		window?.backgroundColor = Colors.Background.Application
		
		let viewController:CC_Splashscreen_ViewController = .init()
		viewController.completion = { [weak self] in
			
			let navigationController: CC_NavigationController = .init(rootViewController: CC_Menu_ViewController())
			navigationController.navigationBar.prefersLargeTitles = false
			self?.window?.rootViewController = navigationController
		}
		window?.rootViewController = viewController
		
		window?.makeKeyAndVisible()
	}
}
