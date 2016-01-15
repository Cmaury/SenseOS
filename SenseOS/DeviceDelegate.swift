
//  GestureController.swift
//  SenseOS=Demo
//
//  Created by Chris Maury on 1/13/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class DeviceDelegate: NSObject, IHSDeviceDelegate {
    
    func ihsDevice(ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
            print("device state changed to \(connectionState)")
        }
    
    func ihsDeviceFoundAmbiguousDevices(ihs: IHSDevice!) {
        
    }
}









