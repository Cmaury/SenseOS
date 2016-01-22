//
//  ViewController.swift
//  SenseOS
//
//  Created by Chris Maury on 1/15/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSButtonDelegate {
        
    
    @IBOutlet weak var accelX: UILabel!
    @IBOutlet weak var accelY: UILabel!
    @IBOutlet weak var accelZ: UILabel!

    @IBOutlet weak var ConnectionState: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                    print("wrote to file \(file)")
                }
                else {
                    print("can't open file because reasons")
                }
                
            }
            else {
                let pathURL = NSURL(string: path)!
                data.writeToURL(pathURL, atomically: true)
                print("created file: \(file)")
            }
            
        }
    }
    
    
    // Device Delegate Methods
    
    @objc func ihsDevice(ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
        
        switch connectionState {
        case IHSDeviceConnectionState.None:
            
            ConnectionState.text = "None"
        case IHSDeviceConnectionState.Disconnected: ConnectionState.text = "Disconnected"
        case IHSDeviceConnectionState.Discovering: ConnectionState.text = "Discovering"
        case IHSDeviceConnectionState.Connecting: ConnectionState.text = "Connecting..."
        case IHSDeviceConnectionState.Connected: ConnectionState.text = "Connected"
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
        
        gestureRecognizer.accelPointCache = SAY3DPoint(x:headset.roll, y: headset.pitch, z: headset.yaw)
        
        accelX.text = " \(headset.pitch)"
        accelY.text = "\(headset.roll)"
        accelZ.text =  "\(headset.yaw)"
        
        if ihs.gyroCalibrated {
            let file = "accel_Data"
            let text = "\(ihs.accelerometerData.x), \(ihs.accelerometerData.y), \(ihs.accelerometerData.z)"
            updateLog(text, file: file)
            print(text)
            
        }
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, didChangeYaw yaw: Float, pitch: Float, andRoll roll: Float) {
        let file = "raw_Accel_Data"
        let text = "\(ihs.yaw), \(ihs.pitch), \(ihs.roll)"
        updateLog(text, file: file)
        print(text)
        
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

