//
//  SAYStateResting.swift
//  SenseOS
//
//  Created by Chris Maury on 2/3/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateResting: SAYGestureRecognizerDelegate {
    
    let manager: SAYStateManager?
    init(manager: SAYStateManager?) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures(
                true,
                down: true)
            setActiveDelegate(self)
        }
        else {
            self.manager = nil
        }
        
        
    }
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
        manager!.gestureRecognizer.activeDelegate = state
    }
    
    let commandRegistry = SAYConversationManager.systemManager().commandRegistry as! SAYCommandRecognizerCatalog
    
    func uberRecognizerCall() {
        //let uberRecognizer = SAYCustomCommandRecognizer(customType: "uberRide", actionBlock:  { command in
            //self.manager?.viewController.soundBoard!.speakText("an Uber is on it's way and will be there in about 5 minutes.")
        //})
    }
    

    func didRecognizeGesture(gesture: SAYGesture) {
        switch gesture {
            case .up:
                print("pressed up")
                manager?.activeState = SAYStateQuickFeed(manager: manager)
            case .down:
                print("pressed down")
                let request = SAYVerbalCommandRequest(commandRegistry: SAYConversationManager.systemManager().commandRegistry!)
                SAYConversationManager.systemManager().presentVoiceRequest(	 request)
                manager?.activeState = SAYStateOpenMic(manager: manager)
            default: print("this gesture doesn't do anything")

            
        }
    }
}