//
//  ViewController.swift
//  SenseOS
//
//  Created by Chris Maury on 1/15/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSButtonDelegate {
    
    @IBOutlet weak var ConsoleLog: UITextView!
    @IBOutlet weak var ConnectionState: UILabel!
    
    @IBAction func RefreshData(sender: UIButton) {
    }
    
    
    var headset: IHSDevice!
    let sensorDelegate = SensorDelegate()
    let audioDelegate = AudioDelegate()
    let buttonDelegate = ButtonDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headset = IHSDevice(deviceDelegate: self)
        print("connection state is \(headset.connectionState.rawValue)")
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
        ConsoleLog.text = ConsoleLog.text + "accelerometer data \(headset.pitch)" + "," + "\(headset.roll)" + "," + "\(headset.yaw)"
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
        print("accelerometer data changed")
        
        if ihs.gyroCalibrated {
            ihs.accelerometerData
        }
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

