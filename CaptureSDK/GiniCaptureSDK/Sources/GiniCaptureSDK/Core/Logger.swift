//
//  Logger.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 5/14/18.
//

import Foundation
import os
import GiniUtilites

func Log(message: String,
         event: String,
         giniConfig: GiniConfiguration = .shared) {
    if giniConfig.debugModeOn {
        giniConfig.logger.log(message: "\(event) \(message)")
    }
}

public protocol GiniLogger: AnyObject {

    /**
     Logs a message

     - parameter message: Message printed out

     */
    func log(message: String)
}

public final class DefaultLogger: GiniLogger {

    public func log(message: String) {
        let prefix = "[ GiniCapture ]"

        Log(message, event: .custom(prefix))
    }
}
