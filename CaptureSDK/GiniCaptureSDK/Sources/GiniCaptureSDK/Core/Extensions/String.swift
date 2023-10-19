//
//  String.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

extension String {
    /*
     In this implementation, the regular expression pattern "\r\r?\n" matches one or more consecutive occurrences of the line separator (\r\n) or double line separator (\r\r\n). The replacingOccurrences(of:with:options:) method is then used to replace all occurrences of this pattern with a single new line character (\n), and the resulting string is split into an array of lines using the components(separatedBy:) method with the newlines delimiter.
     */
    var splitlines: [String] {
        let pattern = #"\r\r?\n"#
        return self.replacingOccurrences(of: pattern, with: "\n", options: .regularExpression)
                   .components(separatedBy: .newlines)
    }

    public static func localized<T: LocalizableStringResource>(resource: T, args: CVarArg...) -> String {
        if args.isEmpty {
            return resource.localizedFormat
        } else {
            return String(format: resource.localizedFormat, arguments: args)
        }
    }

    func split(every length: Int, by separator: String = " ") -> String {
        guard length > 0 && length < count else { return self }

        return (0 ... (count - 1) / length).map {
            dropFirst($0 * length).prefix(length)
        }.joined(separator: separator)
    }
}
