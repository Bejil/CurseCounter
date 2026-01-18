//
//  CC_Game_Survival_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 15/01/2026.
//

import UIKit
import SnapKit

public class CC_Game_Survival_ViewController : CC_Game_ViewController {
	
	override var bestScoreKey: UserDefaults.Keys? {
		
		return .gameSurvivalBestScore
	}
	private let initialTime: TimeInterval = 30.0
	private let perfectBonus: TimeInterval = 3.0
	private let greatBonus: TimeInterval = 1.0
	private let missPenalty: TimeInterval = 5.0
	private var isGameOver: Bool = false
	private var hasDisplayedGameOver: Bool = false
	private var remainingTime: TimeInterval = 30.0 {
		
		didSet {
			
			if remainingTime <= 0 && !isGameOver {
				
				remainingTime = 0
				isGameOver = true
				countdownTimer?.invalidate()
				countdownTimer = nil
				
				// Retirer immédiatement tous les gesture recognizers
				zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
				zoneView.subviews.forEach { $0.removeFromSuperview() }
				
				gameOver()
			}
			
			updateTitle()
		}
	}
	private var countdownTimer: Timer?
	// En mode survie, un miss ne termine pas la partie (sauf si temps = 0)
	override internal var missEndsGame: Bool { return isGameOver }
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		let tutorialViewController:CC_Tutorial_ViewController = .init()
		tutorialViewController.key = .gameSurvivalTutorial
		tutorialViewController.items = [
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.survival.tutorial.main.title"),
				subtitle: String(key: "game.survival.tutorial.main.subtitle"),
				button: String(key: "game.survival.tutorial.main.button")
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.survival.tutorial.combo.title"),
				subtitle: String(format: String(key: "game.survival.tutorial.combo.subtitle"), comboStreakRequired),
				button: String(key: "game.survival.tutorial.combo.button")
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.survival.tutorial.trap.title"),
				subtitle: String(key: "game.survival.tutorial.trap.subtitle"),
				button: String(key: "game.survival.tutorial.trap.button")
			)
		]
		tutorialViewController.completion = { [weak self] in
			
			self?.showStartTutorial()
		}
		tutorialViewController.present()
	}
	
	override func startGame() {
		
		super.startGame()
		
		startCountdown()
	}
	
	override func pauseGame() {
		
		super.pauseGame()
		
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
	
	override func resumeGame() {
		
		super.resumeGame()
		
		guard !isGameOver else { return }
		
		countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			
			self?.remainingTime -= 0.1
		}
	}
	
	override func stopGame() {
		
		super.stopGame()
		
		isGameOver = true
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
	
	private func startCountdown() {
		
		remainingTime = initialTime
		resumeGame()
	}
	
	override internal func updateTitle() {
		
		let timeString = String(format: "%.1f", remainingTime)
		title = "\(pointsCount) " + String(key: "game.points") + " • " + timeString + "s"
	}
	
	override internal func onHit(_ hitType: HitType) {
		
		guard !isGameOver else { return }
		
		switch hitType {
		case .perfect:
			remainingTime += perfectBonus
		case .great:
			remainingTime += greatBonus
		case .good:
			break
		}
	}
	
	override internal func onMiss() {
		
		super.onMiss()
		
		guard !isGameOver else { return }
		remainingTime -= missPenalty
	}
	
	override internal func gameOver() {
		
		countdownTimer?.invalidate()
		countdownTimer = nil
		
		super.gameOver()
	}
}
