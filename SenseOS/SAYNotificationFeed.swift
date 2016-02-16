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
    func handlePlay()
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
}

class SAYNotificationFeed: SAYConversationTopic {
    
    var uber: SAYCustomCommandRecognizer!
    var yelp: SAYCustomCommandRecognizer!
    
    let eventHandler: NotificationTopicEventHandler
    init(eventHandler: NotificationTopicEventHandler) {
        self.eventHandler = eventHandler
        
        super.init()
        
        
        
        //self.speakTextAnd(tutorialPrompt1, action: CurrentRequest.tutorialRequest1)
        
        uber = SAYCustomCommandRecognizer(customType: "uber",  actionBlock: { command in

            self.speakTextAnd( ["Ride Requested. Once a driver accepts, we'll let you know"] + self.tutorialPrompt3, action: CurrentRequest.tutorialRequest3)
        })
        var patterns = ["uber", "current location", "lift", "lyft", "ride", "cab", "oober"]
        uber.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
       
        yelp = SAYCustomCommandRecognizer(customType: "yelp",  actionBlock: { command in
            
            self.speakTextAnd(["Han Chinese restaurant is two blocks away. Would you like directions?"] + self.tutorialPrompt3, action: CurrentRequest.tutorialRequest3)
        })
        
        patterns = ["food", "near", "hungry", "closest", "chinese", "restaurant"]
        yelp.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        
       
        //reply Recognizer
        let replyRecognizer = SAYCustomCommandRecognizer(customType: "reply",  actionBlock: { command in
            print("heard reply command")
            eventHandler.handleReply()
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
            case .tutorialRequest6: break
            default: break
            }
        }
    }
    
    let tutorialPrompt1 = ["Welcome to Sense OS.",
            "With SenseOS you can do everything you would normally do on your smartphone without ever taking it out of your pocket.",
            "Interact with your favorite apps with your voice and subtle motions of your head.",
            "Ok. Here's how it works",
            "Nod up to hear your recent notifications.",
            "You can nod up again to hear your email. and again to hear recent articles from red it.",
            "Go ahead and try nodding up now."
                        ]
    
    let tutorialPrompt2 = ["Nod down to turn on the microphone and use a specific app like Uber or Yelp.",
        "You can ask to do the things you would normally do while using their apps.",
        "Like I want an Uber or Where is the closest Chinese restaurant.",
        "Go ahead and try it out."
    ]
    let tutorialPrompt3 = ["Finally, when your phone receives a notification, youll hear a subtle notification",
        "You can listen to the notification by turning towards the source of the sound.",
        "Or, you can shake your head to dismiss it",
        "Sending you a test notification now."
        ]
    let tutorialPrompt4 = ["That's all there is to know. Enjoy using Sense OS!"]
    
    func tutorialRequest1() {
        self.addCommandRecognizer(uber)
        let request = SAYVerbalCommandRequest(commandRegistry: self)
        SAYConversationManager.systemManager().presentVoiceRequest(request)
    }
    
    func tutorialRequest2() {
        self.addCommandRecognizer(uber)
        self.addCommandRecognizer(yelp)
        self.speakText(tutorialPrompt2)
    }
    
    func tutorialRequest3() {
        (eventHandler as! ViewController).playNotificaiton(self)
    }
    
    func tutorialRequest4() {
        self.speakTextAnd(tutorialPrompt4, action: CurrentRequest.tutorialRequest5)
    }
    
    func speakTextAnd(text: [String], action: CurrentRequest ) {
        let sequence = SAYAudioEventSequence()
        for (index, item) in text.enumerate() {
            if index == text.count - 1 {
                self.eventHandler.updateUI(item)
                sequence.addEvent(SAYSpeechEvent(utteranceString: item))
                sequence.addEvent(SAYSilenceEvent(interval: 0.75), withCompletionBlock: {
                    self.currentRequest = action
                })

            }
            else {
                sequence.addEvent(SAYSpeechEvent(utteranceString: item), withCompletionBlock: {
                    self.eventHandler.updateUI(item)
                })
                sequence.addEvent(SAYSilenceEvent(interval: 0.5))
            }
        }
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
}