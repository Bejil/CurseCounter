//
//  LL_Ads.swift
//  LettroLine
//
//  Created by BLIN Michael on 08/06/2024.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

public class CC_Ads : NSObject {
	
	public static let shared:CC_Ads = .init()
	
	private var appOpening:AppOpenAd?
	private var appOpeningPresentCompletion:(()->Void)?
	private var appOpeningDismissCompletion:(()->Void)?
	
	private var rewardedAdReward:AdReward?
	private var rewardedAdCompletion:((Bool,Bool?)->Void)?
	private var rewardedAd: RewardedAd?
	
	private var interstitialPresentCompletion:(()->Void)?
	private var interstitialDismissCompletion:(()->Void)?
	
	public var shouldDisplayAd:Bool {
		
		return (UserDefaults.get(.shouldDisplayAds) as? Bool ?? true) && ConsentInformation.shared.consentStatus == .obtained //&& !UIApplication.isDebug
	}
	
	public func start() {
		
		MobileAds.shared.start(completionHandler: nil)
	}
	
	public func presentAppOpening(_ presentCompletion:(()->Void)?, _ dismissCompletion:(()->Void)?) {
		
		if shouldDisplayAd {
			
			appOpeningPresentCompletion = presentCompletion
			appOpeningDismissCompletion = dismissCompletion
			
			AppOpenAd.load(with: Ads.FullScreen.AppOpening, request: Request()) { [weak self] ad, error in
				
				self?.appOpening = ad
				self?.appOpening?.fullScreenContentDelegate = self
				self?.appOpening?.present(from: UI.MainController)
			}
		}
		else {
			
			dismissCompletion?()
		}
	}
	
	public func presentInterstitial(_ identifier:String, _ presentCompletion:(()->Void)?, _ dismissCompletion:(()->Void)?) {
		
		if shouldDisplayAd {
			
			interstitialPresentCompletion = presentCompletion
			interstitialDismissCompletion = dismissCompletion
			
			InterstitialAd.load(with:identifier, request: Request(), completionHandler: { [weak self] ad, error in
				
				if let ad {
					
					ad.fullScreenContentDelegate = self
					ad.present(from: UI.MainController)
				}
				else {
					
					dismissCompletion?()
				}
			})
		}
		else {
			
			dismissCompletion?()
		}
	}
	
	public func presentRewardedAd(_ identifier:String, _ completion:((_ state:Bool, _ exception:Bool?)->Void)?) async {
		
		rewardedAdCompletion = completion
		
		do {
			
			rewardedAd = try await RewardedAd.load(with: identifier, request: Request())
			rewardedAd?.fullScreenContentDelegate = self
			
			if let ad = rewardedAd {
				
				ad.present(from: nil) { [weak self] in
					
					self?.rewardedAdReward = self?.rewardedAd?.adReward
				}
			}
		}
		catch {
			
			rewardedAdCompletion?(false,(error as NSError).code == 1)
			rewardedAdCompletion = nil
		}
	}
	
	public func presentBanner(_ identifier:String, _ rootViewController:UIViewController) -> BannerView {
		
		let bannerView:BannerView = .init(adSize: AdSizeBanner)
		bannerView.adUnitID = identifier
		bannerView.rootViewController = rootViewController
		bannerView.delegate = self
		
		if shouldDisplayAd {
			
			bannerView.load(Request())
		}
		
		return bannerView
	}
}

extension CC_Ads : FullScreenContentDelegate {
	
	public func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
		
		if ad is InterstitialAd {
			
			interstitialPresentCompletion?()
			interstitialPresentCompletion = nil
		}
		else if ad is AppOpenAd {
			
			appOpeningDismissCompletion?()
			appOpeningDismissCompletion = nil
		}
	}
	
	public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
		
		appOpening = nil
		
		if rewardedAd != nil && rewardedAdCompletion != nil && ad is RewardedAd {
			
			rewardedAdCompletion?(true,nil)
			
			rewardedAd = nil
			rewardedAdCompletion = nil
			rewardedAdReward = nil
		}
		else if ad is InterstitialAd {
			
			interstitialDismissCompletion?()
			interstitialDismissCompletion = nil
		}
		else if ad is AppOpenAd {
			
			appOpeningDismissCompletion?()
			appOpeningDismissCompletion = nil
		}
	}
	
	public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		
		if ad is InterstitialAd {
			
			interstitialDismissCompletion?()
			interstitialDismissCompletion = nil
		}
		else if rewardedAd != nil && rewardedAdCompletion != nil && ad is RewardedAd {
			
			rewardedAdCompletion?(false,nil)
			
			rewardedAd = nil
			rewardedAdCompletion = nil
			rewardedAdReward = nil
		}
		else if ad is AppOpenAd {
			
			appOpeningDismissCompletion?()
			appOpeningDismissCompletion = nil
		}
	}
}


extension CC_Ads : BannerViewDelegate {
	
	public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
		
		UIView.animation {
			
			bannerView.isHidden = true
			bannerView.alpha = bannerView.isHidden ? 0.0 : 1.0
			bannerView.superview?.layoutIfNeeded()
		}
	}
}

extension BannerView {
	
	open override func didMoveToSuperview() {
		
		super.didMoveToSuperview()
		
		NotificationCenter.add(.updateAds) { [weak self] _ in
											  
			self?.isHidden = !CC_Ads.shared.shouldDisplayAd
			self?.refresh()
		}
	}
	
	public func refresh() {
		
		if !isHidden {
			
			load(Request())
		}
	}
}
