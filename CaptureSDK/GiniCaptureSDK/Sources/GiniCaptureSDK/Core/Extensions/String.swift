//
//  String.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

extension String {
    var splitlines: [String] {
        var lines: [String] = []
        enumerateLines(invoking: { line, _ in
            lines.append(line)
        })
        return lines
    }
    
    public static func localized<T: LocalizableStringResource>(resource: T, args: CVarArg...) -> String {
        if args.isEmpty {
            return resource.localizedFormat
        } else {
            return String(format: resource.localizedFormat, arguments: args)
        }
    }
}
