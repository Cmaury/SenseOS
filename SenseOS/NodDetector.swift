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
    
    // constructor
    init(windowSize: Int) {
        self.windowSize = windowSize
    }
    
    //================//
    // public methods //
    //================//
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
    
    public func getPitchRate() -> Float {
        return getGradient(pitchArray)
    }
    
    public func getRollRate() -> Float {
        return getGradient(rollArray)
    }
    
    public func getYawRate() -> Float {
        return getGradient(yawArray)
    }
    
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