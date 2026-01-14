//
//  CC_Settings_Button.swift
//  LettroLine
//
//  Created by BLIN Michael on 22/08/2025.
//

import UIKit

public class CC_Settings_Button : CC_Button {
	
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			
			UIAction(title: String(key: "settings.sounds"), subtitle: String(key: "settings.sounds." + (CC_Audio.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: CC_Audio.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				UserDefaults.set(!CC_Audio.shared.isSoundsEnabled, .soundsEnabled)
				
				CC_Audio.shared.play(.Button)
				
				self?.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "settings.vibrations"), subtitle: String(key: "settings.vibrations." + (CC_Feedback.shared.isVibrationsEnabled ? "on" : "off")), image: UIImage(systemName: CC_Feedback.shared.isVibrationsEnabled ? "water.waves" : "water.waves.slash"), handler: { [weak self] _ in
				
				UserDefaults.set(!CC_Feedback.shared.isVibrationsEnabled, .vibrationsEnabled)
				
				self?.menu = self?.settingsMenu
			})
		])
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		title = String(key: "settings.button")
		image = UIImage(systemName: "slider.vertical.3")?.applyingSymbolConfiguration(.init(scale: .medium))
		menu = settingsMenu
		showsMenuAsPrimaryAction = true
		type = .text
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
