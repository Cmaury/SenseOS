//
//  SAYNodDetector.swift
//  SenseOS
//
//  Created by Chris Maury on 2/5/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

public class SAYNodDetector {
    
    // class variables
    var windowSize: Int
    var pitchArray = [Float]()
    var rollArray = [Float]()
    var yawArray = [Float]()
    var ticks = 0
    
    // nod tracking variables
    var verticalSensitivityThreshold: Float = 0.45
    var horizontalSensitivityThreshold: Float = 1
    var boolTimeout = 10
    var nodTimeout = 10
    var disturbanceTimeout = 5
    var shakeThreshold = 35
    // up nod tracking
    var upNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
    // down nod tracking
    var downNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
    // right nod tracking
    var rightNodTracker = ["right": 0, "lastRight": 0, "left": 0, "lastLeft": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
    // left nod tracking
    var leftNodTracker = ["right": 0, "lastRight": 0, "left": 0, "lastLeft": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
    // shakes
    var lastVShake = 0
    var vShakeRecentlyEnded = false
    var lastHShake = 0
    var hShakeRecentlyEnded = false
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
        if(getPitchRate() >= verticalSensitivityThreshold){
            // check for new UP head movement FIRST
            upNodTracker["up"] = 1
            upNodTracker["lastUp"] = ticks
            upNodTracker["lastDisturbance"] = ticks
            upNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() <= -verticalSensitivityThreshold){
            upNodTracker["lastDisturbance"] = ticks
            upNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() <= -verticalSensitivityThreshold && upNodTracker["up"]! == 1){
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
            if(upNodTracker["disturbanceCount"] > shakeThreshold){
                vShakeRecentlyEnded = true
                lastVShake = ticks
            }
            upNodTracker["disturbanceCount"] = 0
        }
        
        // update downNodTracker
        if(getPitchRate() <= -verticalSensitivityThreshold){
            // check for new DOWN head movement FIRST
            downNodTracker["down"] = 1
            downNodTracker["lastDown"] = ticks
            downNodTracker["lastDisturbance"] = ticks
            downNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() >= verticalSensitivityThreshold){
            downNodTracker["lastDisturbance"] = ticks
            downNodTracker["disturbanceCount"]!++
        }
        if(getPitchRate() >= verticalSensitivityThreshold && downNodTracker["down"]! == 1){
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
            if(downNodTracker["disturbanceCount"] > shakeThreshold){
                vShakeRecentlyEnded = true
                lastVShake = ticks
            }
            downNodTracker["disturbanceCount"] = 0
        }
        
        // timeout for vertical shakes
        if((ticks-lastVShake) > boolTimeout){
            vShakeRecentlyEnded = false
        }
        
        // update rightNodTracker
        if(getYawRate() >= horizontalSensitivityThreshold){
            // check for new RIGHT head movement FIRST
            rightNodTracker["right"] = 1
            rightNodTracker["lastRight"] = ticks
            rightNodTracker["lastDisturbance"] = ticks
            rightNodTracker["disturbanceCount"]!++
        }
        if(getYawRate() <= -horizontalSensitivityThreshold){
            rightNodTracker["lastDisturbance"] = ticks
            rightNodTracker["disturbanceCount"]!++
        }
        if(getYawRate() <= -horizontalSensitivityThreshold && rightNodTracker["right"]! == 1){
            // check for new LEFT head movement SECOND
            rightNodTracker["left"] = 1
            rightNodTracker["lastLeft"] = ticks
            rightNodTracker["lastNod"] = ticks
        }
        if(rightNodTracker["right"]! == 1 && (ticks-rightNodTracker["lastRight"]! > boolTimeout)){
            // check for timeout of RIGHT head movement
            rightNodTracker["right"] = 0
        }
        if(rightNodTracker["left"]! == 1 && (ticks-rightNodTracker["lastLeft"]! > boolTimeout)){
            // check for timeout of LEFT head movement
            rightNodTracker["left"] = 0
        }
        if(ticks - rightNodTracker["lastDisturbance"]! > disturbanceTimeout * 4){
            if(rightNodTracker["disturbanceCount"] > shakeThreshold){
                hShakeRecentlyEnded = true
                lastHShake = ticks
            }
            rightNodTracker["disturbanceCount"] = 0
        }
        
        // update rightNodTracker
        if(getYawRate() <= -horizontalSensitivityThreshold){
            // check for new LEFT head movement FIRST
            leftNodTracker["left"] = 1
            leftNodTracker["lastLeft"] = ticks
            leftNodTracker["lastDisturbance"] = ticks
            leftNodTracker["disturbanceCount"]!++
        }
        if(getYawRate() >= horizontalSensitivityThreshold){
            leftNodTracker["lastDisturbance"] = ticks
            leftNodTracker["disturbanceCount"]!++
        }
        if(getYawRate() >= horizontalSensitivityThreshold && leftNodTracker["left"]! == 1){
            // check for new RIGHT head movement SECOND
            leftNodTracker["right"] = 1
            leftNodTracker["lastRight"] = ticks
            leftNodTracker["lastNod"] = ticks
        }
        if(leftNodTracker["right"]! == 1 && (ticks-leftNodTracker["lastRight"]! > boolTimeout)){
            // check for timeout of RIGHT head movement
            leftNodTracker["right"] = 0
        }
        if(leftNodTracker["left"]! == 1 && (ticks-leftNodTracker["lastLeft"]! > boolTimeout)){
            // check for timeout of LEFT head movement
            leftNodTracker["left"] = 0
        }
        if(ticks - leftNodTracker["lastDisturbance"]! > disturbanceTimeout * 4){
            // check for timeout on disturbanceCount
            if(leftNodTracker["disturbanceCount"] > shakeThreshold){
                hShakeRecentlyEnded = true
            }
            leftNodTracker["disturbanceCount"] = 0
        }
        
        // timeout for horizontal shakes
        if((ticks-lastHShake) > boolTimeout){
            hShakeRecentlyEnded = false
            lastHShake = ticks
        }
    }
    
    // check for nods
    
    public func isUpNod() -> Bool {
        if(ticks < 15){
            return false
        }
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
        if(ticks < 15){
            return false
        }
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
    
    public func isRightNod() -> Bool {
        if(ticks < 15){
            return false
        }
        if((ticks-rightNodTracker["lastNod"]!) < nodTimeout && (ticks-rightNodTracker["lastDisturbance"]!) > disturbanceTimeout &&
            rightNodTracker["disturbanceCount"]! < shakeThreshold){
                rightNodTracker["right"] = 0
                rightNodTracker["left"] = 0
                rightNodTracker["lastNod"] = 0
                rightNodTracker["lastDisturbance"] = 0
                return true
        } else {
            return false
        }
    }
    
    public func isLeftNod() -> Bool {
        if(ticks < 15){
            return false
        }
        if((ticks-leftNodTracker["lastNod"]!) < nodTimeout && (ticks-leftNodTracker["lastDisturbance"]!) > disturbanceTimeout &&
            leftNodTracker["disturbanceCount"]! < shakeThreshold){
                leftNodTracker["right"] = 0
                leftNodTracker["left"] = 0
                leftNodTracker["lastNod"] = 0
                leftNodTracker["lastDisturbance"] = 0
                return true
        } else {
            return false
        }
    }
    
    public func isShakeVertical() -> Bool {
        if(upNodTracker["disturbanceCount"]! > shakeThreshold || downNodTracker["disturbanceCount"]! > shakeThreshold){
            return true
        } else {
            return false
        }
    }
    
    public func isShakeHorizontal() -> Bool {
        if(rightNodTracker["disturbanceCount"]! > shakeThreshold || leftNodTracker["disturbanceCount"]! > shakeThreshold){
            return true
        } else {
            return false
        }
    }
    
    public func isVShakeRecentlyEnded() -> Bool {
        if(vShakeRecentlyEnded){
            vShakeRecentlyEnded = false
            return true
        } else {
            return false
        }
    }
    
    public func isHShakeRecentlyEnded() -> Bool {
        if(hShakeRecentlyEnded){
            hShakeRecentlyEnded = false
            return true
        } else {
            return false
        }
    }
    
    public func reset() {
        ticks = 0
        // up nod tracking
        upNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
        // down nod tracking
        downNodTracker = ["up": 0, "lastUp": 0, "down": 0, "lastDown": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
        // right nod tracking
        rightNodTracker = ["right": 0, "lastRight": 0, "left": 0, "lastLeft": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
        // left nod tracking
        leftNodTracker = ["right": 0, "lastRight": 0, "left": 0, "lastLeft": 0, "lastNod": 0, "disturbanceCount": 0, "lastDisturbance": 0]
        // shakes
        lastVShake = 0
        vShakeRecentlyEnded = false
        lastHShake = 0
        hShakeRecentlyEnded = false
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
        let diffThreshold: Float = 30
        var sumOfDiffs: Float = 0
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