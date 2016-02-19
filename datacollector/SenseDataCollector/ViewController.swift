//
//  ViewController.swift
//  SenseOS
//
//  Created by Chris Maury on 1/15/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit
import AVFoundation

enum gestureLabel: String {
    case None
    case NodUp
    case NodDown
    case NodLeft
    case NodRight
    case LookLeft
    case LookRight
    case ShakeVertical
    case ShakeHorizontal
}

class ViewController: UIViewController, IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSButtonDelegate, MyTopicEventHandler {
    
    // UI
    // labels
    @IBOutlet weak var ConnectionState: UILabel!
    @IBOutlet weak var pitchLabel: UILabel?
    @IBOutlet weak var rollLabel: UILabel?
    @IBOutlet weak var yawLabel: UILabel?
    @IBOutlet weak var xLabel: UILabel?
    @IBOutlet weak var yLabel: UILabel?
    @IBOutlet weak var zLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    // buttons
    @IBOutlet weak var exportDataButton: UIButton!
    @IBOutlet weak var nodUpButton: UIButton!
    @IBOutlet weak var nodDownButton: UIButton!
    @IBOutlet weak var nodRightButton: UIButton!
    @IBOutlet weak var nodLeftButton: UIButton!
    @IBOutlet weak var lookRightButton: UIButton!
    @IBOutlet weak var lookLeftButton: UIButton!
    @IBOutlet weak var shakeHorizontalButton: UIButton!
    @IBOutlet weak var shakeVerticalButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    // headset
    let headset = IHSDevice(deviceDelegate: ViewController.self as! IHSDeviceDelegate)
    // data collection
    let dataFileName = "data.csv"
    var gestureUID = 0
    var sessionActive = false
    var showedDeviceSelection = false
    var topicHandler: MyTopic?
    
    var currentGestureLabel = gestureLabel.None
    @IBOutlet weak var gestureText: UILabel!

    @IBAction func startSession(sender: UIButton) {
       //while in session randomly speak a gesture
        //record data during that time period as that gesture
        sessionActive = !sessionActive
        
        
        let sequence = SAYAudioEventSequence()
        sequence.addEvent(SAYSpeechEvent(utteranceString: ""), withCompletionBlock: {
            //After you hear the tone, perform the gesture indicated. When you are finished tap the start stop button to end the current session
            self.setGestureToBeRecorded()
            print("start gesture recognition")
            })
        self.topicHandler?.postEvents(sequence)
        
        
        
    }
    var random = 0 {
        
        didSet {
            switch random {
            case 0	:
                topicHandler?.recordGesture("Nod Up", gesture: gestureLabel.NodUp)
                
            case 1:
                currentGestureLabel = gestureLabel.None
                topicHandler?.recordGesture("Nod Down", gesture: gestureLabel.NodDown)
            case 2:
                topicHandler?.recordGesture("Look Left and then forward", gesture: gestureLabel.NodLeft)
            case 3:
                topicHandler?.recordGesture("Look Right and then forward", gesture: gestureLabel.NodRight)
            case 4:
                topicHandler?.recordGesture("Look Left", gesture: gestureLabel.LookLeft)
            case 5:
                topicHandler?.recordGesture("Look Right", gesture: gestureLabel.LookRight)
            case 6:
                topicHandler?.recordGesture("Shake your head left and right", gesture: gestureLabel.ShakeHorizontal)
            case 7:
                topicHandler?.recordGesture("Shake your head up and down", gesture: gestureLabel.ShakeVertical)
            default: print("did not match case")
            }
        }
        
    }
    
    func setGestureToBeRecorded() {
        print("session active state is \(sessionActive)")
        if sessionActive == true {
            random = Int(arc4random_uniform(8))
            print("\(random)")

        }
        
    }
    
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
        logDataHeader() // create first row (header) in data file
        // set up buttons
        exportDataButton.backgroundColor = UIColor.blackColor()
        nodUpButton.backgroundColor = UIColor.grayColor()
        nodDownButton.backgroundColor = UIColor.grayColor()
        nodRightButton.backgroundColor = UIColor.grayColor()
        nodLeftButton.backgroundColor = UIColor.grayColor()
        lookRightButton.backgroundColor = UIColor.grayColor()
        lookLeftButton.backgroundColor = UIColor.grayColor()
        shakeHorizontalButton.backgroundColor = UIColor.grayColor()
        shakeVerticalButton.backgroundColor = UIColor.grayColor()
        deleteButton.backgroundColor = UIColor.redColor()
        nodUpButton.exclusiveTouch = true
        nodDownButton.exclusiveTouch = true
        nodRightButton.exclusiveTouch = true
        nodLeftButton.exclusiveTouch = true
        lookRightButton.exclusiveTouch = true
        lookLeftButton.exclusiveTouch = true
        shakeHorizontalButton.exclusiveTouch = true
        shakeVerticalButton.exclusiveTouch = true
        deleteButton.exclusiveTouch = true
        // set gesture text
        gestureText.text = "Current Gesture: " + currentGestureLabel.rawValue
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
            //print("Wrote to file " + String(file))
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
    func logDataHeader() {
        let data = "pitch,roll,yaw,aceelX,accelY,accelZ,label,UID,headsetConnectionState,timeStamp\n"
        writeToFile(data, file: dataFileName)
    }
    func logData(pitch: Float, roll: Float, yaw: Float, accelX: Double, accelY: Double, accelZ: Double){
        // also logs: gesture label, gesture ID, headset connection status, and timestamp
        var data = String(pitch) + "," + String(roll) + "," + String(yaw) + ","
        data += String(accelX) + "," + String(accelY) + "," + String(accelZ) + ","
        data += String(currentGestureLabel.rawValue) + "," + String(gestureUID) + ","
        data += String(ConnectionState.text!) + "," + String(NSDate().timeIntervalSince1970 * 1000) + "\n"
        writeToFile(data, file: dataFileName)
    }
    // logs an "ignore" - ignore the last gesture
    func logIgnoreLast() {
        let data = "IGNORE,IGNORE,IGNORE,IGNORE,IGNORE,IGNORE,IGNORE,IGNORE,IGNORE,IGNORE\n"
        writeToFile(data, file: dataFileName)
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
        if !showedDeviceSelection {
            ihs.showDeviceSelection(self)
            showedDeviceSelection = true
        }
    }
    
    //Sensor Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, accelerometer3AxisDataChanged data: IHSAHRS3AxisStruct) {
        pitchLabel?.text = String(headset.pitch)
        rollLabel?.text = String(headset.roll)
        yawLabel?.text = String(headset.yaw)
        xLabel?.text = String(headset.accelerometerData.x)
        yLabel?.text = String(headset.accelerometerData.y)
        zLabel?.text = String(headset.accelerometerData.z)
        timeLabel?.text = "\(NSDate().timeIntervalSince1970 * 1000)"
        logData(headset.pitch, roll: headset.roll, yaw: headset.yaw, accelX: headset.accelerometerData.x, accelY: headset.accelerometerData.y, accelZ: headset.accelerometerData.z)
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
    
    // BUTTON UP/DOWN METHODS //
    func updateGestureText() {
        gestureText.text = "Current Gesture: " + currentGestureLabel.rawValue + " [" + String(gestureUID) + "]"
    }
    
    @IBAction func NodUpTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.NodUp
        updateGestureText()
    }
    @IBAction func NodDownTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.NodDown
        updateGestureText()
    }
    @IBAction func NodRightTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.NodRight
        updateGestureText()
    }
    @IBAction func NodLeftTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.NodLeft
        updateGestureText()
    }
    @IBAction func LookRightTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.LookRight
        updateGestureText()
    }
    @IBAction func LookLeftTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.LookLeft
        updateGestureText()
    }
    @IBAction func ShakeHTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.ShakeHorizontal
        updateGestureText()
    }
    @IBAction func ShakeVTouchDown(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.ShakeVertical
        updateGestureText()
    }
    @IBAction func NoGesture(sender: AnyObject) {
        gestureUID++
        currentGestureLabel = gestureLabel.None
        updateGestureText()
    }
    @IBAction func IgnoreLastGesture(sender: AnyObject) {
        logIgnoreLast()
    }
    

}

