//
//  CC_Game_Classic_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 16/01/2026.
//

import UIKit

public class CC_Game_Classic_ViewController : CC_Game_ViewController {
	
	override var bestScoreKey: UserDefaults.Keys? {
		
		return .gameClassicBestScore
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		let tutorialViewController:CC_Tutorial_ViewController = .init()
		tutorialViewController.key = .gameClassicTutorial
		tutorialViewController.items = [
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.classic.tutorial.main.title"),
				subtitle: String(key: "game.classic.tutorial.main.subtitle"),
				button: String(key: "game.classic.tutorial.main.button")
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.classic.tutorial.combo.title"),
				subtitle: String(format: String(key: "game.classic.tutorial.combo.subtitle"), comboStreakRequired),
				button: String(key: "game.classic.tutorial.combo.button")
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.classic.tutorial.trap.title"),
				subtitle: String(key: "game.classic.tutorial.trap.subtitle"),
				button: String(key: "game.classic.tutorial.trap.button")
			)
		]
		tutorialViewController.completion = { [weak self] in
			
			self?.showStartTutorial()
		}
		tutorialViewController.present()
	}
}
