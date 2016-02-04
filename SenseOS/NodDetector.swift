//
//  NodDetector.swift
//  SenseOS
//
//  Created by Tomer Borenstein on 2/2/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

public class NodDetector {
    
    // class variables
    var windowSize: Int
    var pitchArray = [Float]()
    var rollArray = [Float]()
    var yawArray = [Float]()
    var ticks = 0
    // up nod tracking
    var upNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "lastDisturbance": 0]
    var sensitivityThreshold: Float = 0.8
    var boolTimeout = 10
    var nodTimeout = 10
    var disturbanceTimeout = 5
    var upNodCount = 0
    // constructor
    init(windowSize: Int) {
        self.windowSize = windowSize
    }
    
    //================//
    // public methods //
    //================//
    
    // tick
    
    public func tick(){
        ticks++
        // update upNodTracker
        if(getPitchRate() >= sensitivityThreshold) {
            // check for new UP head movement FIRST
            upNodTracker["up"] = 1
            upNodTracker["lastUp"] = ticks
            upNodTracker["lastDisturbance"] = ticks
        }
        if(getPitchRate() <= -sensitivityThreshold) {
            upNodTracker["lastDisturbance"] = ticks
        }
        if(getPitchRate() <= -sensitivityThreshold && upNodTracker["up"]! == 1) {
            // check for new DOWN head movement SECOND
            upNodTracker["down"] = 1
            upNodTracker["lastDown"] = ticks
            upNodTracker["lastNod"] = ticks
            upNodTracker["lastDisturbance"] = ticks
        }
        if(upNodTracker["up"]! == 1 && (ticks-upNodTracker["lastUp"]! > boolTimeout)){
            // check for timeout of UP head movement
            upNodTracker["up"] = 0
        }
        if(upNodTracker["down"]! == 1 && (ticks-upNodTracker["lastDown"]! > boolTimeout)){
            // check for timeout of DOWN head movement
            upNodTracker["down"] = 0
        }
    }
    
    // check for nods
    
    public func isUpNod() -> Bool {
        if((ticks-upNodTracker["lastNod"]!) < nodTimeout && (ticks-upNodTracker["lastDisturbance"]!) > disturbanceTimeout){
            upNodTracker["up"] = 0
            upNodTracker["down"] = 0
            upNodTracker["lastNod"] = 0
            upNodTracker["lastDisturbance"] = 0
            upNodCount++
            return true
        } else {
            return false
        }
    }
    
    public func getUpNodCount() -> Int {
        return upNodCount
    }
    
    // add angles
    
    public func addPitchAngle(angle: Float) {
        pitchArray.append(angle)
        if(pitchArray.count > windowSize) {
            pitchArray.removeFirst()
        }
    }
    
    public func addRollAngle(angle: Float) {
        rollArray.append(angle)
        if(rollArray.count > windowSize){
            rollArray.removeFirst()
        }
    }
    
    public func addYawAngle(angle: Float) {
        yawArray.append(angle)
        if(yawArray.count > windowSize){
            yawArray.removeFirst()
        }
    }
    
    // get angle change rates
    
    public func getPitchRate() -> Float {
        return getGradient(pitchArray)
    }
    
    public func getRollRate() -> Float {
        return getGradient(rollArray)
    }
    
    public func getYawRate() -> Float {
        return getGradient(yawArray)
    }
    
    // tick (must be called once every sample)
    
    //================//
    // private methods //
    //================//
    // currently simply takes average of differences, a better method could
    // be to fit a line through the points and take its slope
    private func getGradient(points: [Float]) -> Float {
        var sumOfDiffs: Float = 0.0
        for (var i = 1; i < points.count; i++){
            let diff = points[i] - points[i-1]
            sumOfDiffs += diff
        }
        return (sumOfDiffs / Float(points.count-1))
    }
}