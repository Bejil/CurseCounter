//
//  Constants.swift
//  CurseCounter
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit

public struct UI {
	
	static var MainController :UIViewController {
		
		return UIApplication.shared.topMostViewController()!
	}
	
	public static let Margins:CGFloat = 15.0
	public static let CornerRadius:CGFloat = 18.0
}

public struct Colors {
	
	public static let Primary:UIColor = UIColor(named: "Primary")!
	public static let Secondary:UIColor = UIColor(named: "Secondary")!
	public static let Tertiary:UIColor = UIColor(named: "Tertiary")!
	
	public struct Background {
		
		public static let Application:UIColor = UIColor(named: "ApplicationBackground")!
		public static let View:UIColor = UIColor(named: "ViewBackground")!
	}
	
	public struct Navigation {
		
		public static let Title:UIColor = UIColor(named: "NavigationTitle")!
		public static let Button:UIColor = UIColor(named: "NavigationButton")!
	}
	
	public struct Content {
		
		public static let Title:UIColor = UIColor(named: "ContentTitle")!
		public static let Text:UIColor = UIColor(named: "ContentText")!
	}
	
	public struct Button {
		
		public static let Badge:UIColor = UIColor(named: "ButtonBadge")!
		
		public struct Primary {
			
			public static let Background:UIColor = UIColor(named: "ButtonPrimaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonPrimaryContent")!
		}
		
		public struct Secondary {
			
			public static let Background:UIColor = UIColor(named: "ButtonSecondaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonSecondaryContent")!
		}
		
		public struct Tertiary {
			
			public static let Background:UIColor = UIColor(named: "ButtonTertiaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonTertiaryContent")!
		}
		
		public struct Delete {
			
			public static let Background:UIColor = UIColor(named: "ButtonDeleteBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonDeleteContent")!
		}
		
		public struct Navigation {
			
			public static let Background:UIColor = UIColor(named: "ButtonNavigationBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonNavigationContent")!
		}
		
		public struct Text {
			
			public static let Background:UIColor = UIColor(named: "ButtonTextBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonTextContent")!
		}
	}
	
	public struct Hits {
		
		public static let Wrong:UIColor = UIColor(named: "HitsWrong")!
		public static let Perfect:UIColor = UIColor(named: "HitsPerfect")!
		public static let Great:UIColor = UIColor(named: "HitsGreat")!
		public static let Good:UIColor = UIColor(named: "HitsGood")!
	}
}

public struct Fonts {
	
	private struct Name {
		
		static let Regular:String = "TTInterphasesProTrl-Rg"
		static let Bold:String = "TTInterphasesProTrl-Bd"
		static let Black:String = "GROBOLD"
	}
	
	public static let Size:CGFloat = 13
	
	public struct Navigation {
		
		public struct Title {
			
			public static let Large:UIFont = UIFont(name: Name.Black, size: Fonts.Size+25)!
			public static let Small:UIFont = UIFont(name: Name.Black, size: Fonts.Size+12)!
		}
		
		public static let Button:UIFont = UIFont(name: Name.Black, size: Fonts.Size)!
	}
	
	public struct Content {
		
		public struct Text {
			
			public static let Regular:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
			public static let Bold:UIFont = UIFont(name: Name.Bold, size: Fonts.Size)!
		}
		
		public struct Button {
			
			public static let Title:UIFont = UIFont(name: Name.Black, size: Fonts.Size+4)!
			public static let Subtitle:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
		}
		
		public struct Title {
			
			public static let H1:UIFont = UIFont(name: Name.Black, size: Fonts.Size+30)!
			public static let H2:UIFont = UIFont(name: Name.Black, size: Fonts.Size+11)!
			public static let H3:UIFont = UIFont(name: Name.Black, size: Fonts.Size+8)!
			public static let H4:UIFont = UIFont(name: Name.Black, size: Fonts.Size+5)!
		}
	}
}

public struct Ads {
	
	public struct FullScreen {
		
		static let AppOpening:String = "ca-app-pub-9540216894729209/6153578798"
		
		public struct Game {
			
			static let Start:String = "ca-app-pub-9540216894729209/8351354960"
			static let End:String = "ca-app-pub-9540216894729209/7038273296"
		}
	}
	
	public struct Banner {
		
		static let Menu:String = "ca-app-pub-9540216894729209/7369445786"
		static let Game:String = "ca-app-pub-9540216894729209/1961206432"
	}
}
