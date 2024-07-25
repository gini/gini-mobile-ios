//
//  Date.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    /**
     Returns the current timestamp in milliseconds for the Berlin timezone.

     This method calculates the current date and time, adjusts it to the Berlin timezone,
     and then returns the timestamp in milliseconds since the Unix epoch (January 1, 1970).

     - Returns: An `Int64` representing the current timestamp in milliseconds for the Berlin timezone.
     */
    static func berlinTimestamp() -> Int64? {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        let dateString = dateFormatter.string(from: date)

        // Convert the formatted date string back to a Date object
        guard let berlinDate = dateFormatter.date(from: dateString) else {
            print("Failed to convert string to date")
            return nil
        }
            // Convert the time interval to milliseconds and then to Int64
        return Int64(berlinDate.timeIntervalSince1970 * 1000)
    }
}
