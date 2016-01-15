//
//  ViewController.swift
//  SenseOS
//
//  Created by Chris Maury on 1/15/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ConsoleLog: UITextView!

    var headset: IHSDevice!
    let sensorDelegate = SensorDelegate()
    let audioDelegate = AudioDelegate()
    let buttonDelegate = ButtonDelegate()
    let deviceDelegate = DeviceDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headset = IHSDevice(deviceDelegate: deviceDelegate)
        headset.connect()
        
        
        ConsoleLog.text = ConsoleLog.text + "connections state is " + "\(headset.connectionState) \n	"
        print("connections state is \(headset.connectionState)")
        ConsoleLog.text = ConsoleLog.text + "accelerometer data \(headset.pitch)" + "," + "\(headset.roll)" + "," + "\(headset.yaw)"
    }


}

