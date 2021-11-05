//
//  String+Utils.swift
// GiniBank
//
//  Created by Nadya Karaban on 04.03.21.
//

import Foundation
import GiniCaptureSDK

extension String {
    public static func ginibankLocalized<T: LocalizableStringResource>(resource: T, args: CVarArg...) -> String {
        if args.isEmpty {
            return resource.localizedGiniBankFormat
        } else {
            return String(format: resource.localizedGiniBankFormat, arguments: args)
        }
    }
}
