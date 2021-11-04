//
//  ErrorLog.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.07.21.
//

import UIKit
public struct ErrorLog {
    
    public var deviceModel: String = UIDevice.current.model
    public var osName: String = UIDevice.current.systemName
    public var osVersion: String = UIDevice.current.systemVersion
    public var captureVersion: String = GiniCapture.versionString
    public var description: String
    public var error: Error? = nil

}
