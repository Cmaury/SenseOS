//
//  SAYGestureRecognizer.swift
//  SenseOS
//
//  Created by Chris Maury on 1/21/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

struct SAY3DPoint {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
}

let SAY3DPointOrigin = SAY3DPoint(x: 0, y: 0, z: 0)

class SAYGestureRecognizer {
    
    var accelPointCache: [SAY3DPoint]
    
    let kSamplePoints = 16
    let pointThreshold = CGFloat(0.5)
    let originThreshold = CGFloat(10)
    var origin: SAY3DPoint
    var isRecognizing = false
    
    
    var accelPoints: [SAY3DPoint]
    var resampledPoints: [SAY3DPoint]
    var templates: [String: [SAY3DPoint]]
    let gestureTemplates = SAYGestureTemplateCGFloat()

    init() {
        self.origin = SAY3DPointOrigin
        self.accelPoints = []
        self.resampledPoints = []
        self.templates =  ["Nod Up": gestureTemplates.shortNodUpandBack,
            //"LongNodStartUp": gestureTemplates.LongNodStartUp,
            //"longNodStartDown": gestureTemplates.longNodStartDown,
            "shortNodDownandBack": gestureTemplates.shortNodDownandBack,
            "lookLeftandBack": gestureTemplates.lookLeftandBack,
            "lookRightandBack": gestureTemplates.lookRightandBack
            //"shakeHeadStartLeft": gestureTemplates.shakeHeadStartLeft,
            //"shakeHeadStartRight": gestureTemplates.shakeHeadStartRight,
            //"iltLeftandBack": gestureTemplates.tiltLeftandBack,
            //"tiltRightandBack": gestureTemplates.tiltRightandBack,
            //"twistLeftandBack": gestureTemplates.twistLeftandBack,
            //"twistRightandBack": gestureTemplates.twistRightandBack
            //"jerkBack": gestureTemplates.jerkBack
        ]
        self.accelPointCache = [SAY3DPointOrigin]
        
    }
    
    func testDistance() -> (CGFloat, CGFloat) {
        let delta = Distance(accelPointCache.last!, p2: accelPointCache[accelPointCache.count - 2])
        let originDelta = Distance(accelPointCache.last!, p2: origin)
        //print("distance delta is \(delta)")
        return (delta, originDelta)
    }
    
    func startRecognition() {

        if accelPointCache.count > 10 {
            let originDelta = Distance(accelPointCache.last!, p2: origin)
            let pointDelta = Distance(accelPointCache.last!, p2: accelPointCache[accelPointCache.count - 2])
            //print("distance delta is \(delta)")
            if originDelta > originThreshold || (originDelta < originThreshold && pointDelta > pointThreshold) {
                isRecognizing = true
                addAccelData()
            }
            else {
                isRecognizing = false
                findBestMatch()
                resetAccelData()
                
//                if accelPoints.count > 0 {
//                    print("started recognizing")
//                    findBestMatch()
//                }
                //print("Stored \(accelPoints.count) data points")
                //print("stopped recognizing")
                

            }
        }
    }
    
    func stopRecognition() {
        
    }
    
    func addAccelData() {
        let currentPoint = accelPointCache.last
        accelPoints.append((currentPoint!))
        //print("wrote accel data point to array of accel data points")
    }
    
    func resetAccelData() {
        accelPoints = []
    }

    func findBestMatch() -> String {
        return findBestMatchCenter(SAY3DPoint(x: 0, y: 0, z:0), angle: 0, score: 0)
    }
    
    func findBestMatchCenter(outCenter: SAY3DPoint, angle: CGFloat, score: CGFloat) -> String {
        

        var samplePoints = kSamplePoints
        var samples: [SAY3DPoint]?
        //let c = accelPoints.count
        
//        for var i = 0; i < min(samplePoints, c); i + 1 {
//            let index = max(0, (c-1) * i / (samplePoints-1))
//            print("samplePoints index = \(index) and count of accelpoints = \(c) and i = \(i)")
//            samples.append(accelPoints[index])
//            
//        }
        
        if accelPoints.count > 1 {
            samples = accelPoints
        }

        if accelPoints.count > samplePoints {
            if samples != nil {
                for var i = 0; i < (accelPoints.count - samplePoints); i++ {
                    samples!.popLast()
                }
                samplePoints = samples!.count
            }
        }
        //print(" accel point are \(samples)")
        
        var center: SAY3DPoint = Centroid(samples, samplePoints: samplePoints)
        //print("\(center)")
        
        Translate(&samples, samplePoints: samplePoints, center: center)
        
        //angle calculation goes here
        CGPoint firstPoint = samples[0];
        float firstPointAngle = atan2(firstPoint.y, firstPoint.x);
        NSLog(@"firstPointAngle=%0.2f", firstPointAngle*360.0f/(2.0f*M_PI));
        if (outRadians)
        *outRadians = firstPointAngle;       
        
        Rotate(&samples, samplePoints: samplePoints, angle: -firstPointAngle)
        
        
        //scale gesture
        var lowerFrontLeft: SAY3DPoint = SAY3DPointOrigin
        var upperBackRight: SAY3DPoint = SAY3DPointOrigin
        if samples != nil {
            for var i = 0; i < samples!.count; i++ {
                let pt = samples![i]
                if (pt.x < lowerFrontLeft.x) { lowerFrontLeft.x = pt.x }
                if (pt.y < lowerFrontLeft.y) { lowerFrontLeft.y = pt.y }
                if (pt.z < lowerFrontLeft.z) { lowerFrontLeft.z = pt.z }
                if (pt.x > upperBackRight.x) { upperBackRight.x = pt.x }
                if (pt.y > upperBackRight.y) { upperBackRight.y = pt.y }
                if (pt.z > upperBackRight.z) { upperBackRight.z = pt.z }
            }
        }
        
        
        let scale: CGFloat = 2 / max(upperBackRight.x - lowerFrontLeft.x, max(upperBackRight.y - lowerFrontLeft.y, upperBackRight.z - lowerFrontLeft.z))
        

        Scale(&samples, samplePoints: samplePoints, xscale: scale, yscale: scale, zscale: scale)

        
        center = Centroid(samples, samplePoints: samplePoints)
        

        Translate(&samples, samplePoints: samplePoints, center: center)

        //code for recording templates
//
//            if samples != nil {
//            var string = "[ "
//            for point in samples! {
//                string.appendContentsOf("[ \(point.x), \(point.y), \(point.z)], ")
//            }
//            string.appendContentsOf("], \n")
//            print("read:\n \(string)")
//        }
//    
        
        var bestTemplateName = ""
        var best = CGFloat(99999.999)
        for templateName in templates.keys {
            
            //get all sample points
            let templateIndex = templates.indexForKey(templateName)
            var templateSamples = [SAY3DPoint]()
            for item in templates[templateIndex!].1 {
                templateSamples.append(item)
            }

            
            var template = [SAY3DPoint](count: templateSamples.count, repeatedValue: SAY3DPointOrigin)
            //print("sample Points are \(samplePoints) and temaplte points are \(templateSamples.count)")
            //assert(samplePoints == templateSamples.count)
            
            for (index, templateSample) in templateSamples.enumerate() {
                template[index] = templateSample
            }
            
            let score = DistanceAtBestAngle(samples, samplePoints: samplePoints, template: template)
            
            if score > 0.0 {
                //print("\(templateName) match score is \(score)")
            }
            
            
            if score < best {
                bestTemplateName = templateName
                best = score
            }
            
            
           
            
            //not sure if should be set here
            //var outscore = best
            
            self.resampledPoints = [SAY3DPoint]()
            
            if samples != nil {
                for var i = 0; i < samples!.count; i++ {
                    self.resampledPoints.append(samples![i])
                }
            }
            
        }
        if best > 0.0 {
            print("Best match is \(bestTemplateName ) with score \(best)")
        }
    
        resetAccelData()
        let returnString = bestTemplateName + " with score: \(best)"
        return returnString
    }
    
    func Centroid(samples: [SAY3DPoint]?, samplePoints: Int) -> SAY3DPoint{
        var center = SAY3DPointOrigin
        if samples != nil {
            
            for var i = 0; i < samples!.count; i++ {
                let pt = samples![i]
                center.x = pt.x
                center.y = pt.y
                center.z = pt.z
            }
            center.x /= CGFloat(samplePoints)
            center.y /= CGFloat(samplePoints)
            center.z /= CGFloat(samplePoints)
            
        }
        return center
    }
    
 
    func Translate(inout samples: [SAY3DPoint]?, samplePoints: Int, center: SAY3DPoint) {
        if samples != nil {
            for var i = 0; i < samples!.count; i++ {
                
                let x = -center.x
                let y = -center.y
                let z = -center.z
                let pt = samples![i]
                samples![i] = SAY3DPoint(x: pt.x+x, y: pt.y+y, z: pt.z+z)
            }
        }
        
    }
    
    func Scale(inout samples: [SAY3DPoint]?, samplePoints: Int, xscale: CGFloat, yscale: CGFloat, zscale: CGFloat) {
        if samples != nil {
            let makeScale = CATransform3DMakeScale(xscale, yscale, zscale)
            
            for var i = 0; i < samples!.count; i++ {
                let pt0 = samples![i]
                let pt = CATransform3DScale(makeScale, pt0.x, pt0.y, pt0.z)
                samples![i].x = pt.m11
                samples![i].y = pt.m22
                samples![i].z = pt.m33
            }
        }
    }
    
    func Rotate(inout samples: [SAY3DPoint]?, samplePoints: Int, angle: CGFloat) {
        if samples != nil {
            for  (i, sample) in samples!.enumerate() {
                let pt = CATransform3DMakeRotation(angle, sample.x, sample.y,  sample.z)
                samples![i].x = pt.m11
                samples![i].y = pt.m22
                samples![i].z = pt.m33
            }
        }
    }
    
    func Distance(p1: SAY3DPoint, p2: SAY3DPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let dz = p2.z - p1.z
        
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    func PathDistance(p1: [SAY3DPoint]?, p2: [SAY3DPoint]?, count: Int) -> CGFloat {
        
        var d: CGFloat = 0.0
        
        
        if p1 != nil && p2 != nil {
            for var i = 0; i < count; i++ {
                d = d + Distance(p1![i], p2: p2![i])
            }
            
        }
        return d
    }
    
    func DistanceAtAngle(samples: [SAY3DPoint]?, samplePoints: Int, template: [SAY3DPoint], theta: CGFloat) -> CGFloat {
        
        var newPoints: [SAY3DPoint]?
        newPoints = [SAY3DPoint](count:128, repeatedValue: SAY3DPointOrigin)
            
        if samples != nil {

            assert(samplePoints <= newPoints!.count)
            //is this equivalent to memccpy(newPoints, samples,...)?
            newPoints!.replaceRange(0...samples!.count, with: samples!)
            //print("path distance is \(newPoints))")
            let count = min(samples!.count, template.count)
            Rotate(&newPoints, samplePoints: samplePoints, angle: -theta)
            return PathDistance(newPoints, p2: template, count: count)
        }
        else {
        return PathDistance(newPoints, p2: template, count: 0)
        }
    }
    
    func DistanceAtBestAngle(samples: [SAY3DPoint]?, samplePoints: Int, template: [SAY3DPoint]) -> CGFloat {
        
        var a = CGFloat(-0.25 * M_PI)
        var b = -a
        let threshold = CGFloat(0.1)
        let Phi = CGFloat(0.5 * (-1.0 + sqrtf(5.0)))
        
        var x1 = Phi * a + (1.0 - Phi) * b
        var f1: CGFloat = DistanceAtAngle(samples, samplePoints: samplePoints, template: template, theta: x1)
        
        var x2 = (1.0 - Phi) * a + Phi * b
        var f2:CGFloat = DistanceAtAngle(samples, samplePoints: samplePoints, template: template, theta: x2)
        
        while (fabs(b-a) > threshold) {
            if (f1 < f2) {
                b = x2
                x2 = x1
                f2 = f1
                x1 = Phi * a + (1.0 - Phi) * b
                f1 = DistanceAtAngle(samples, samplePoints: samplePoints, template: template, theta: x1)
            }
            else  {
                a = x1
                x1 = x2
                f1 = f2
                x2 = (1.0 - Phi) * a + Phi * b
                f2 = DistanceAtAngle(samples, samplePoints: samplePoints, template: template, theta: x2)
            }
            
        }
        //print("\(f1), \(f2)")
     return CGFloat(min(f1, f2))   
    }
    
}




