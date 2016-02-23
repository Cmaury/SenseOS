//
//  MyTopic.swift
//  SenseOS
//
//  Created by Chris Maury on 2/16/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//



import Foundation

protocol MyTopicEventHandler: class {
    
}

class MyTopic: SAYConversationTopic {
    let eventHandler: MyTopicEventHandler
    let viewController: ViewController
    init(eventHandler: MyTopicEventHandler, viewController: ViewController) {
        self.eventHandler = eventHandler
        self.viewController = viewController
        super.init()
        
        
    }
    
    let startTone = NSBundle.mainBundle().pathForResource("beep_short_on", ofType: "wav")
    
    let endTone = NSBundle.mainBundle().pathForResource("beep_short_off", ofType: "wav")
    
    func recordGesture(prompt: String, gesture: gestureLabel) {
        print("current gesture is \(gesture)")
        let sequence = SAYAudioEventSequence()
        
        sequence.addEvent(SAYSpeechEvent(utteranceString: prompt))
        sequence.addEvent(SAYToneEvent(audioURL: NSURL(fileURLWithPath: startTone!)), withCompletionBlock: {
                self.viewController.gestureUID++
                self.viewController.currentGestureLabel = gesture
        })
        sequence.addEvent(SAYSilenceEvent(interval:2.0))
        sequence.addEvent(SAYToneEvent(audioURL: NSURL(fileURLWithPath: endTone!)), withCompletionBlock: {
                self.viewController.currentGestureLabel = gestureLabel.None
            })
        sequence.addEvent(SAYSilenceEvent(interval: 6.0), withCompletionBlock: {
            self.viewController.setGestureToBeRecorded()
        })
        self.postEvents(sequence)
    }
    
    
    
}