//
//  ViewController.swift
//  SenseOS
//
//  Created by Chris Maury on 1/15/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSButtonDelegate {
    
    // UI
    @IBOutlet weak var accelX: UILabel!
    @IBOutlet weak var accelY: UILabel!
    @IBOutlet weak var accelZ: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var originDistance: UILabel!
    @IBOutlet weak var ConnectionState: UILabel!
    @IBOutlet weak var pitchRateLabel: UILabel!
    // Sound
    var dingSound: AVAudioPlayer?
    
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
        var fileText = ""
        var fileIndex = ""
        if sender.title == "Accel" {
            fileIndex = "accel_Data"
        }
        else { fileIndex = "raw_Accel_Data" }
        print("file name " + fileIndex)
        //get file to share from button
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileIndex);
            
            //get file text
                do {
                    print("getting contents of file \(path)")
                fileText = try String(contentsOfFile: path)
                }
                catch {
                    fileText = "there was an error pulling file data"
                    print(error)
            }
            let myWebsite = NSURL(string: "http://conversantlabs.com")
            let activityViewController = UIActivityViewController(activityItems: [fileText, myWebsite!], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    let headset = IHSDevice(deviceDelegate: ViewController.self as! IHSDeviceDelegate)
    let gestureRecognizer = SAYGestureRecognizer()
    let nodDetector = NodDetector(windowSize: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup osund
        dingSound = AVAudioPlayer()
        let url:NSURL = NSBundle.mainBundle().URLForResource("chime_bell_ding", withExtension: "wav")!
        do { dingSound = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        // other
        if headset.connectionState != IHSDeviceConnectionState.Connected {
            ConnectionState.text = "not connected"
            print("trying to connect")
            headset.deviceDelegate = self
            headset.sensorsDelegate = self
            headset.audioDelegate = self
            headset.buttonDelegate = self
            headset.connect()
            print("\(headset.connectionState.rawValue)")
        }
        print("connection state is \(headset.connectionState.rawValue)")
    }
    
    func playDing() {
        dingSound?.numberOfLoops = 0
        dingSound?.volume = 15.0
        dingSound?.prepareToPlay()
        dingSound?.play()
    }
    
    func updateLog(text:String, file: String) {
        let text = text + ", " + NSDate().description + "\n"
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                if let fileHandle = NSFileHandle(forWritingAtPath: path) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.writeData(data)
                    fileHandle.closeFile()
                    //print("wrote to file \(file)")
                }
                else {
                    print("can't open file because reasons")
                }
                
            }
            else {
                let pathURL = NSURL(string: path)!
                data.writeToURL(pathURL, atomically: true)
//                print("created file: \(file)")
            }
            
        }
    }
    
    
    // Device Delegate Methods
    
    @objc func ihsDevice(ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
        
        switch connectionState {
        case IHSDeviceConnectionState.Connected:
            ConnectionState.text = "Connected"
            
        case IHSDeviceConnectionState.None: ConnectionState.text = "None"
        case IHSDeviceConnectionState.Disconnected: ConnectionState.text = "Disconnected"
            gestureRecognizer.stopRecognition()
        case IHSDeviceConnectionState.Discovering: ConnectionState.text = "Discovering"
        case IHSDeviceConnectionState.Connecting: ConnectionState.text = "Connecting..."
        case IHSDeviceConnectionState.ConnectionFailed:
            ConnectionState.text = "Connection Failed"
        case IHSDeviceConnectionState.BluetoothOff: ConnectionState.text = "Bluetooth is off"
        default: break
        }
        print("device state changed to " + ConnectionState.text!)
        
    }
    
    func ihsDeviceFoundAmbiguousDevices(ihs: IHSDevice!) {
        print("found ambiguous device")
    }
    
    
    //Sensor Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, accelerometer3AxisDataChanged data: IHSAHRS3AxisStruct) {
        
        if gestureRecognizer.origin.x == SAY3DPointOrigin.x {
            gestureRecognizer.origin = SAY3DPoint(x: CGFloat(headset.pitch), y: CGFloat(headset.roll), z: CGFloat(headset.yaw))
        }
        
        gestureRecognizer.accelPointCache.append(SAY3DPoint(x:CGFloat(headset.roll), y: CGFloat(headset.pitch), z: CGFloat(headset.yaw)))
        gestureRecognizer.startRecognition()
        distanceLabel.text = "\(gestureRecognizer.testDistance().0)"
        originDistance.text = "\(gestureRecognizer.testDistance().1)"
        if !gestureRecognizer.isRecognizing {
            gestureRecognizer.findBestMatch()
        }
        
        accelX.text = " \(headset.pitch)"
        accelY.text = "\(headset.roll)"
        accelZ.text =  "\(headset.yaw)"
        
        // add data to NodDetector
        nodDetector.addPitchAngle(headset.pitch)
        nodDetector.tick()
        // update UI
        pitchRateLabel.text = String(nodDetector.getPitchRate())
        // check for head nod
        if(nodDetector.isUpNod()){
            playDing()
        }
        
        
        if ihs.gyroCalibrated {
            let file = "accel_Data"
            let text = "\(ihs.accelerometerData.x), \(ihs.accelerometerData.y), \(ihs.accelerometerData.z)"
            updateLog(text, file: file)
            //print(text)
            
        }
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, didChangeYaw yaw: Float, pitch: Float, andRoll roll: Float) {
        let file = "raw_Accel_Data"
        let text = "\(ihs.yaw), \(ihs.pitch), \(ihs.roll)"
        updateLog(text, file: file)
        //print(text)
        
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, fusedHeadingChanged heading: Float) {
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, compassHeadingChanged heading: Float) {
        
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, horizontalAccuracyChanged horizontalAccuracy: Double) {
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, locationChangedToLatitude latitude: Double, andLogitude longitude: Double) {
        
    }
    
    
    @objc func ihsDevice(ihs: IHSDevice!, magneticDisturbanceChanged magneticDisturbance: Bool) {
        
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, magneticFieldStrengthChanged magneticFieldStrength: Int) {
        
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, gyroCalibrated: Bool) {
        
    }
    
    
    //Button Delegate methods

    @objc func ihsDevice(ihs: IHSDevice!, didPressIHSButton button: IHSButton, withEvent event: IHSButtonEvent, fromSource source: IHSButtonSource) {
        
    }
    

    
    //Audio Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, playerDidStartSuccessfully success: Bool) {
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, playerDidPauseSuccessfully success: Bool) {
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, playerDidStopSuccessfully success: Bool) {
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, playerCurrentTime currentTime: NSTimeInterval, duration: NSTimeInterval) {
        
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, playerRenderError status: OSStatus) {
    }

}

