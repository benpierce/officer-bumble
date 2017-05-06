//
//  GameViewController.swift
//  test
//
//  Created by Ben Pierce on 2014-11-28.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import GoogleMobileAds
import UIKit
import SpriteKit

class GameViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    var adErrorCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        var inTests = (NSClassFromString("SenTestCase") != nil ||
                      NSClassFromString("XCTest") != nil)
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.ShowAd), name: NSNotification.Name(rawValue: EVENT_TYPE.SHOW_AD.rawValue), object: nil)
        interstitial = createAndLoadInterstitial()
        
        // We don't want the application to run if we're in unit test mode.
 //       if ( !inTests ) {
            // Load all textures
            textureManager.PreloadTextures()
            
            let scene = TitleScreen(size: view.frame.size, resourceName: "titlescreen", isMuted: false)
            let skView = view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.ignoresSiblingOrder = true
            skView.showsPhysics = false
            skView.presentScene(scene)
            skView.isMultipleTouchEnabled = true
 //       }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // Show an ad on the screen.
    @objc fileprivate func ShowAd() {
        presentInterstitial()
    }
    
    //Interstitial func
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6543954261758189/4993733754")
        interstitial.delegate = self
        let request = GADRequest()
        
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID , "9f9aa567e07dfe69ffe9471ab72a27b2", "deefa816460b32dccb3a72e35c1cc8a6"]
        interstitial.load(request)
        
        return interstitial
    }
    
    func presentInterstitial() {
        if (interstitial.isReady) {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    //Interstitial delegate
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        adErrorCount = adErrorCount + 1
        
        if ( adErrorCount > 20 ) {
            interstitial = createAndLoadInterstitial()
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
}
