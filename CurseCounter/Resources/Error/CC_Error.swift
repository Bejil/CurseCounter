//
//  CC_Error.swift
//  CinqMille
//
//  Created by BLIN Michael on 06/08/2023.
//

import Foundation

public class CC_Error : NSError, @unchecked Sendable {
	
	public convenience init(_ string:String?) {
		
		self.init(domain: Bundle.main.bundleIdentifier ?? "", code: 000, userInfo: [NSLocalizedDescriptionKey: string ?? ""])
	}
}
