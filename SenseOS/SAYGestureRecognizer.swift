//
//  SAYGestureRecognizer.swift
//  SenseOS
//
//  Created by Chris Maury on 2/3/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum SAYGesture: String {
    case up
    case down
    case left
    case right
    case shakeHorizontal
    case shakeVertical
    
    var userDescription: String {
        switch self {
        case up:
            return "Nodded Up"
        case down:
            return "Nodded Down"
        case left:
            return "Looked Left"
        case right:
            return "Looked Right"
        case shakeHorizontal:
            return "Shook your head left and right"
        case shakeVertical:
            return "shook your head up and down"
        default: break
        }
    }
}

protocol SAYGestureRecognizerDelegate {
    func didRecognizeGesture(gesture: SAYGesture)
    func setActiveDelegate(state: SAYGestureRecognizerDelegate)
}

class SAYGestureRecognizer {
    
    
    var useGestures = true
    let viewController: ViewController
    var activeDelegate: SAYGestureRecognizerDelegate
    
    init(viewController: ViewController, delegate: SAYGestureRecognizerDelegate) {
        self.viewController = viewController
        self.activeDelegate = delegate
    }
   	
    
    let nodDetector = SAYNodDetector(windowSize: 5)
    var enabledGestures = [SAYGesture]()
    
    
    func detectGesture() {
        nodDetector.addPitchAngle(viewController.headset.pitch)
        nodDetector.addRollAngle(viewController.headset.roll)
        nodDetector.addYawAngle(viewController.headset.yaw)
        nodDetector.tick()
        
            for item in enabledGestures {
                if useGestures{
                    switch item {
                    case .up:
                        if nodDetector.isUpNod() {
                            recognizedGesture(SAYGesture.up)
                            //(viewController as NotificationTopicEventHandler).updateUI("nodded up")
                            print("nodded up")
                        }
                    case .down:
                        if nodDetector.isDownNod() {
                            recognizedGesture(SAYGesture.down)
                            print("Recognized Down")
                        }
                    case .left:
                        if nodDetector.isLeftNod() {
                            recognizedGesture(SAYGesture.left)
                            print("Recognized Look Left")
                        }
                    case .right:
                        if nodDetector.isRightNod() {
                            recognizedGesture(SAYGesture.right)
                            print("Recognized Look Right")
                        }
                    case .shakeHorizontal:
                        if nodDetector.isHShakeRecentlyEnded() {
                            recognizedGesture(SAYGesture.shakeHorizontal)
                            print("Recognized Shake Horizontal")
                        }
                    case .shakeVertical:
                        if nodDetector.isVShakeRecentlyEnded() {
                            recognizedGesture(SAYGesture.shakeVertical)
                            print("Recognized Shake Vertical")
                        }
                    }
                    
                }
//                else {
//                    if self.nodDetector.isHShakeRecentlyEnded() && item == SAYGesture.shakeHorizontal {
//                        self.recognizedGesture(SAYGesture.shakeHorizontal)
//                        print("Recognized Shake Horizontal")
//                    }
//                    if self.nodDetector.isVShakeRecentlyEnded() && item == SAYGesture.shakeVertical {
//                        self.recognizedGesture(SAYGesture.shakeVertical)
//                        print("Recognized Shake Vertical")
//                    }
//                }
        }
    }
    
    
    func enableGestures(up: Bool = false, down: Bool = false, left: Bool = false, right: Bool = false, shakeHorizontal: Bool = false, shakeVertical: Bool = false) {
        
        enabledGestures = []	
        if up {
            enabledGestures.append(SAYGesture.up)
        }
        if down {
            enabledGestures.append(SAYGesture.down)
        }
        if left {
            enabledGestures.append(SAYGesture.left)
        }
        if right {
            enabledGestures.append(SAYGesture.right)
        }
        if shakeHorizontal {
            enabledGestures.append(SAYGesture.shakeHorizontal)
        }
        if shakeVertical {
            enabledGestures.append(SAYGesture.shakeVertical)
        }
        
        
    }
    
    func recognizedGesture(gesture: SAYGesture) {
        activeDelegate.didRecognizeGesture(gesture)
    }
        
}