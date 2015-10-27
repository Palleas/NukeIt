//
//  AppDelegate.swift
//  NukeIt
//
//  Created by Romain Pouclet on 2015-10-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Cocoa
import ORSSerial

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var port: ORSSerialPort!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        port = ORSSerialPortManager.sharedSerialPortManager().availablePorts.first
        port.delegate = self
        port.baudRate = 9600
        port.open()
    }

}

extension AppDelegate {
    func nuke() {
        let path = String("/Users/Romain/Library/Developer/Xcode/DerivedData/")
        do {
            let subdirectories = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            
            print(subdirectories)
            try subdirectories.forEach({ (subdirectory) -> () in
                try NSFileManager.defaultManager().removeItemAtPath(path + subdirectory)
            })
            print("Nuked dd folder")
            
            let notification = NSUserNotification()
            notification.title = "DerivedData folder has been nuked! 🔥"
            
            let hub = NSUserNotificationCenter.defaultUserNotificationCenter()
            hub.deliverNotification(notification)
        } catch {
            print("Unable to nuke dd folder \(error)")
        }
    }
}

extension AppDelegate: ORSSerialPortDelegate {
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        print("Port \(serialPort) was opened")
    }
    
    func serialPortWasClosed(serialPort: ORSSerialPort) {
        print("Port \(serialPort) was closed")
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        print("Removed :(")
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        if let payload = NSString(data: data, encoding: NSUTF8StringEncoding) where payload.rangeOfString("\n").location != NSNotFound {
            nuke()
        }
    }
}