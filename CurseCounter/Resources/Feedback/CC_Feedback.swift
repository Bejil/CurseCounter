//
//  CC_Feedback.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit

public class CC_Feedback : NSObject {
	
	public enum Style {
		
		case Error
		case Success
		case On
		case Off
	}
	
	public static var shared:CC_Feedback = .init()
	public var isVibrationsEnabled:Bool {
		
		return UserDefaults.get(.vibrationsEnabled) as? Bool ?? true
	}
	
	public func make(_ type:Style) {
		
		if isVibrationsEnabled {
			
			if type == .On || type == .Off {
				
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			}
			else {
				
				UINotificationFeedbackGenerator().notificationOccurred(type == .Success ? .success : .error)
			}
		}
	}
}
