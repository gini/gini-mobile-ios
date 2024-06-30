//
//  AmplitudeService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 A service for tracking and uploading events to the Amplitude analytics platform using directly Ampltitude API.

 This service manages an event queue and handles the periodic uploading of events
 to the Amplitude server. It supports automatic retries with exponential backoff
 in case of upload failures. The service also observes application lifecycle events
 to manage background tasks appropriately.
 */
final class AmplitudeService {
    private var eventQueue: [BaseEvent] = []
    private var apiKey: String?
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var retryAttempts: Int = 0
    private let maxRetryAttempts = 3
    private let apiURL = "https://api.eu.amplitude.com/batch"

    /**
     Initializes the AmplitudeService with the provided API key.

     - Parameter apiKey: The API key for the Amplitude analytics platform.
     */
    init(apiKey: String?) {
        self.apiKey = apiKey
        setupObservers()
        startEventUploadTimer()
        uploadPendingEvents() // Immediate upload on initialization
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopEventUploadTimer()
    }

    func trackEvents(_ events: [BaseEvent]) {
        eventQueue = events
        uploadEvents(events: events)
    }

    /**
     Uploads events to the Amplitude server.

     - Parameter events: An array of `BaseEvent` objects to upload.
     */
    private func uploadEvents(events: [BaseEvent]) {
        guard let url = URL(string: apiURL), let apiKey, events.isNotEmpty else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = EventsBatchPayload(apiKey: apiKey, events: events)

        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error uploading events: \(error)")
                    self.handleUploadFailure(events: events)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Successfully uploaded events")
                        self.retryAttempts = 0
                        self.eventQueueCleanup()
                    } else {
                        print("Failed to upload events: \(httpResponse.statusCode)")
                        self.handleUploadFailure(events: events)
                    }
                }
            }
            task.resume()
        } catch {
            print("Error encoding events: \(error)")
            handleUploadFailure(events: events)
        }
    }

    /**
     Handles the failure of an event upload by implementing an exponential backoff retry strategy.

     - Parameter events: An array of `BaseEvent` objects that failed to upload.

     This method increments the retry attempt counter and checks if it has exceeded the maximum allowed retry attempts.
     If the maximum retries have not been reached, the method re-adds the failed events back to the event queue and
     schedules a retry using an exponential backoff strategy. The retry delay is calculated as `2^retryAttempts` seconds.

     The method uses `DispatchQueue.global().asyncAfter` to schedule the `uploadPendingEvents` method after the calculated delay.
     If the maximum number of retry attempts is reached, it logs a message and resets the retry attempt counter.

     - Note: The exponential backoff strategy helps prevent overwhelming the server with repeated requests
     and allows it time to recover between retries.
     */

    private func handleUploadFailure(events: [BaseEvent]) {
        retryAttempts += 1
        if retryAttempts <= maxRetryAttempts {
            eventQueue.append(contentsOf: events)
            // Calculate the delay before retrying an event upload after a failure.
            // It employs an exponential backoff strategy.
            let retryDelay = pow(2.0, Double(retryAttempts)) // Exponential backoff
            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                self?.uploadPendingEvents()
            }
        } else {
            print("Max retry attempts reached. Failed to upload events.")
            retryAttempts = 0
        }
    }

    /**
     Starts a timer to periodically upload pending events.
     */
    private func startEventUploadTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.uploadPendingEvents()
        }
    }

    /**
    Stops the event upload timer.
    */
    private func stopEventUploadTimer() {
        timer?.invalidate()
        timer = nil
    }

    /**
     Uploads pending events from the event queue.
     */
    private func uploadPendingEvents() {
        guard !eventQueue.isEmpty else { return }
        let eventsToUpload = eventQueue
        uploadEvents(events: eventsToUpload)
    }

    private func eventQueueCleanup() {
        eventQueue.removeAll()
    }

    /**
     Sets up observers for application lifecycle events.
     */
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    @objc private func appDidEnterBackground() {
        stopEventUploadTimer()
        startBackgroundTask()
    }

    @objc private func appWillEnterForeground() {
        endBackgroundTask()
        startEventUploadTimer()
    }

    @objc private func appWillTerminate() {
        stopEventUploadTimer()
        uploadPendingEvents()
    }

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        uploadPendingEvents()
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
