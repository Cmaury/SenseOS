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
    
    // nod tracking variables
    var sensitivityThreshold: Float = 1
    var boolTimeout = 10
    var nodTimeout = 10
    var disturbanceTimeout = 5
    var disturbanceCount = 0
    var shakeThreshold = 16
    // up nod tracking
    var upNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
    // down nod tracking
    var downNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
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
            upNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() <= -sensitivityThreshold) {
            upNodTracker["lastDisturbance"] = ticks
            upNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() <= -sensitivityThreshold && upNodTracker["up"]! == 1) {
            // check for new DOWN head movement SECOND
            upNodTracker["down"] = 1
            upNodTracker["lastDown"] = ticks
            upNodTracker["lastNod"] = ticks
        }
        if(upNodTracker["up"]! == 1 && (ticks-upNodTracker["lastUp"]! > boolTimeout)){
            // check for timeout of UP head movement
            upNodTracker["up"] = 0
        }
        if(upNodTracker["down"]! == 1 && (ticks-upNodTracker["lastDown"]! > boolTimeout)){
            // check for timeout of DOWN head movement
            upNodTracker["down"] = 0
        }
        if(ticks - upNodTracker["lastDisturbance"]! > disturbanceTimeout * 4){
            // check for timeout on disturbanceCount
            upNodTracker["disturbanceCount"] = 0
        }
        
        // update downNodTracker
        if(getPitchRate() <= -sensitivityThreshold) {
            // check for new DOWN head movement FIRST
            downNodTracker["down"] = 1
            downNodTracker["lastDown"] = ticks
            downNodTracker["lastDisturbance"] = ticks
            downNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() >= sensitivityThreshold) {
            downNodTracker["lastDisturbance"] = ticks
            downNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() >= sensitivityThreshold && downNodTracker["down"]! == 1){
            // check for new UP head movement SECOND
            downNodTracker["up"] = 1
            downNodTracker["lastUp"] = ticks
            downNodTracker["lastNod"] = ticks
        }
        if(downNodTracker["up"]! == 1 && (ticks-downNodTracker["lastUp"]! > boolTimeout)){
            // check for timeout of UP head movement
            downNodTracker["up"] = 0
        }
        if(downNodTracker["down"]! == 1 && (ticks-downNodTracker["lastDown"]! > boolTimeout)){
            // check for timeout of DOWN head movement
            downNodTracker["down"] = 0
        }
        if(ticks - downNodTracker["lastDisturbance"]! > disturbanceTimeout * 4){
            // check for timeout on disturbanceCount
            downNodTracker["disturbanceCount"] = 0
        }
        
    }
    
    // check for nods
    
    public func isUpNod() -> Bool {
        if((ticks-upNodTracker["lastNod"]!) < nodTimeout && (ticks-upNodTracker["lastDisturbance"]!) > disturbanceTimeout &&
            upNodTracker["disturbanceCount"] < shakeThreshold){
            upNodTracker["up"] = 0
            upNodTracker["down"] = 0
            upNodTracker["lastNod"] = 0
            upNodTracker["lastDisturbance"] = 0
            return true
        } else {
            return false
        }
    }
    
    public func isDownNod() -> Bool {
        if((ticks-downNodTracker["lastNod"]!) < nodTimeout && (ticks-downNodTracker["lastDisturbance"]!) > disturbanceTimeout &&
            downNodTracker["disturbanceCount"] < shakeThreshold){
                downNodTracker["up"] = 0
                downNodTracker["down"] = 0
                downNodTracker["lastNod"] = 0
                downNodTracker["lastDisturbance"] = 0
                return true
        } else {
            return false
        }
    }
    
    // note: disturbance count resets after some timeout
    public func getUpNodDisturbanceCount() -> Int {
        return upNodTracker["disturbanceCount"]!
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
    
    // has to take care of 360 -> 0 and 0 -> 360
    public func getYawRate() -> Float {
        let diffThreshold: Float = 10
        var sumOfDiffs: Float = 0.0
        for (var i = 1; i < yawArray.count; i++){
            var diff = yawArray[i] - yawArray[i-1]
            if(diff > diffThreshold){
                diff = 360 - diff + 1
            } else if(diff < -diffThreshold){
                diff = 360 + diff + 1
            }
            sumOfDiffs += diff
        }
        return (sumOfDiffs / Float(yawArray.count-1))
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