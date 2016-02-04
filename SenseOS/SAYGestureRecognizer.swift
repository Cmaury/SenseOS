//
//  SAYGestureRecognizer.swift
//  SenseOS
//
//  Created by Chris Maury on 2/3/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum SAYGesture {
    case up
    case down
    case left
    case right
    case shakeHorizontal
    case shakeVertical
}

protocol SAYGestureRecognizerDelegate {
    func didRecognizeGesture(gesture: SAYGesture)
    func setActiveDelegate(state: SAYGestureRecognizerDelegate)
}

class SAYGestureRecognizer {
    
    let viewController: ViewController
    var activeDelegate: SAYGestureRecognizerDelegate
    
    init(viewController: ViewController, delegate: SAYGestureRecognizerDelegate) {
        self.viewController = viewController
        self.activeDelegate = delegate
    }
   	
    
    func enableGestures(up: Bool = false, down: Bool = false, left: Bool = false, right: Bool = false, shakeHorizontal: Bool = false, shakeVertical: Bool = false) {
        
    }
    
    func recognizedGesture(gesture: SAYGesture) {
        activeDelegate.didRecognizeGesture(gesture)
    }
        
}