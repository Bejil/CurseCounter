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
	
	private var remainingTime: TimeInterval = 30.0 {
		
		didSet {
			
			updateTitle()
			
			if remainingTime <= 0 {
				
				remainingTime = 0
				countdownTimer?.invalidate()
				countdownTimer = nil
				gameOver()
			}
		}
	}
	
	private var countdownTimer: Timer?
	
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
		
		remainingTime -= missPenalty
	}
	
	override internal func gameOver() {
		
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
