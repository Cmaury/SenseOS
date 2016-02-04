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

    func didRecognizeGesture(gesture: SAYGesture) {
        switch gesture {
            case .up:
                print("pressed up")
            case .down:
                 print("pressed down")
            default: print("this gesture doesn't do anything")

            
        }
    }
}