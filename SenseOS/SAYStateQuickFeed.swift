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
            var notificationArry = [""]
            notificationArry.append("New Notifications:  eye message from Greg")
            notificationArry.append("Email from Meredith. No Subject")
            notificationArry.append("NY Times breaking news...")
            
            for var i = 0; i < notificationArry.count; i+0 {
                manager.viewController.soundBoard?.speakText(notificationArry[i], then: {i++})
            }
           

            
           // let request = SAYVerbalCommandRequest(commandRegistry: SAYConversationManager.systemManager().commandRegistry!)
            //SAYConversationManager.systemManager().presentVoiceRequest(request)
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
        switch gesture {
        case .up:
            print("pressed up")
            
            feedIndex = feedIndex + 1
            
            if feedIndex == 1 {
                manager?.viewController.soundBoard?.speakText("Inbod: Meredith Stern. No Subject. Adam Larsen. Reply. lunch friday?")
            }
            if feedIndex == 2 {
                manager?.viewController.soundBoard?.speakText("Reddit: Sanders tied with Clinton nationwied: Poll. 5k votes. New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
            }
            if feedIndex == 3 {
                manager?.viewController.soundBoard?.speakText("Twitter: David Yanofsky: The Super Bowl can triple private get travel. qz.com.  Caleb Hunt: Strategy one. Score some more goals.")
            }
            
        case .down:
            print("pressed down")
            if feedIndex == 1 {
                manager?.viewController.soundBoard?.speakText("Meredith Stern: No Subject. youtube link. Baby faling on her own birthday cake.")
            }
            if feedIndex == 2 {
                manager?.viewController.soundBoard?.speakText("Comments for Sanders tied with Clinton. PancackesYes said My guess is that Hillary's internal data already showed this.")
            }
            if feedIndex == 3 {
                manager?.viewController.soundBoard?.speakText("New Message. What would you like to say?")
            }
            
        case .shakeHorizontal:
            feedIndex = 0
            manager?.activeState = SAYStateResting(manager: manager)
            
            
        case .left:
            if feedIndex == 1 {
                manager?.viewController.soundBoard?.speakText("Inbod: Meredith Stern. No Subject. Adam Larsen. Reply. lunch friday?")
            }
            if feedIndex == 2 {
                manager?.viewController.soundBoard?.speakText("Reddit: Sanders tied with Clinton nationwied: Poll. 5k votes. New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
            }
            if feedIndex == 3 {
                manager?.viewController.soundBoard?.speakText("Twitter: David Yanofsky: The Super Bowl can triple private get travel. qz.com.  Caleb Hunt: Strategy one. Score some more goals.")
            }
            
        case .right:
            if feedIndex == 1 {
                manager?.viewController.soundBoard?.speakText("IAdam Larsen. Reply. lunch friday?")
            }
            if feedIndex == 2 {
                manager?.viewController.soundBoard?.speakText("New study shows regrowing tropical forest sequester more carbon and recover more quickly than previously thought. 5.6k votes.")
            }
            if feedIndex == 3 {
                manager?.viewController.soundBoard?.speakText("Caleb Hunt: Strategy one. Score some more goals.")
            }
        default: print("this gesture doesn't do anything")
            
            
        }
    }
}