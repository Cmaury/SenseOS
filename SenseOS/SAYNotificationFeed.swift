//
//  SAYNotificationFeed.swift
//  SenseOS
//
//  Created by Chris Maury on 2/7/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

protocol NotificationTopicEventHandler: class {
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


class SAYNotificationFeed: SAYConversationTopic {
    
    let eventHandler: NotificationTopicEventHandler
    init(eventHandler: NotificationTopicEventHandler) {
        self.eventHandler = eventHandler
        super.init()
        
       self.addCommandRecognizer(SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlay"))
        
        
        //reply Recognizer
        let replyRecognizer = SAYCustomCommandRecognizer(customType: "reply",  actionBlock: { command in
            print("heard reply command")
            eventHandler.handleReply()
        })
        var patterns = ["reply", "respond", "answer"]
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
    
    
    
    func speakText(text: [String]) {
        let sequence = SAYAudioEventSequence()
        for item in text {
            sequence.addEvent(SAYSpeechEvent(utteranceString: item))
            sequence.addEvent(SAYSilenceEvent(interval: 0.5))
        }
        self.postEvents(sequence)
    }
 
    func clearQueue() {
        speakText([""])
    }
}