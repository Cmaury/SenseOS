//
//  SayOpenMicTopic.swift
//  SenseOS
//
//  Created by Chris Maury on 2/8/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation


protocol OpenMicTopicEventHandler: class {
    func handlePlay()
    func handlePrevious()
    func handleNext()
    func handleSelect()
    func handleStop()
    func handleRead()
    func handleShare()
    func handleReply()
    func handleDelete()
    func handleComments()
    func handleUber()
    func handleYelp()
}


class SAYOpenMicTopic: SAYConversationTopic {
    
    let eventHandler: OpenMicTopicEventHandler
    init(eventHandler: OpenMicTopicEventHandler) {
        self.eventHandler = eventHandler
        super.init()
        
        self.addCommandRecognizer(SAYPlayCommandRecognizer(responseTarget: eventHandler, action: "handlePlay"))
        
        //uber recognizer
        let uberRecognizer = SAYCustomCommandRecognizer(customType: "uber",  actionBlock: { command in
            print("heard uber command")
            eventHandler.handleUber()
        })
        var patterns = ["uber", "ride", "uber X", "lift", "lyft", "pick me up"]
        uberRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        self.addCommandRecognizer(uberRecognizer)
        
        //yelp recognizer
        let yelpRecognizer = SAYCustomCommandRecognizer(customType: "yelp",  actionBlock: { command in
            print("heard yelp command")
            eventHandler.handleYelp()
        })
        patterns = ["yelp", "looking for", "want", "nearby"]
        yelpRecognizer.addTextMatcher(SAYPatternCommandMatcher(forPatterns: patterns))
        self.addCommandRecognizer(yelpRecognizer)


        
    }
    func speakText(text: [String]) {
        let sequence = SAYAudioEventSequence()
        for item in text {
            sequence.addEvent(SAYSpeechEvent(utteranceString: item), withCompletionBlock: {
                print(item)
                    })
            sequence.addEvent(SAYSilenceEvent(interval: 0.5))
        }
        self.postEvents(sequence)
    }
    
    func clearQueue() {
        speakText([""])
    }
}