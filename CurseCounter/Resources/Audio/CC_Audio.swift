//
//  CC_Audio.swift
//  LetttroLine
//
//  Created by BLIN Michael on 09/10/2025.
//

import AVFoundation

public class CC_Audio : NSObject {
	
	public enum Sounds : String {
		
		case Success = "Success"
		case Error = "Error"
		case Button = "Button"
		case Tap = "Tap"
	}
	
	public static var shared:CC_Audio = .init()
	private var soundPlayer:AVAudioPlayer?
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	
	public func play(_ sound:Sounds) {
		
		stopSound()
		
		if isSoundsEnabled, let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			try?AVAudioSession.sharedInstance().setCategory(.playback)
			try?AVAudioSession.sharedInstance().setActive(true)
			
			try?soundPlayer = AVAudioPlayer(contentsOf: url)
			soundPlayer?.prepareToPlay()
			soundPlayer?.play()
		}
	}
	
	private func stopSound() {
		
		soundPlayer?.stop()
		soundPlayer = nil
	}
}
