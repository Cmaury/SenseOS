//
//  StateManager.swift
//  SenseOS
//
//  Created by Chris Maury on 2/3/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum SAYState {
    case resting 
    case notification
    case openMic
    case quickFeed
}

class SAYStateManager: SAYGestureRecognizerDelegate  {
    
    let viewController: ViewController
    var activeState: SAYGestureRecognizerDelegate?
    var gestureRecognizer: SAYGestureRecognizer
    
    init(viewController: ViewController)
    {
        self.viewController = viewController
        self.activeState = SAYStateResting(manager: nil)
        self.gestureRecognizer = SAYGestureRecognizer(viewController: viewController, delegate: self.activeState!)
    }
    
    func didRecognizeGesture(gesture: SAYGesture) {
        switch gesture {
            default: print("active state not set")
        }
    }
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
    }
    
    var state = SAYState.resting {
        
        willSet {
            activeState = nil
        }
        
        didSet(currentState) {

            switch state {
                case .resting:
                    activeState = SAYStateResting(manager: self)
                case .notification:
                    activeState = SAYStateNotification(manager: self)
                case .openMic:
                    activeState = SAYStateOpenMic(manager: self)
                case .quickFeed:
                    	activeState = SAYStateQuickFeed(manager: self)
            }
        }
    }
    
   
}
