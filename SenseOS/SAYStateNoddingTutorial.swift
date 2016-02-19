//
//  SAYStateNoddingTutorial.swift
//  SenseOS
//
//  Created by Chris Maury on 2/18/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SAYStateNoddingTutorial: SAYGestureRecognizerDelegate {
    let tone = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("chime_bell_ding-2", ofType: "wav")!)
    let manager: SAYStateManager?
    init(manager: SAYStateManager?) {
        if let manager = manager {
            self.manager = manager
            manager.gestureRecognizer.enableGestures()
            setActiveDelegate(self)
            manager.viewController.topicHandler?.clearQueue()
        }
        else {
            self.manager = nil
        }
        
        
    }
    
    func setActiveDelegate(state: SAYGestureRecognizerDelegate) {
        manager?.gestureRecognizer.activeDelegate = state
    }
    
    
    var gestureCount = 0
    var recognizedGestures: Set<String> = ["up", "down", "left", "right", "shakeH", "shakeV"]
    
    func didRecognizeGesture(gesture: SAYGesture) {
        gestureCount++
        manager?.viewController.soundBoard?.playToneWithURL(tone)
        let sequence = SAYAudioEventSequence()
        switch gesture {
            case .up:
                
                if recognizedGestures.contains("up") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "You Nodded Up"))
                }
                recognizedGestures.remove("up")
                print("pressed up")
            case .down:
                if recognizedGestures.contains("down") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString:"You Nodded down"))
                }
                recognizedGestures.remove("down")
                print("pressed down")
            case .left:
                if recognizedGestures.contains("left") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString:"You Looked Left"))
                }
                recognizedGestures.remove("left")
            case .right:
                if recognizedGestures.contains("right") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString:"You Looked Right"))
                }
                recognizedGestures.remove("right")
            case .shakeHorizontal:
                if recognizedGestures.contains("shakeH") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString:"You Shooke your head left and right"))
                }
                recognizedGestures.remove("shakeH")
            case .shakeVertical:
                if recognizedGestures.contains("shakeV") {
                    sequence.addEvent(SAYSpeechEvent(utteranceString:"You Shooke your head up and down"))
                }
                recognizedGestures.remove("shakeV")
            default: print("this gesture doesn't do anything")
            
            
        }
        if gestureCount > 8 {
            
                switch recognizedGestures {
                    case ["up"]:
                        sequence.addEvent(SAYSpeechEvent(utteranceString: "Try tilting your head up"))
                    case ["down"]:
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "Try tilting your head down"))
                    case ["left"]:
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "Look to your left"))
                    case ["right"]:
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "Look to your right"))
                    case ["shakeH"]:
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "Try shaking your head left to right"))
                    case ["shakeV"]:
                    sequence.addEvent(SAYSpeechEvent(utteranceString: "Try shaking your head up and down"))
                    default: break
                }
            
        }
        if recognizedGestures.isEmpty  {
            manager?.state = SAYState.resting
            sequence.addEvent(SAYSpeechEvent(utteranceString: ""), withCompletionBlock: {
                self.manager?.viewController.topicHandler?.tutorialRequest1_5()
            })
            
        }
        manager?.viewController.topicHandler?.postEvents(sequence)
    }
}