//
//  CC_Game_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_Game_ViewController : CC_ViewController {
	
	internal enum HitType: Int {
		
		case good = 1
		case great = 2
		case perfect = 3
		
		static func forPrecision(_ precision: Double) -> HitType {
			
			let precisionPercent = Int(precision * 100)
			if let index = [0...59, 60...89, 90...100].firstIndex(where: { $0.contains(precisionPercent) }) {
				return HitType(rawValue: index + 1) ?? .good
			}
			return .good
		}
		
		var points: Int {
			
			return rawValue
		}
		
		var color: UIColor {
			
			switch self {
			case .perfect: return Colors.Hits.Perfect
			case .great: return Colors.Hits.Great
			case .good: return Colors.Hits.Good
			}
		}
		
		var text: String {
			
			return String(key: "game.hit.\(rawValue)")
		}
	}
	internal var bestScoreKey: UserDefaults.Keys? {
		
		return nil
	}
	internal var pointsCount:Int = 0 {
		
		didSet {
			
			updateTitle()
		}
	}
	internal var hitsCount:Int = 0
	private var perfectStreak:Int = 0
	internal let comboStreakRequired:Int = 5 // Nombre de perfects consécutifs requis pour activer le combo
	internal lazy var zoneView: UIView = .init()
	private var isGameOverDisplayed: Bool = false
	internal var missEndsGame: Bool { return true }
	private var isPaused: Bool = false
	private var isGameStopped: Bool = false
	private var colorTimer: Timer?
	private var pausedTime: CFTimeInterval = 0
	
	public override func loadView() {
		
		super.loadView()
		
		let stackView: UIStackView = .init(arrangedSubviews: [zoneView,CC_Ads.shared.presentBanner(Ads.Banner.Game, self)])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func close() {
		
		pauseGame()
		
		let alertController:CC_Alert_ViewController = .init()
		alertController.backgroundView.isUserInteractionEnabled = false
		alertController.title = String(key: "game.quit.alert.title")
		alertController.add(String(key: "game.quit.alert.message"))
		alertController.add(String(key: "game.quit.alert.warning"))
		let button = alertController.addButton(title: String(key: "game.quit.alert.button.quit")) { [weak self] _ in
			
			self?.stopGame()
			
			alertController.close { [weak self] in
				
				self?.dismiss()
			}
		}
		button.type = .delete
		alertController.addCancelButton() { [weak self] _ in
			
			self?.resumeGame()
		}
		alertController.present()
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		super.dismiss(completion)
		
		CC_Alert_ViewController.presentLoading { alertController in
			
			CC_Ads.shared.presentInterstitial(Ads.FullScreen.Game.End, nil, {
				
				alertController?.close(completion)
			})
		}
	}
	
	internal func pauseGame() {
		
		guard !isPaused else { return }
		isPaused = true
		
		// Stopper le timer de couleur
		colorTimer?.invalidate()
		
		// Mettre en pause toutes les animations dans la zoneView
		zoneView.subviews.forEach { subview in
			
			let pausedTime = subview.layer.convertTime(CACurrentMediaTime(), from: nil)
			subview.layer.speed = 0
			subview.layer.timeOffset = pausedTime
		}
		
		// Désactiver les interactions
		zoneView.isUserInteractionEnabled = false
	}
	
	internal func resumeGame() {
		
		guard isPaused else { return }
		isPaused = false
		
		// Reprendre toutes les animations dans la zoneView
		zoneView.subviews.forEach { subview in
			
			let pausedTime = subview.layer.timeOffset
			subview.layer.speed = 1
			subview.layer.timeOffset = 0
			subview.layer.beginTime = 0
			let timeSincePause = subview.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
			subview.layer.beginTime = timeSincePause
		}
		
		// Réactiver les interactions
		zoneView.isUserInteractionEnabled = true
	}
	
	internal func stopGame() {
		
		isGameStopped = true
		
		// Stopper le timer de couleur
		colorTimer?.invalidate()
		colorTimer = nil
		
		// Retirer toutes les animations et vues
		zoneView.layer.removeAllAnimations()
		zoneView.subviews.forEach { subview in
			subview.layer.removeAllAnimations()
			subview.removeFromSuperview()
		}
		
		// Retirer tous les gesture recognizers
		zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
	}
	
	internal func updateTitle() {
		
		title = "\(pointsCount) " + String(key: "game.points")
	}
	
	internal func showStartTutorial() {
		
		let tutorialViewController:CC_Tutorial_ViewController = .init()
		tutorialViewController.items = [
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.countdown.3"),
				timeInterval: 1.0,
				closure: {
					
					CC_Audio.shared.playSound(.Tap)
					CC_Feedback.shared.make(.On)
				}
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.countdown.2"),
				timeInterval: 1.0,
				closure: {
					
					CC_Audio.shared.playSound(.Tap)
					CC_Feedback.shared.make(.On)
				}
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.countdown.1"),
				timeInterval: 1.0,
				closure: {
					
					CC_Audio.shared.playSound(.Button)
					CC_Feedback.shared.make(.Success)
				}
			),
			CC_Tutorial_ViewController.Item(
				title: String(key: "game.countdown.go"),
				timeInterval: 1.0
			)
		]
		tutorialViewController.completion = { [weak self] in
			
			self?.startGame()
		}
		tutorialViewController.present {
			
			CC_Audio.shared.playSound(.Tap)
			CC_Feedback.shared.make(.On)
		}
	}
	
	internal func startGame() {
		
		isModal = true
		
		updateTitle()

		createZone()
	}
	
	internal func createZone() {
		
		// Retirer les anciens gesture recognizers
		zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
		
		let targetSize: CGFloat = 3.5 * UI.Margins
		let initialSize: CGFloat = targetSize * 15.0
		
		// Calculer la durée en fonction du nombre de succès
		// Commence à 2.0s et diminue progressivement sans limite
		let baseDuration: TimeInterval = 2.0
		let speedIncrement: TimeInterval = 0.015 // Réduit de 0.015s par point (progression lente)
		let animationDuration = max(0.1, baseDuration - (Double(hitsCount) * speedIncrement))
		
		// Container pour la zone QTE
		let qteContainer = UIView()
		zoneView.addSubview(qteContainer)
		
		// Position aléatoire
		let margin = targetSize + UI.Margins
		let minX = zoneView.safeAreaInsets.left + margin
		let maxX = zoneView.frame.size.width - zoneView.safeAreaInsets.right - margin
		let minY = zoneView.safeAreaInsets.top + margin
		let maxY = zoneView.frame.size.height - zoneView.safeAreaInsets.bottom - margin
		
		let randomX = CGFloat.random(in: minX...maxX)
		let randomY = CGFloat.random(in: minY...maxY)
		
		qteContainer.snp.makeConstraints { make in
			make.centerX.equalTo(randomX)
			make.centerY.equalTo(randomY)
			make.size.equalTo(initialSize)
		}
		
		// Cercle central (zone cible fixe)
		let targetCircle = UIView()
		targetCircle.backgroundColor = UIColor.white.withAlphaComponent(0.15)
		targetCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
		targetCircle.layer.borderWidth = 3
		targetCircle.layer.cornerRadius = targetSize / 2
		qteContainer.addSubview(targetCircle)
		
		targetCircle.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(targetSize)
		}
		
		// Cercle extérieur (qui se rétrécit)
		let shrinkingCircle = UIView()
		shrinkingCircle.isUserInteractionEnabled = false
		shrinkingCircle.backgroundColor = UIColor.clear
		shrinkingCircle.layer.borderColor = UIColor.white.cgColor
		shrinkingCircle.layer.borderWidth = 3
		shrinkingCircle.layer.cornerRadius = initialSize / 2
		qteContainer.addSubview(shrinkingCircle)
		
		shrinkingCircle.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.size.equalTo(initialSize)
		}
		
		var isActive = false
		var hasBeenTapped = false
		var currentHitType: HitType = .good
		// Zone cliquable quand le cercle est à 8x la taille cible (plus grand = plus tôt)
		let activeZoneMultiplier: CGFloat = 8.0
		let timeToSuccessZone = animationDuration * (initialSize - activeZoneMultiplier * targetSize) / (initialSize - targetSize)
		
		UIApplication.wait(timeToSuccessZone) { [weak self] in
			
			isActive = true
			currentHitType = .good
			
			UIView.animation {
				
				targetCircle.backgroundColor = Colors.Hits.Good.withAlphaComponent(0.3)
				targetCircle.layer.borderColor = Colors.Hits.Good.cgColor
				shrinkingCircle.layer.borderColor = Colors.Hits.Good.cgColor
			}
			
			// Démarrer le timer pour les mises à jour de couleur (~60fps)
			self?.colorTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
				
				guard isActive, !hasBeenTapped else { return }
				
				let currentScale = shrinkingCircle.layer.presentation()?.transform.m11 ?? 1.0
				let currentSize = initialSize * currentScale
				
				let activeRangeStart = activeZoneMultiplier * targetSize
				let activeRangeEnd = targetSize
				let precision = 1.0 - (currentSize - activeRangeEnd) / (activeRangeStart - activeRangeEnd)
				let precisionValue = max(0, min(1, precision))
				
				let newHitType = HitType.forPrecision(precisionValue)
				
				if newHitType != currentHitType {
					
					currentHitType = newHitType
					
					UIView.animation(0.15) {
						
						targetCircle.backgroundColor = currentHitType.color.withAlphaComponent(0.3)
						targetCircle.layer.borderColor = currentHitType.color.cgColor
						shrinkingCircle.layer.borderColor = currentHitType.color.cgColor
					}
				}
			}
		}
		
		let tapGesture = UITapGestureRecognizer(block: { [weak self] _ in
			
			guard !hasBeenTapped else { return }
			hasBeenTapped = true
			
			// Arrêter le timer
			self?.colorTimer?.invalidate()
			self?.colorTimer = nil
			
			if isActive {
				
				isActive = false
				
				// Calculer la précision basée sur la taille actuelle du cercle
				// Le cercle va de 5x targetSize (début zone active) à 1x targetSize (fin)
				// On récupère le scale actuel via la présentation layer
				let currentScale = shrinkingCircle.layer.presentation()?.transform.m11 ?? 1.0
				let currentSize = initialSize * currentScale
				
				// Zone active: de Nx à 1x targetSize
				// Précision: 0% quand à Nx, 100% quand à 1x
				let activeRangeStart = activeZoneMultiplier * targetSize
				let activeRangeEnd = targetSize
				let precision = 1.0 - (currentSize - activeRangeEnd) / (activeRangeStart - activeRangeEnd)
				let precisionValue = max(0, min(1, precision))
				
				// Déterminer le type de hit
				let hitType = HitType.forPrecision(precisionValue)
				
				// Incrémenter le compteur de succès
				self?.hitsCount += 1
				
				// Calculer les points avec bonus de combo
				var earnedPoints = hitType.points
				
				if hitType == .perfect {
					
					self?.perfectStreak += 1
					
					// Bonus de combo : +1 point si série de X perfects consécutifs
					if let streak = self?.perfectStreak, let required = self?.comboStreakRequired,
					   streak > required {
						
						earnedPoints += 1
					}
				}
				else {
					
					// Reset le streak si ce n'est pas un perfect
					self?.perfectStreak = 0
				}
				
				// Incrémenter le compteur de points
				self?.pointsCount += earnedPoints
				
				// Hook pour les sous-classes
				self?.onHit(hitType)
				
				CC_Audio.shared.playSound(.Success)
				CC_Feedback.shared.make(.Success)
				
				// Afficher le feedback avec bonus
				self?.showHitFeedback(hitType, bonus: earnedPoints - hitType.points, in: qteContainer)
				
				targetCircle.pulse(hitType.color) {
					
					qteContainer.removeFromSuperview()
				}
					
				UIApplication.wait { [weak self] in
					
					guard self?.isGameStopped != true else { return }
					self?.createZone()
				}
			}
			else {
				
				// Hook pour les sous-classes
				self?.onMiss()
				
				CC_Audio.shared.playSound(.Error)
				CC_Feedback.shared.make(.Error)
				
				// Afficher le feedback d'erreur
				self?.showMissFeedback(in: qteContainer)
				
				UIView.animation {
					
					targetCircle.backgroundColor = Colors.Hits.Wrong.withAlphaComponent(0.4)
					targetCircle.layer.borderColor = Colors.Hits.Wrong.cgColor
				}
				
				targetCircle.pulse(Colors.Hits.Wrong) {
					
					qteContainer.removeFromSuperview()
				}
				
				if self?.missEndsGame == true {
					self?.gameOver()
				} else {
				UIApplication.wait { [weak self] in
						guard self?.isGameStopped != true else { return }
					self?.createZone()
					}
				}
			}
		})
		targetCircle.addGestureRecognizer(tapGesture)
		
		// Tap en dehors de la zone = game over
		let missedTapGesture = UITapGestureRecognizer(block: { [weak self] _ in
			
			guard !hasBeenTapped else { return }
			hasBeenTapped = true
			isActive = false
			
			// Arrêter le timer
			self?.colorTimer?.invalidate()
			self?.colorTimer = nil
			
			// Hook pour les sous-classes
			self?.onMiss()
			
			CC_Audio.shared.playSound(.Error)
			CC_Feedback.shared.make(.Error)
			
			// Afficher le feedback d'erreur
			self?.showMissFeedback(in: qteContainer)
			
			UIView.animation {
				
				targetCircle.backgroundColor = Colors.Hits.Wrong.withAlphaComponent(0.4)
				targetCircle.layer.borderColor = Colors.Hits.Wrong.cgColor
			}
			
			targetCircle.pulse(Colors.Hits.Wrong) {
				
				qteContainer.removeFromSuperview()
			}
			
			if self?.missEndsGame == true {
				self?.gameOver()
			} else {
				UIApplication.wait { [weak self] in
					guard self?.isGameStopped != true else { return }
					self?.createZone()
				}
			}
		})
		missedTapGesture.require(toFail: tapGesture)
		zoneView.addGestureRecognizer(missedTapGesture)
		
		UIView.animation(animationDuration, {
			
			shrinkingCircle.transform = CGAffineTransform(scaleX: targetSize / initialSize, y: targetSize / initialSize)
			
		}, { [weak self] in
			
			guard self?.isGameStopped != true else { return }
			
			if isActive && !hasBeenTapped {
				
				isActive = false
				hasBeenTapped = true
				
				// Hook pour les sous-classes
				self?.onMiss()
				
				CC_Audio.shared.playSound(.Error)
				CC_Feedback.shared.make(.Error)
				
				// Afficher le feedback d'erreur
				self?.showMissFeedback(in: qteContainer)
				
				UIView.animation(0.3, {
					
					qteContainer.alpha = 0
					
				}, {
					
					qteContainer.removeFromSuperview()
				})
				
				if self?.missEndsGame == true {
					self?.gameOver()
				} else {
					UIApplication.wait { [weak self] in
						guard self?.isGameStopped != true else { return }
						self?.createZone()
					}
				}
			}
		})
	}
	
	internal func onHit(_ hitType: HitType) {
		
	}
	
	internal func onMiss() {
		
		perfectStreak = 0
	}
	
	internal func showHitFeedback(_ hitType: HitType, bonus: Int = 0, in container: UIView) {
		
		// Texte avec indicateur de combo si bonus présent
		let text = bonus > 0 ? String(key: "game.hit.combo") : hitType.text
		
		let feedbackLabel = CC_Label(text)
		feedbackLabel.font = Fonts.Content.Title.H2
		feedbackLabel.textColor = hitType.color
		feedbackLabel.textAlignment = .center
		feedbackLabel.alpha = 0
		feedbackLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		zoneView.addSubview(feedbackLabel)
		
		// Positionner au centre de la zone touchée
		let containerCenter = container.center
		feedbackLabel.snp.makeConstraints { make in
			make.centerX.equalTo(containerCenter.x)
			make.centerY.equalTo(containerCenter.y)
		}
		
		UIView.animation(0.15, {
			
			feedbackLabel.alpha = 1
			feedbackLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			
		}, {
			
			UIView.animation(0.1, {
				
				feedbackLabel.transform = .identity
				
			}, {
				
				UIView.animation(0.4, {
					
					feedbackLabel.alpha = 0
					feedbackLabel.transform = CGAffineTransform(translationX: 0, y: -50)
					
				}, {
					
					feedbackLabel.removeFromSuperview()
				})
			})
		})
	}
	
	internal func showMissFeedback(in container: UIView) {
		
		let feedbackLabel = CC_Label(String(key: "game.hit.wrong"))
		feedbackLabel.font = Fonts.Content.Title.H2
		feedbackLabel.textColor = Colors.Hits.Wrong
		feedbackLabel.textAlignment = .center
		feedbackLabel.alpha = 0
		feedbackLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		zoneView.addSubview(feedbackLabel)
		
		// Positionner au centre de la zone
		let containerCenter = container.center
		feedbackLabel.snp.makeConstraints { make in
			make.centerX.equalTo(containerCenter.x)
			make.centerY.equalTo(containerCenter.y)
		}
		
		UIView.animation(0.15, {
			
			feedbackLabel.alpha = 1
			feedbackLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			
		}, {
			
			UIView.animation(0.1, {
				
				feedbackLabel.transform = .identity
				
			}, {
				
				UIView.animation(0.4, {
					
					feedbackLabel.alpha = 0
					feedbackLabel.transform = CGAffineTransform(translationX: 0, y: -50)
					
				}, {
					
					feedbackLabel.removeFromSuperview()
				})
			})
		})
	}
	
	internal func gameOver() {
		
		// Empêcher les appels multiples
		guard !isGameOverDisplayed else { return }
		isGameOverDisplayed = true
		
		// Retirer les gesture recognizers pour empêcher les interactions
		zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
		
		if let bestScoreKey {
			
			let alertViewController: CC_Alert_ViewController = .init()
			alertViewController.backgroundView.isUserInteractionEnabled = false
			var presentCompletion:(()->Void)?
			
			let bestScore: Int = (UserDefaults.get(bestScoreKey) as? Int) ?? 0
			if pointsCount > bestScore {
				
				UserDefaults.set(pointsCount, bestScoreKey)
				
				CC_Audio.shared.playSound(.Success)
				CC_Feedback.shared.make(.Success)
				
				alertViewController.title = String(key: "game.over.bestScore.alert.title")
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
				
				alertViewController.title = String(key: "game.over.default.alert.title")
			}
			
			alertViewController.add(String(format: String(key: "game.over.alert.points"), pointsCount))
			alertViewController.add(String(format: String(key: "game.over.alert.hits"), hitsCount))
			alertViewController.addDismissButton { [weak self] _ in
				
				self?.dismiss()
			}
			alertViewController.present(presentCompletion)
		}
	}
}
