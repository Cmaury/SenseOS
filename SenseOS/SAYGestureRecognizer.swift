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
}

class SAYGestureRecognizer {
    
   
    var setActiveDelegate = SAYState.resting
    
    func enableGestures(up: Bool = false, down: Bool = false, left: Bool = false, right: Bool = false, shakeHorizontal: Bool = false, shakeVertical: Bool = false) {
        
    }
        
}