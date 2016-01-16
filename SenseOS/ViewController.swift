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
    @IBOutlet weak var ConnectionState: UILabel!

    var headset: IHSDevice!
    let sensorDelegate = SensorDelegate()
    let audioDelegate = AudioDelegate()
    let buttonDelegate = ButtonDelegate()
    let deviceDelegate = DeviceDelegate()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headset = IHSDevice(deviceDelegate: deviceDelegate)
        headset.connect()
        ConnectionState.text = connectionStateString
        ConsoleLog.text = ConsoleLog.text + "accelerometer data \(headset.pitch)" + "," + "\(headset.roll)" + "," + "\(headset.yaw)"
    }


}

