//
//  SAYStateNotification.swift
//  SenseOS
//
//  Created by Chris Maury on 2/4/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateNotification: SAYGestureRecognizerDelegate {
    
    
    let manager: SAYStateManager?
    init(manager: SAYStateManager?) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures(
                left: true,
                right: true,
                shakeHorizontal: true,
                shakeVertical: true)
            setActiveDelegate(self)
        }
        else {
            self.manager = nil
        }
        
        
    }
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
        manager!.gestureRecognizer.activeDelegate = state
    }
    
    var direction = ""
    
    func didRecognizeGesture(gesture: SAYGesture) {
        switch gesture {
            case .left:
                if direction == "left" {
                    print("I should be speaking")
                    manager?.viewController.player?.stop()
                    manager?.viewController.soundBoard?.speakText("New Email from Greg. What's the good word?")
                }
                else {
                    manager?.viewController.player?.stop()
                    manager?.activeState = SAYStateResting(manager: manager)
            }
            
            case .right:
                if direction == "right" {
                    manager?.viewController.player?.stop()
                    manager?.viewController.soundBoard?.speakText("New Email from Greg. What's the good word?")
                }
                else {
                    manager?.viewController.player?.stop()
                    manager?.activeState = SAYStateResting(manager: manager)
            }
            case .shakeHorizontal:
                manager?.viewController.player?.stop()
                manager?.activeState = SAYStateResting(manager: manager)
            case .shakeVertical:
                manager?.viewController.player?.stop()
                manager?.viewController.soundBoard?.speakText("New Email from Greg. What's the good word?")
            default: print("this gesture doesn't do anything")
            
            
        }
    }
}
