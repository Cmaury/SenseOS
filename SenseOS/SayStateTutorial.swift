//
//  SayStateTutorial.swift
//  SenseOS
//
//  Created by Chris Maury on 2/10/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateTutorial: SAYGestureRecognizerDelegate {
    
    
    let manager: SAYStateManager?
    init(manager: SAYStateManager?) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures(
                true,
                down: true,
                shakeHorizontal: true)
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
            manager?.activeState = SAYStateQuickFeed(manager: manager)
            print("Nodded Up")
        case .down:
            manager?.activeState = SAYStateOpenMic(manager: manager, caller: self, callerState: 0)
            print("Nodded Down")
        case .shakeHorizontal:
            print("Shooke Horizontal")
            manager?.activeState = SAYStateResting(manager: manager)
        default: print("this gesture doesn't do anything")
            
            
        }
    }
    
    func startTutorial() {
        var notificationArray = [""]
        notificationArray.append("Welcome to Sense OS.")
        notificationArray.append("With Sense OS you can do everything you would normally do on your smart phone without ever having to take it out of your pocket.")
        notificationArray.append("Interact with your favorite apps with your voice and subtle motions of your head.")
        notificationArray.append("Ok. Here's how it works")
        notificationArray.append("Nod up to hear your recent notifications.")
        notificationArray.append("You can nod up again to hear your email, and again to listen to top posts on red it.")
        notificationArray.append("Shake your head at any time to stop.")
        notificationArray.append("Nod down to turn on the microphone and use a specific app like Uber or Yelp. ")
        notificationArray.append("You can ask to do the things you would normally do while using their apps.")
        notificationArray.append("Like I want an Uber or Where is the closest Chinese restaurant.")
        notificationArray.append("Finally, When your phone receives a notification youll hear a subtle sound playing. ")
        notificationArray.append("You can listen to the notification by turning towards the source of the sound,")
        notificationArray.append("or you can shake your head to dismiss it")
        notificationArray.append("That's it. Go ahead. Try it out for yourself")
        
        manager?.viewController.topicHandler?.speakText(notificationArray)

    }
}
