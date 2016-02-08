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

    @IBOutlet weak var audioOutput: UILabel!
   
    @IBOutlet weak var ConnectionState: UILabel!
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
        var fileText = ""
        var fileIndex = ""
        if sender.title == "Accel" {
            fileIndex = "accel_Data"
        }
        else { fileIndex = "Gyro_Data" }
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
    
    @IBAction func playNotificaiton(sender: AnyObject) {
        
        stateManager.state = SAYState.notification
        let random = arc4random_uniform(2)
    
            
        player!.volume = 1.0
        if random == 0 {
            player!.pan = -1.0
            (stateManager.activeState as! SAYStateNotification).direction = "left"
        }
        else {
            player!.pan = 1.0
            (stateManager.activeState as! SAYStateNotification).direction = "right"
        }
        player!.play()
    }
    
    @IBAction func gestureButton(sender: UIButton) {
        print("\(sender.titleLabel?.text)")
        if let text = sender.titleLabel {
                switch text.text! {
                case "Nod Up":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.up)
                case "Nod Down":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.down)
                case "Look Left":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.left)
                case "Look Right":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.right)
                case "Shake Up/Down":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.shakeVertical)
                case "Shake Left/Right":
                    stateManager.gestureRecognizer.recognizedGesture(SAYGesture.shakeHorizontal)
                default: break
                }
            
        }

        
    }
    
    let headset = IHSDevice(deviceDelegate: ViewController.self as! IHSDeviceDelegate)
    
    //var gestureRecognizer: SAYGestureRecognizer!
    var soundBoard: SAYSoundBoard?
    var audioCoordinator: SAYAudioTrackCoordinator?
    var stateManager: SAYStateManager!
    var player: AVAudioPlayer?
    var showedDeviceSelection = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        stateManager = SAYStateManager(viewController: self)
        stateManager.state = SAYState.resting
        
        
        let path = NSBundle.mainBundle().pathForResource("thinking", ofType: "wav")
        let url = NSURL(fileURLWithPath: path!)

        player = try! AVAudioPlayer(contentsOfURL: url)

        if headset.connectionState != IHSDeviceConnectionState.Connected {
            ConnectionState.text = "not connected"
            print("trying to connect")
            headset.deviceDelegate = self
            headset.sensorsDelegate = self
            headset.audioDelegate = self
            headset.buttonDelegate = self
            headset.connect()
            stateManager.state = SAYState.resting
            print("\(headset.connectionState.rawValue)")
        }
        print("connection state is \(headset.connectionState.rawValue)")
    }
    
    
    //sayKit integration
    func presentResultText(text: String) {
        dispatch_async(dispatch_get_main_queue()){
            self.audioOutput.text = text
        }
        soundBoard?.speakText(text)
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
                
                
                //saving data to file is broken. fix later.
                //print("created file: \(file)")
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
        ihs.connect()
        if !showedDeviceSelection {
            ihs.showDeviceSelection(self)
            showedDeviceSelection = true
        }
        
    }
    
    
    
    //Sensor Delegate Methods
    @objc func ihsDevice(ihs: IHSDevice!, accelerometer3AxisDataChanged data: IHSAHRS3AxisStruct) {
        
        accelX.text = " \(headset.pitch)"
        accelY.text = "\(headset.roll)"
        accelZ.text =  "\(headset.yaw)"
        
        if ihs.gyroCalibrated {
            let file = "accel_Data"
            let text = "\(ihs.accelerometerData.x), \(ihs.accelerometerData.y), \(ihs.accelerometerData.z)"
            updateLog(text, file: file)
            //print(text)
            
        }
    }
    
    @objc func ihsDevice(ihs: IHSDevice!, didChangeYaw yaw: Float, pitch: Float, andRoll roll: Float) {
        let file = "Gyro_Data"
        let text = "\(ihs.yaw), \(ihs.pitch), \(ihs.roll)"
        updateLog(text, file: file)
        //print(text)
        
        
        stateManager.gestureRecognizer.detectGesture()
        
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

