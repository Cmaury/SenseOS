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

class SAYStateManager  {
    
    let viewController: ViewController
    
    init(viewController: ViewController)
    {
        self.viewController = viewController
    }
    
    var state = SAYState.resting {
        
        didSet(currentState) {

            
           viewController.gestureRecognizer.setActiveState(currentState)

            switch state {
                case .resting:
                    self.viewController.gestureRecognizer.enableGestures(
                        up: true,
                        down: true)
                case .notification:
                    ViewController.gestureRecognizer.enableGestures(
                        left: true,
                        right: true,
                        shakeHorizontal: true,
                        shakeVertical: true)
                case .openMic:
                    ViewController.gestureRecognizer.enableGestures(
                        down: true,
                        shakeHorizontal: true)
                case .quickFeed:
                    ViewController.gestureRecognizer.enableGestures(
                        up: true,
                        down: true,
                        left: true,
                        right: true,
                        shakeHorizontal: true,
                        shakeVertical: true)
            }
        }
    }
    
   
}
