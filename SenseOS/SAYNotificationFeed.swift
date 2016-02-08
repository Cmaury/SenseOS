//
//  SAYNotificationFeed.swift
//  SenseOS
//
//  Created by Chris Maury on 2/7/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation




class SAYNotificationFeed: NSObject, SAYAudioEventSource {
    
    func lastPostedEvents() -> SAYAudioEventSequence? {
        
        let notificationSequence = SAYAudioEventSequence()
        
        
        return notificationSequence
    }
    
    func addListener(listener: SAYAudioEventListener) {
        <#code#>
    }
    
    func removeListener(listener: SAYAudioEventListener) {
        <#code#>
    }
    
    
}


class SAYNotificationEvent: NSObject, SAYAudioEvent {
    

    func operations() -> [SAYOperation] {
        
        
    }
}

class speakText: SAYOperation {
    
    override func execute() {
        <#code#>
    }
}




//class notificationListener: NSObject, SAYAudioEventListener {
//    
//    var notificationFeed = SAYNotificationFeed()
//    
//    func eventSource(source: notificationFeed, didPostEventSequence sequence: SAYAudioEventSequence) {
//        <#code#>
//    }
//}