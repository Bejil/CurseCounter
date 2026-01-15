//
//  CC_Game_Survival_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 15/01/2026.
//

import UIKit
import SnapKit

public class CC_Game_Survival_ViewController : CC_Game_ViewController {
	
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
	
	public override func loadView() {
		
		super.loadView()
		
		remainingTime = initialTime
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		startCountdown()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
	
	private func startCountdown() {
		
		countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			
			self?.remainingTime -= 0.1
		}
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
		
		// Empêcher les appels multiples
		guard !hasDisplayedGameOver else { return }
		hasDisplayedGameOver = true
		
		countdownTimer?.invalidate()
		countdownTimer = nil
		
		// Retirer les gesture recognizers pour empêcher les interactions
		zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
		
		let alertViewController: CC_Alert_ViewController = .init()
		var presentCompletion:(()->Void)?
		
		let bestScore: Int = (UserDefaults.get(.bestScoreSurvival) as? Int) ?? 0
		if pointsCount > bestScore {
			
			UserDefaults.set(pointsCount, .bestScoreSurvival)
			
			CC_Audio.shared.playSound(.Success)
			CC_Feedback.shared.make(.Success)
			
			alertViewController.title = String(key: "game.survival.over.bestScore.alert.title")
			alertViewController.dismissHandler = {
				
				CC_Confettis.stop()
			}
			
			presentCompletion = {
				
				CC_Confettis.start()
			}
		}
		else {
			
			CC_Audio.shared.playSound(.Error)
			CC_Feedback.shared.make(.Error)
			
			alertViewController.title = String(key: "game.survival.over.default.alert.title")
		}
		
		alertViewController.add(String(format: String(key: "game.over.alert.points"), pointsCount))
		alertViewController.add(String(format: String(key: "game.over.alert.hits"), hitsCount))
		alertViewController.addDismissButton { [weak self] _ in
			
			self?.close()
		}
		alertViewController.present(presentCompletion)
	}
}
