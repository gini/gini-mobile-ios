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

     - Example:
     ```
     let timestamp = Date.berlinTimestamp()
     print("Timestamp in Berlin timezone: \(timestamp)")
     ```
     */
    static func berlinTimestamp() -> Int64 {
        // Get the current date
        let currentDate = Date()

        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Convert the current date to the Berlin timezone
        let berlinDateString = dateFormatter.string(from: currentDate)
        let berlinDate = dateFormatter.date(from: berlinDateString)!

        // Get the timestamp in milliseconds
        let timestamp = Int64(berlinDate.timeIntervalSince1970 * 1000)

        return timestamp
    }
}