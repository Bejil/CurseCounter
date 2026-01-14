//
//  CC_Game_ViewController.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class CC_Game_ViewController : CC_ViewController {
	
	private var successCount: Int = 0 {
		
		didSet {
			
			countLabel.text = "\(successCount)"
		}
	}
	private lazy var countLabel: CC_Label = {
		
		$0.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize+20)
		$0.textColor = Colors.Content.Title
		$0.textAlignment = .center
		return $0
		
	}(CC_Label("\(successCount)"))
	private lazy var zoneView:UIView = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		let stackView:UIStackView = .init(arrangedSubviews: [countLabel,zoneView])
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
		let animationDuration = max(minDuration, baseDuration - (Double(successCount) * speedIncrement))
		
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
		let timeToSuccessZone = animationDuration * (initialSize - 5.0 * targetSize) / (initialSize - targetSize)
		
		UIApplication.wait(timeToSuccessZone) {
			
			isActive = true
			
			UIView.animation {
				
				targetCircle.backgroundColor = Colors.Secondary.withAlphaComponent(0.3)
				targetCircle.layer.borderColor = Colors.Secondary.cgColor
				shrinkingCircle.layer.borderColor = Colors.Secondary.cgColor
			}
		}
		
		let tapGesture = UITapGestureRecognizer(block: { [weak self] _ in
			
			guard !hasBeenTapped else { return }
			hasBeenTapped = true
			
			if isActive {
				
				isActive = false
				
				// Incrémenter le compteur de succès
				self?.successCount += 1
				
				CC_Audio.shared.play(.Success)
				CC_Feedback.shared.make(.Success)
				
				targetCircle.pulse(Colors.Secondary) {
					
					qteContainer.removeFromSuperview()
				}
					
				UIApplication.wait { [weak self] in
					
					self?.createZone()
				}
			}
			else {
				
				CC_Audio.shared.play(.Error)
				CC_Feedback.shared.make(.Error)
				
				UIView.animation {
					
					targetCircle.backgroundColor = Colors.Primary.withAlphaComponent(0.4)
					targetCircle.layer.borderColor = Colors.Primary.cgColor
				}
				
				targetCircle.pulse(Colors.Primary) {
					
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
	
	private func gameOver() {
		
		CC_Audio.shared.play(.Error)
		CC_Feedback.shared.make(.Error)
		
		let alertViewController:CC_Alert_ViewController = .init()
		alertViewController.title = String(key: "game.over.title")
		alertViewController.add(String(format: String(key: "game.over.message"), successCount))
		alertViewController.addDismissButton { [weak self] _ in
			
			self?.close()
		}
		alertViewController.present()
	}
}
