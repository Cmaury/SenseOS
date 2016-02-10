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
    @IBOutlet weak var ConnectionState: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    // headset
    let headset = IHSDevice(deviceDelegate: ViewController.self as! IHSDeviceDelegate)
    // data collection
    let dataFileName = "data.csv"
    var gestureUID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if headset.connectionState != IHSDeviceConnectionState.Connected {
            ConnectionState.text = "Not connected"
            print("Trying to connect...")
            headset.deviceDelegate = self
            headset.sensorsDelegate = self
            headset.audioDelegate = self
            headset.buttonDelegate = self
            headset.connect()
            print(String(headset.connectionState.rawValue))
        }
        print("Connection state is " + String(headset.connectionState.rawValue))
        clearFile(dataFileName) // start new data file each time you open the app
    }
    
    // export data (share)
    @IBAction func shareButton(sender: UIBarButtonItem) {
        var fileText = ""
        let fileIndex = dataFileName
        //get file to share from button
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileIndex);
            //get file text
            do {
                print("Getting contents of file " + String(path))
                fileText = try String(contentsOfFile: path)
            } catch {
                fileText = "There was an error pulling file data"
                print(error)
            }
            let activityViewController = UIActivityViewController(activityItems: [fileText], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // write to the end of a file
    // file is created if it does not exist
    func writeToFile(text:String, file:String){
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = paths.stringByAppendingPathComponent(file)
        if let fileHandle = NSFileHandle(forWritingAtPath: filePath) {
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(data)
            fileHandle.closeFile()
            print("Wrote to file " + String(file))
        } else {
            print("Can't open file " + String(file) + "...")
            do {
                try text.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                print("Can't write to file " + String(file) + "...")
            }
            print("Created and wrote new file: " + String(file))
        }
    }
    
    // clears file by writing nothing to it
    func clearFile(file:String){
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let filePath = paths.stringByAppendingPathComponent(file)
        do {
            try "".writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            print("Cleared file " + String(file))
        } catch {
            
        }
    }
    
    // log headset data
    // TODO: not complete, just test
    func logData(pitch: Float, roll: Float, yaw: Float, label: Int){
        let str = String(pitch) + "," + String(roll) + "," + String(yaw) + "," + String(label) + "\n"
        writeToFile(str, file: dataFileName);
    }
    
    // Device Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
        switch connectionState {
            case IHSDeviceConnectionState.Connected: ConnectionState.text = "Connected"
            case IHSDeviceConnectionState.None: ConnectionState.text = "None"
            case IHSDeviceConnectionState.Disconnected: ConnectionState.text = "Disconnected"
            case IHSDeviceConnectionState.Discovering: ConnectionState.text = "Discovering"
            case IHSDeviceConnectionState.Connecting: ConnectionState.text = "Connecting..."
            case IHSDeviceConnectionState.ConnectionFailed: ConnectionState.text = "Connection Failed"
            case IHSDeviceConnectionState.BluetoothOff: ConnectionState.text = "Bluetooth is off"
            default: break
        }
        print("Device state changed to " + ConnectionState.text!)
        
    }
    
    func ihsDeviceFoundAmbiguousDevices(ihs: IHSDevice!) {
        print("Found ambiguous device")
    }
    
    //Sensor Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, accelerometer3AxisDataChanged data: IHSAHRS3AxisStruct) {
        pitchLabel.text = String(headset.pitch)
        rollLabel.text = String(headset.roll)
        yawLabel.text = String(headset.yaw)
        xLabel.text = String(headset.accelerometerData.x)
        yLabel.text = String(headset.accelerometerData.y)
        zLabel.text = String(headset.accelerometerData.z)
        timeLabel.text = "\(NSDate().timeIntervalSince1970 * 1000)"
        logData(headset.pitch, roll: headset.roll, yaw: headset.yaw, label: 1)
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, didChangeYaw yaw: Float, pitch: Float, andRoll roll: Float) {
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

