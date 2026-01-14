//
//  CC_Game_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_Game_ViewController : CC_ViewController {
	
	private enum HitType: Int {
		
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
	
	private var pointsCount:Int = 0 {
		
		didSet {
			
			title = "\(pointsCount) " + String(key: "game.points")
		}
	}
	private var hitsCount:Int = 0
	private lazy var zoneView: UIView = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = "\(pointsCount) " + String(key: "game.points")
		
		let stackView: UIStackView = .init(arrangedSubviews: [zoneView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)

		createZone()
	}
	
	private func createZone() {
		
		// Retirer les anciens gesture recognizers
		zoneView.gestureRecognizers?.forEach { zoneView.removeGestureRecognizer($0) }
		
		let targetSize: CGFloat = 3.5 * UI.Margins
		let initialSize: CGFloat = targetSize * 15.0
		
		// Calculer la durée en fonction du nombre de succès
		// Commence à 1.2s et diminue progressivement jusqu'à un minimum de 0.5s
		let baseDuration: TimeInterval = 2.0
		let minDuration: TimeInterval = 0.5
		let speedIncrement: TimeInterval = 0.05 // Réduit de 0.05s par succès
		let animationDuration = max(minDuration, baseDuration - (Double(pointsCount) * speedIncrement))
		
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
		
		// Timer pour mettre à jour la couleur en temps réel
		var colorTimer: Timer?
		
		UIApplication.wait(timeToSuccessZone) {
			
			isActive = true
			currentHitType = .good
			
			UIView.animation {
				
				targetCircle.backgroundColor = Colors.Hits.Good.withAlphaComponent(0.3)
				targetCircle.layer.borderColor = Colors.Hits.Good.cgColor
				shrinkingCircle.layer.borderColor = Colors.Hits.Good.cgColor
			}
			
			// Démarrer le timer pour les mises à jour de couleur (~60fps)
			colorTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
				
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
			colorTimer?.invalidate()
			colorTimer = nil
			
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
				
				// Incrémenter le compteur de points
				self?.pointsCount += hitType.points
				
				// Incrémenter le compteur de succès
				self?.hitsCount += 1
				
				CC_Audio.shared.playSound(.Success)
				CC_Feedback.shared.make(.Success)
				
				// Afficher le feedback
				self?.showHitFeedback(hitType, in: qteContainer)
				
				targetCircle.pulse(hitType.color) {
					
					qteContainer.removeFromSuperview()
				}
					
				UIApplication.wait { [weak self] in
					
					self?.createZone()
				}
			}
			else {
				
				CC_Audio.shared.playSound(.Error)
				CC_Feedback.shared.make(.Error)
				
				UIView.animation {
					
					targetCircle.backgroundColor = Colors.Hits.Wrong.withAlphaComponent(0.4)
					targetCircle.layer.borderColor = Colors.Hits.Wrong.cgColor
				}
				
				targetCircle.pulse(Colors.Hits.Wrong) {
					
					qteContainer.removeFromSuperview()
				}
				
				self?.gameOver()
			}
		})
		targetCircle.addGestureRecognizer(tapGesture)
		
		// Tap en dehors de la zone = game over
		let missedTapGesture = UITapGestureRecognizer(block: { [weak self] _ in
			
			guard !hasBeenTapped else { return }
			hasBeenTapped = true
			isActive = false
			
			// Arrêter le timer
			colorTimer?.invalidate()
			colorTimer = nil
			
			UIView.animation(0.3, {
				
				qteContainer.alpha = 0
				
			}, {
				
				qteContainer.removeFromSuperview()
			})
			
			self?.gameOver()
		})
		missedTapGesture.require(toFail: tapGesture)
		zoneView.addGestureRecognizer(missedTapGesture)
		
		UIView.animation(animationDuration, {
			
			shrinkingCircle.transform = CGAffineTransform(scaleX: targetSize / initialSize, y: targetSize / initialSize)
			
		}, { [weak self] in
			
			if isActive && !hasBeenTapped {
				
				isActive = false
				hasBeenTapped = true
				
				UIView.animation(0.3, {
					
					qteContainer.alpha = 0
					
				}, {
					
					qteContainer.removeFromSuperview()
				})
				
				self?.gameOver()
			}
		})
	}
	
	private func showHitFeedback(_ hitType: HitType, in container: UIView) {
		
		let feedbackLabel = CC_Label(hitType.text)
		feedbackLabel.font = Fonts.Content.Title.H1
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
	
	private func gameOver() {
		
		let alertViewController: CC_Alert_ViewController = .init()
		var presentCompletion:(()->Void)?
		
		let bestScore:Int = (UserDefaults.get(.bestScore) as? Int) ?? 0
		if pointsCount > bestScore {
			
			UserDefaults.set(pointsCount, .bestScore)
			
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
			
			self?.close()
		}
		alertViewController.present(presentCompletion)
	}
}
