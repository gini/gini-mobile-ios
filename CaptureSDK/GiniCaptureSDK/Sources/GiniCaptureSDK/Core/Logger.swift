//
//  Logger.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 5/14/18.
//

import Foundation
import os
import GiniUtilites

func Log(message: String, event: String) {
    let giniConfiguration = GiniConfiguration.shared
    if giniConfiguration.debugModeOn {
        giniConfiguration.logger.log(message: "\(event) \(message)")
    }
}
