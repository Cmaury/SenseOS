//
//  SAYStateOpenMic.swift
//  SenseOS
//
//  Created by Chris Maury on 2/4/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateOpenMic: SAYGestureRecognizerDelegate {
    
    var caller = SAYStateResting(manager: nil) as AnyObject
    var callerState = 0
    let manager: SAYStateManager?
    
    init(manager: SAYStateManager?, caller: AnyObject = SAYStateResting(manager: nil) as AnyObject, callerState: Int = 0) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures(
                down: true,
                shakeVertical: true,
                shakeHorizontal: true)
            setActiveDelegate(self)
            self.caller = caller
            self.callerState = callerState          

            let request = SAYVerbalCommandRequest(commandRegistry: SAYConversationManager.systemManager().commandRegistry!)
            SAYConversationManager.systemManager().presentVoiceRequest(request)
        }
        else {
            self.manager = nil
        }
        
        
    }
    
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
        manager!.gestureRecognizer.activeDelegate = state
    }
    
    func didRecognizeGesture(gesture: SAYGesture) {
        switch gesture {
        case .down:
            print("pressed up")
        case .shakeVertical:
            print("pressed down")
        case .shakeHorizontal:
            //SAYSpeechRecognitionManager.stopListeningNow()
            
            manager?.activeState = SAYStateResting(manager: manager)
            print("shook horizontally")
        default: print("this gesture doesn't do anything")
            
            
        }
    }
}