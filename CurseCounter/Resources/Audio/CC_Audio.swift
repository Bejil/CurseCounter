//
//  CM_Audio.swift
//  CinqMille
//
//  Created by BLIN Michael on 09/10/2025.
//

import AVFoundation

public class CC_Audio : NSObject {
	
	public enum Sounds : String, CaseIterable {
		
		case Success = "Success"
		case Error = "Error"
		case Button = "Button"
		case Tap = "Tap"
	}
	
	public static var shared:CC_Audio = .init()
	
	/// Cache des sons pré-chargés pour éviter les délais
	private var soundCache:[Sounds: AVAudioPlayer] = [:]
	
	/// Players de sons actifs (pour permettre plusieurs sons simultanés)
	private var activeSoundPlayers:[AVAudioPlayer] = []
	
	private var musicPlayer:AVAudioPlayer?
	
	/// Queue dédiée pour les opérations audio (évite les freezes sur le main thread)
	private let audioQueue = DispatchQueue(label: "com.cinqmille.audio", qos: .userInteractive)
	
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	public var isMusicEnabled:Bool {
		
		return (UserDefaults.get(.musicEnabled) as? Bool) ?? true
	}
	
	public override init() {
		
		super.init()
		
		// Configurer l'AVAudioSession une seule fois
		configureAudioSession()
		
		// Pré-charger tous les sons
		preloadSounds()
	}
	
	/// Configure l'AVAudioSession une seule fois au démarrage
	private func configureAudioSession() {
		
		do {
			// .playback avec .mixWithOthers : permet de jouer les sons sans couper la musique externe
			try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
			try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
		}
		catch {
			print("Erreur configuration AVAudioSession: \(error)")
		}
	}
	
	/// Pré-charge tous les sons en mémoire pour éviter les délais
	private func preloadSounds() {
		
		audioQueue.async { [weak self] in
			
			for sound in Sounds.allCases {
				
				if let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
					
					let url = URL(fileURLWithPath: path)
					
					if let player = try? AVAudioPlayer(contentsOf: url) {
						
						player.prepareToPlay()
						self?.soundCache[sound] = player
					}
				}
			}
		}
	}
	
	public func playSound(_ sound:Sounds) {
		
		guard isSoundsEnabled else { return }
		
		audioQueue.async { [weak self] in
			
			guard let self = self else { return }
			
			// Créer un nouveau player à partir du cache (copie pour permettre plusieurs sons simultanés)
			guard let cachedPlayer = self.soundCache[sound],
				  let url = cachedPlayer.url,
				  let player = try? AVAudioPlayer(contentsOf: url) else { return }
			
			player.prepareToPlay()
			
			DispatchQueue.main.async {
				player.delegate = self
				self.activeSoundPlayers.append(player)
				player.play()
			}
		}
	}
	
	public func playMusic() {
		
		stopMusic()
		
		guard isMusicEnabled else { return }
		
		if let index = (0...2).randomElement(), let path = Bundle.main.path(forResource: "music_\(index)", ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			if let player = try? AVAudioPlayer(contentsOf: url) {
				
				musicPlayer = player
				musicPlayer?.delegate = self
				musicPlayer?.prepareToPlay()
				musicPlayer?.play()
			}
		}
	}
	
	public func stopMusic() {
		
		musicPlayer?.stop()
		musicPlayer = nil
	}
}

extension CC_Audio : AVAudioPlayerDelegate {
	
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		
		// Si c'est la musique qui a fini, relancer une autre
		if player == musicPlayer {
			playMusic()
		}
		else {
			// Nettoyer les players de sons terminés
			DispatchQueue.main.async { [weak self] in
				self?.activeSoundPlayers.removeAll { $0 == player }
			}
		}
	}
}
