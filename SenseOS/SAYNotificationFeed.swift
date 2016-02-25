//
//  SAYNotificationFeed.swift
//  SenseOS
//
//  Created by Chris Maury on 2/7/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

protocol NotificationTopicEventHandler: class {
    func updateUI(text: String)
    func finishTutorial()
    func handleUber()
    func handlePrevious()
    func handleNext()
    func handleSelect()
    func handleStop()
    func handleRead()
    func handleReply()
    func handleDelete()
    func handleShare()
    func handleComments()
    
}

enum CurrentRequest {
    case tutorialRequest1
    case tutorialRequest2
    case tutorialRequest3
    case tutorialRequest4
    case tutorialRequest5
    case tutorialRequest6
    case tutorialRequest7
}

class SAYNotificationFeed: SAYConversationTopic {
    var calledUber = false
    var uber: SAYCustomCommandRecognizer!
    var yelp: SAYCustomCommandRecognizer!
    let tone = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pad_confirm", ofType: "wav")!)
    let eventHandler: NotificationTopicEventHandler
    var viewController: ViewController
    init(eventHandler: NotificationTopicEventHandler) {
        self.eventHandler = eventHandler
        self.viewController = eventHandler as! ViewController
        super.init()
        
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: ""))
        self.postEvents(sequence)
        viewController.headset.pause()
        
        uber = SAYCustomCommandRecognizer(customType: "uber",  actionBlock: { command in
            
            
            
            let sequence = SAYAudioEventSequence()
            sequence.addEvent(SAYSpeechEvent(utteranceString: "Ride Requested. Waiting for Driver"))
            sequence.addEvent(SAYToneEvent(audioURL: self.tone))
            sequence.addEvent(SAYSpeechEvent(utteranceString: "Jessie has accepted your request. She should be there in 5 minutes. Keep track of her progress by following the sound of her car."), withCompletionBlock: {
                self.viewController.stateManager.gestureRecognizer.enableGestures()
                self.eventHandler.handleUber()
            })
            self.calledUber = true
            self.postEvents(sequence)
        })
        var patterns = ["@blah"]
        uber.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        
        
       
        //reply Recognizer
        let replyRecognizer = SAYCustomCommandRecognizer(customType: "reply",  actionBlock: { command in
            print("heard reply command")
            eventHandler.handleReply()
            

            let testurl = NSURL(string: "URLTest://SenseOS/request=blah")
            UIApplication.sharedApplication().openURL(testurl!)
        })
        
        patterns = ["reply", "respond", "answer"]
        replyRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        self.addCommandRecognizer(replyRecognizer)
        
        //Read recognizer
        let readRecognizer = SAYCustomCommandRecognizer(customType: "read",  actionBlock: { command in
            print("heard read command")
            eventHandler.handleRead()
        })
        patterns = ["read", "open"]
        replyRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        self.addCommandRecognizer(readRecognizer)

        //share recognizer
        let shareRecognizer = SAYCustomCommandRecognizer(customType: "reply",  actionBlock: { command in
            print("heard share command")
            eventHandler.handleShare()
        })
        patterns = ["save", "share", "facebook", "Twitter"]
        replyRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        self.addCommandRecognizer(shareRecognizer)
        
    }
    
    var currentRequest: CurrentRequest? = nil {
        didSet {
            switch currentRequest! {
            case .tutorialRequest1:
                tutorialRequest1()
            case .tutorialRequest2:
                tutorialRequest2()
            case .tutorialRequest3:
                tutorialRequest3()
            case .tutorialRequest4:
                tutorialRequest4()
            case .tutorialRequest5:
                eventHandler.finishTutorial()
            case .tutorialRequest6:
                self.playSilence()
                viewController.stateManager.gestureRecognizer.enableGestures(true)
            case .tutorialRequest7:
                viewController.stateManager.gestureRecognizer.enableGestures(down: true)
            default: break
            }
        }
    }
    
    let tutorialPrompt1 = ["Welcome to Sense OS.",
            "With SenseOS you can do everything you would normally do on your smartphone without ever taking it out of your pocket.",
            "Use your favorite apps with your voice and the subtle motions of your head.",
            "To use Sense OS you can, Look up, down, left, and right. You can also nod or shake your head.",

        "You'll hear a ding everytime you make a movement that SenseOS can understand.",
        "Why don't you try it now?"
        ]
    
    let tutorialPrompt1_5 = ["Great Job! Those are all the movements you need to know to use SenseOS",
            "Now here is how you can put those movements to work",
            "Nod up to hear your recent notifications.",
            "You can nod up again to hear your email. and again to hear recent articles from red it.",
            "Go ahead and try nodding up now."
                        ]
    
    let tutorialPrompt2 = ["You can Nod down to turn on the microphone and use SenseOS with your voice",
        "You can ask to do the things you would normally do while using a smartphone app.",
        "For example, if you wanted to order an Uber you could say  I want an Uber or I need a ride home.",
        "Give it a try."
    ]
    let tutorialPrompt3 = ["Finally, when your phone receives a notification, youll hear a subtle audio message",
        "You can listen to the notification by turning towards the source of the sound.",
        "Or, you can shake your head to dismiss it",
        "Sending you a test notification now."
        ]
    let tutorialPrompt4 = ["That's all there is to know. Enjoy using Sense OS!"]
    
    func tutorialRequest1() {
        print("the current state is \(viewController.stateManager.gestureRecognizer.enabledGestures)")
        viewController.stateManager.gestureRecognizer.enableGestures(true, down: true, left: true, right: true, shakeHorizontal: true, shakeVertical: true)
    }
    
    func tutorialRequest2() {
        
        self.speakTextAnd(tutorialPrompt2, action: CurrentRequest.tutorialRequest7)
    }
    
    func tutorialRequest3() {
        viewController.stateManager.gestureRecognizer.enableGestures( down: false, left: true, right: true, shakeHorizontal: true, shakeVertical: true)
        viewController.playNotificaiton(self)
    }
    
    func tutorialRequest4() {
        self.speakTextAnd(tutorialPrompt4, action: CurrentRequest.tutorialRequest5)
        self.removeCommandRecognizer(uber)
    }
    
    func tutorialRequest1_5() {
        viewController.stateManager.gestureRecognizer.enableGestures()
        self.addCommandRecognizer(uber)
        speakTextAnd(tutorialPrompt1_5, action: CurrentRequest.tutorialRequest6)
    }
    
    func speakTextAnd(text: [String], action: CurrentRequest ) {
        let sequence = SAYAudioEventSequence()
        for item in text {
            sequence.addEvent(SAYSpeechEvent(utteranceString: item), withCompletionBlock: {
                self.eventHandler.updateUI(item)
            })
        }
        sequence.addEvent(SAYSpeechEvent(utteranceString: ""), withCompletionBlock: {
            self.currentRequest = action
        })
//            sequence.addEvent(SAYSilenceEvent(interval: 0.5))
//            if index == text.count - 1 {
//                self.eventHandler.updateUI(item)
//                sequence.addEvent(SAYSpeechEvent(utteranceString: item))
//                sequence.addEvent(SAYSilenceEvent(interval: 0.75), withCompletionBlock: {
//                    self.currentRequest = action
//                })
//
//            }
//            else {
//                sequence.addEvent(SAYSpeechEvent(utteranceString: item), withCompletionBlock: {
//                    self.eventHandler.updateUI(item)
//                })
//                sequence.addEvent(SAYSilenceEvent(interval: 0.5))
//            }
//        }
        self.postEvents(sequence)
    }
    
    func speakText(text: [String]) {
        let sequence = SAYAudioEventSequence()
        for item in text {
            sequence.addEvent(SAYSpeechEvent(utteranceString: item), withCompletionBlock: {
                self.eventHandler.updateUI(item)
            })
            sequence.addEvent(SAYSilenceEvent(interval: 0.5))
        }
        self.postEvents(sequence)
    }
 
    func clearQueue() {
        speakText([""])
    }
    func playSilence(time: NSTimeInterval = 5.0) {
        let sequence = SAYAudioEventSequence()
        
        sequence.addEvent(SAYSilenceEvent(interval: time))
        
        self.postEvents(sequence)
    }
}