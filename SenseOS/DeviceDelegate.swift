
//  GestureController.swift
//  SenseOS=Demo
//
//  Created by Chris Maury on 1/13/16.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

var connectionStateString = ""

class DeviceDelegate: NSObject, IHSDeviceDelegate {
    
    @objc func ihsDevice(ihs: IHSDevice!, connectionStateChanged connectionState: IHSDeviceConnectionState) {
        
        switch connectionState {
            case IHSDeviceConnectionState.None:
                
                connectionStateString = "None"
            case IHSDeviceConnectionState.Disconnected: connectionStateString = "Disconnected"
            case IHSDeviceConnectionState.Discovering: connectionStateString = "Discovering"
            case IHSDeviceConnectionState.Connecting: connectionStateString = "Connecting..."
            case IHSDeviceConnectionState.Connected: connectionStateString = "Connected"
            case IHSDeviceConnectionState.ConnectionFailed:
                connectionStateString = "Connection Failed"
            case IHSDeviceConnectionState.BluetoothOff: connectionStateString = "Bluetooth is off"
        default: break
        }
            print("device state changed to " + connectionStateString)
        }
    
    func ihsDeviceFoundAmbiguousDevices(ihs: IHSDevice!) {
        
    }
}





