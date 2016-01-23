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
    let recognitionThreshold = CGFloat(0.5)
    var isRecognizing = false
    
    var accelPoints = [SAY3DPoint]()
    var resampledPoints = [SAY3DPoint]()
    var templates = [String: SAY3DPoint]()
    
    init() {
        self.accelPoints = []
        self.resampledPoints = []
        self.templates = ["":SAY3DPointOrigin]
        self.accelPointCache = [SAY3DPointOrigin]
        
    }
    func testDistance() -> CGFloat {
        let delta = Distance(accelPointCache.last!, p2: accelPointCache[accelPointCache.count - 2])
        print("distance delta is \(delta)")
        return delta
    }
    
    func startRecognition() {
        if accelPointCache.count > 10 {
            let delta = Distance(accelPointCache.last!, p2: accelPointCache[accelPointCache.count - 2])
            print("distance delta is \(delta)")
            if delta > recognitionThreshold {
                isRecognizing = true
                print("started recognizing")
                addAccelData()
            }
            else {
                isRecognizing = false
                //findBestMatch()
                print("Stored \(accelPoints.count) data points")
                print("stopped recognizing")
                var string = "[ "
                for point in accelPoints {
                    string.appendContentsOf("[ \(point.x), \(point.y), \(point.z)], ")
                }
                string.appendContentsOf("], \n")
                print("read:\n \(string)")

            }
        }
    }
    
    func stopRecognition() {
        
    }
    
    func addAccelData() {
        let currentPoint = accelPointCache.last
        accelPoints.append((currentPoint!))
        print("wrote accel data point to array of accel data points")
    }
    
    func resetAccelData() {
        accelPoints = []
    }

    func findBestMatch() -> String {
        return findBestMatchCenter(SAY3DPoint(x: 0, y: 0, z:0), angle: 0, score: 0)
    }
    
    func findBestMatchCenter(outCenter: SAY3DPoint, angle: CGFloat, score: CGFloat) -> String {
        
        var i: Int
        let samplePoints = kSamplePoints
        var samples  = [SAY3DPoint]()
        let c = accelPoints.count
        
        for i = 0; i < min(samplePoints, c); i + 1 {
            let index = max(0, (c-1) * i / (samplePoints-1))
            samples[i] = accelPoints[index]        }
        
        var center: SAY3DPoint = Centroid(samples, samplePoints: samplePoints)
        
        Translate(&samples, samplePoints: samplePoints, center: center)
        
        //angle calculation goes here
        
        
        //scale gesture
        var lowerFrontLeft: SAY3DPoint = SAY3DPointOrigin
        var upperBackRight: SAY3DPoint = SAY3DPointOrigin
        
        for var i = 0; i < samplePoints; i++ {
            let pt: SAY3DPoint = samples[i]
            if (pt.x < lowerFrontLeft.x) { lowerFrontLeft.x = pt.x }
            if (pt.y < lowerFrontLeft.y) { lowerFrontLeft.y = pt.y }
            if (pt.z < lowerFrontLeft.z) { lowerFrontLeft.z = pt.z }
            if (pt.x > upperBackRight.x) { upperBackRight.x = pt.x }
            if (pt.y > upperBackRight.y) { upperBackRight.y = pt.y }
            if (pt.z > upperBackRight.z) { upperBackRight.z = pt.z }
        }
        
        let scale: CGFloat = 2 / max(upperBackRight.x - lowerFrontLeft.x, max(upperBackRight.y - lowerFrontLeft.y, upperBackRight.z - lowerFrontLeft.z))
        
        Scale(&samples, samplePoints: samplePoints, xscale: scale, yscale: scale, zscale: scale)
        
        center = Centroid(samples, samplePoints: samplePoints)
        
        Translate(&samples, samplePoints: samplePoints, center: center)
        
        var bestTemplateName = ""
        var best = CGFloat(99.999)
        for templateName in templates.keys {
            
            //get all sample points
            let templateIndex = templates.indexForKey(templateName)
            var templateSamples = [SAY3DPoint]()
            templateSamples.append(templates[templateIndex!].1)
            
            var template = [SAY3DPoint](count:samplePoints, repeatedValue: SAY3DPointOrigin)
            assert(samplePoints == templateSamples.count)
            
            for (index, templateSample) in templateSamples.enumerate() {
                template[index] = templateSample
            }
            
            let score = DistanceAtBestAngle(samples, samplePoints: samplePoints, template: template)
            print("[(templateName) match score is \(score)")
            
            if score < best {
                bestTemplateName = templateName
                best = score
            }
            
            print("Best match is \(bestTemplateName ) with score \(best)")
            
            //not sure if should be set here
            //var outscore = best
            
            self.resampledPoints = [SAY3DPoint]()
            
            for var i = 0; i < samplePoints; i++ {
                self.resampledPoints.append(samples[i])
            }
            
            //serialize the samples as JSON
//            var string = "\"template_name\": [ "
//            for sample in samples {
//                string.appendContentsOf("\(sample.x), \(sample.y), \(sample.z)], ")
//            }
//            string.appendContentsOf("], \n")
//            print("read:\n \(string)")
//            return bestTemplateName
        }
        resetAccelData()
        let returnString = bestTemplateName + " with score: \(best)"
        return returnString
    }
    
    func Centroid(samples: [SAY3DPoint], samplePoints: Int) -> SAY3DPoint{
        
        var center = SAY3DPointOrigin
        for var i = 0; i < samplePoints; i++ {
            let pt = samples[i]
            center.x = pt.x
            center.y = pt.y
            center.z = pt.z
        }
        center.x /= CGFloat(samplePoints)
        center.y /= CGFloat(samplePoints)
        center.z /= CGFloat(samplePoints)
        return center
    }
    
 
    func Translate(inout samples: [SAY3DPoint], samplePoints: Int, center: SAY3DPoint) {
        
        for var i = 0; i < samplePoints; i++ {
            
            let x = -center.x
            let y = -center.y
            let z = -center.z
            let pt = samples[i]
            samples[i] = SAY3DPoint(x: pt.x+x, y: pt.y+y, z: pt.z+z)
        }
    }
    
    func Scale(inout samples: [SAY3DPoint], samplePoints: Int, xscale: CGFloat, yscale: CGFloat, zscale: CGFloat) {
        
        
        let makeScale = CATransform3DMakeScale(xscale, yscale, zscale)
        
        for var i = 0; i < samplePoints; i++ {
            let pt0 = samples[i]
            let pt = CATransform3DScale(makeScale, pt0.x, pt0.y, pt0.z)
            samples[i].x = pt.m11
            samples[i].y = pt.m22
            samples[i].z = pt.m33
        }
    }
    
    func Distance(p1: SAY3DPoint, p2: SAY3DPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let dz = p2.z - p1.z
        
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    func PathDistance(p1: [SAY3DPoint], p2: [SAY3DPoint], count: Int) -> CGFloat {
        var d: CGFloat = 0.0
        for var i = 0; i < count; i++ {
            d = d + Distance(p1[i], p2: p2[i])
        }
        return d
    }
    
    func DistanceAtAngle(samples: [SAY3DPoint], samplePoints: Int, template: [SAY3DPoint], theta: CGFloat) -> CGFloat {
        
        var newPoints = [SAY3DPoint](count:128, repeatedValue: SAY3DPointOrigin)
        assert(samplePoints <= newPoints.count)
        //is this equivalent to memccpy(newPoints, samples,...)?
        newPoints.replaceRange(0...samples.count, with: samples)
        return PathDistance(newPoints, p2: samples, count: samplePoints)
    }
    
    func DistanceAtBestAngle(samples: [SAY3DPoint], samplePoints: Int, template: [SAY3DPoint]) -> CGFloat {
        
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
     return CGFloat(min(f1, f2))   
    }
    
}




