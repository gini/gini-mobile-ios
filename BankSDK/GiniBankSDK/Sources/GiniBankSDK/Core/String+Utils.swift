//
//  String+Utils.swift
//  GiniPayBank
//
//  Created by Nadya Karaban on 04.03.21.
//

import Foundation
import GiniCapture

extension String {
    public static func ginipayLocalized<T: LocalizableStringResource>(resource: T, args: CVarArg...) -> String {
        if args.isEmpty {
            return resource.localizedGiniPayFormat
        } else {
            return String(format: resource.localizedGiniPayFormat, arguments: args)
        }
    }
}
