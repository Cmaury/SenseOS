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
    
    var tutorialRecognizer1: SAYCustomCommandRecognizer!
    
    let eventHandler: NotificationTopicEventHandler
    init(eventHandler: NotificationTopicEventHandler) {
        self.eventHandler = eventHandler
        
        super.init()
        
       
        self.addCommandRecognizer(SAYAvailableCommandsCommandRecognizer(responseTarget: self, action: "availableCommandsRequested"))
        
        func availableCommandsrequested() {
            eventHandler.updateUI("Received command:\n[Available Commands]")
        }
        
        self.addCommandRecognizer(SAYSetSpeechRateCommandRecognizer(responseTarget: self, action: "setSpeechRateRequested"))
            
        func setSpeechRateRequested(command: SAYCommand) {
            print("recognized a set speech rate command")
        }
        
        //self.speakTextAnd(tutorialPrompt1, action: CurrentRequest.tutorialRequest1)
        
        tutorialRecognizer1 = SAYCustomCommandRecognizer(customType: "tutorialRecognizer1",  actionBlock: { command in

            self.speakTextAnd(self.tutorialPrompt2, action: CurrentRequest.tutorialRequest2)
        })
        var patterns = ["okay", "great", "good", "no", "nope", "naw", "not at all", "not really"]
        tutorialRecognizer1.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        
        
        self.addCommandRecognizer(SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlay"))
        
       
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
            case .tutorialRequest2: break
            case .tutorialRequest3: break
            case .tutorialRequest4: break
            case .tutorialRequest5: break
            case .tutorialRequest6: break
            default: break
            }
        }
    }
    
    let tutorialPrompt1 = "How do I Sound? Am I too loud?"
    let tutorialPrompt2 = "Hows this?"
    let tutorialPrompt3 = "Hows this?"
    let tutorialPrompt4 = "Hows this?"
    let tutorialPrompt5 = "Hows this?"
    let tutorialPrompt6 = "Hows this?"
    let tutorialPrompt7 = "Hows this?"
    
    func tutorialRequest1() {
        self.removeCommandRecognizer(tutorialRecognizer1)
        self.addCommandRecognizer(tutorialRecognizer1)
        let request = SAYVerbalCommandRequest(commandRegistry: self)
        SAYConversationManager.systemManager().presentVoiceRequest(request)
        
    }
    
    func speakTextAnd(text: String, action: CurrentRequest ) {
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: text), withCompletionBlock: {
            self.currentRequest = action
        })
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