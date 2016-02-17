//
//  SAYStateQuickFeed.swift
//  SenseOS
//
//  Created by Chris Maury on 2/5/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateQuickFeed: SAYGestureRecognizerDelegate {
    
    let manager: SAYStateManager?
    init(manager: SAYStateManager?) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures(
                true,
                down: true,
                left: true,
                right: true,
                shakeHorizontal: true,
                shakeVertical: true)
            setActiveDelegate(self)
            
            manager.viewController.topicHandler?.clearQueue()
            
            var notificationArray = [""]
            notificationArray.append("New Notifications:  eye message from Greg")
            notificationArray.append("Email from Meredith. No Subject")
            notificationArray.append("NY Times breaking news. Supreme Court Justice Antonin Scalia has died, age 79.")
            
            if manager.viewController.inTutorial == true {
                manager.viewController.topicHandler?.speakTextAnd(notificationArray, action: CurrentRequest.tutorialRequest2)
            }
            
            else {
                manager.viewController.topicHandler?.speakText(notificationArray)
            }
        }
        else {
            self.manager = nil
        }
        
        
    }
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
        manager!.gestureRecognizer.activeDelegate = state
    }
    
    var feedIndex = 0
    
    func didRecognizeGesture(gesture: SAYGesture) {
        if manager?.viewController.inTutorial == true {
            manager!.state = SAYState.resting
        }
        else {
            switch gesture {
            case .up:
                print("pressed up")
                
                feedIndex = feedIndex + 1
                
                if feedIndex == 1 {
                    var notificationArray = [""]
                    notificationArray.append("Inbox: Meredith Stern. No Subject.")
                    notificationArray.append("Adam Larsen. Reply. lunch friday?")
                    notificationArray.append("DeltaAirlines. You're flight is delayed.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 2 {
                    
                    var notificationArray = [""]
                    notificationArray.append("Red it: Sanders tied with Clinton nationwied: Poll. 5k votes.")
                    notificationArray.append("New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
                    notificationArray.append("Mexico won't pay a cent for Trump's stupid wall. 5.6k votes.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 3 {
                    var notificationArray = [""]
                    notificationArray.append("Twitter: David Yanofsky: The Super Bowl can triple private jet travel. qz.com.")
                    notificationArray.append("Caleb Hunt: Strategy one. Score some more goals.")
                    notificationArray.append("Robert Beschizza. My favorite conspiracy theory: Britain retired its space program the week David Bowie began recording Ziggy Stardust.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                
            case .down:
                manager?.activeState = SAYStateOpenMic(manager: manager, caller: self, callerState: feedIndex)
            case .shakeHorizontal:
                feedIndex = 0
                manager?.activeState = SAYStateResting(manager: manager)
                
                
            case .left:
                if feedIndex == 1 {
                    var notificationArray = [""]
                    notificationArray.append("Inbox: Meredith Stern. No Subject.")
                    notificationArray.append("Adam Larsen. Reply. lunch friday?")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 2 {
                    var notificationArray = [""]
                    notificationArray.append("Red it: Sanders tied with Clinton nationwied: Poll. 5k votes.")
                    notificationArray.append("New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 3 {
                    var notificationArray = [""]
                    notificationArray.append("Twitter: David Yanofsky: The Super Bowl can triple private get travel. qz.com.")
                    notificationArray.append("Caleb Hunt: Strategy one. Score some more goals.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                
            case .right:
                if feedIndex == 1 {
                    var notificationArray = [""]
                    notificationArray.append("Adam Larsen. Reply. lunch friday?")
                    notificationArray.append("DeltaAirlines. You're flight is delayed.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 2 {
                    var notificationArray = [""]
                    notificationArray.append("New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
                    notificationArray.append("Mexico won't pay a cent for Trump's stupid wall. 5.6k votes.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
                if feedIndex == 3 {
                    var notificationArray = [""]
                    notificationArray.append("Caleb Hunt: Strategy one. Score some more goals.")
                    notificationArray.append("Robert Beschizza. My favorite conspiracy theory: Britain retired its space program the week David Bowie began recording Ziggy Stardust.")
                    manager?.viewController.topicHandler?.speakText(notificationArray)
                }
            default: print("this gesture doesn't do anything")
                
                
            }
        }
    }
}