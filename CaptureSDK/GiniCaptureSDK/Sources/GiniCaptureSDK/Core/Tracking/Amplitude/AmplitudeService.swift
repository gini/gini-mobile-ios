//
//  AmplitudeService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniBankAPILibrary

/**
 A service for tracking and uploading events to the Amplitude analytics platform using directly Ampltitude API.

 This service manages an event queue and handles the periodic uploading of events
 to the Amplitude server. It supports automatic retries with exponential backoff
 in case of upload failures. The service also observes application lifecycle events
 to manage background tasks appropriately.
 */

final class AmplitudeService {
    /**
     * The state of an event in the queue.
     */
    private enum EventState {
        case pending
        case inProgress
        case sent
    }

    /**
     * A wrapper for an event, including its state and retry count.
     */
    private struct EventWrapper {
        var event: AmplitudeBaseEvent
        var state: EventState
        var retryCount: Int = 0
    }

    private var eventQueue: [EventWrapper] = []
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let maxRetryAttempts = 3
    private let eventUploadInterval: TimeInterval = 5.0
    private let apiURL = "https://api.eu.amplitude.com/batch"
    private let queue = DispatchQueue(label: "com.amplitude.service.queue")
    private var analyticsAPIService: AnalyticsServiceProtocol?

    init(analyticsAPIService: AnalyticsServiceProtocol?) {
        self.analyticsAPIService = analyticsAPIService
        setupObservers()
        startEventUploadTimer()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopEventUploadTimer()
    }

    /**
     * Tracks a list of events by adding them to the event queue.
     * - Parameter events: The events to be tracked.
     */
    func trackEvents(_ events: [AmplitudeBaseEvent]) {
        let newEvents = events.map { EventWrapper(event: $0, state: .pending) }
        queue.async {
            self.eventQueue.append(contentsOf: newEvents)
            self.uploadPendingEvents()
        }
    }

    /**
     * Uploads a list of events to the Amplitude server.
     * - Parameter events: The events to be uploaded.
     */
    private func uploadEvents(events: [EventWrapper]) {
        let payload = AmplitudeEventsBatchPayload(events: events.map { $0.event })
        analyticsAPIService?.sendEventsPayload(payload: payload, completion: { result in
            switch result {
            case .success(_):
                print("✅ Successfully uploaded events")
                self.markEventsAsSent(events: events)
                self.resetAndCleanup()
            case .failure(let error):
                print("❌ Failed to upload events: \(error)")
                self.handleUploadFailure(events: events)
            }
        })
    }

    /**
     * Handles the failure of an event upload by retrying the upload if the maximum retry attempts have not been reached.
     * - Parameter events: The events that failed to upload.
     */
    private func handleUploadFailure(events: [EventWrapper]) {
        guard !events.isEmpty else { return }

        queue.async {
            for event in events {
                if let index = self.eventQueue.firstIndex(where: { $0.event == event.event }) {
                    self.eventQueue[index].retryCount += 1
                    if self.eventQueue[index].retryCount > self.maxRetryAttempts {
                        self.eventQueue.remove(at: index)
                    } else {
                        self.eventQueue[index].state = .pending
                    }
                }
            }

            let retryDelay = pow(2.0, Double(events.first?.retryCount ?? 0))
            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                self?.uploadPendingEvents()
            }
        }
    }

    /**
     * Starts the timer that periodically attempts to upload pending events.
     */
    private func startEventUploadTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: eventUploadInterval,
                                     repeats: true) { [weak self] _ in
            self?.uploadPendingEvents()
        }
    }

    /**
     * Stops the event upload timer.
     */
    private func stopEventUploadTimer() {
        timer?.invalidate()
        timer = nil
    }

    /**
     * Uploads all pending events by changing their state to inProgress and attempting to send them.
     */
    private func uploadPendingEvents() {
        queue.async {
            let pendingEvents = self.eventQueue.filter { $0.state == .pending }
            guard !pendingEvents.isEmpty else { return }
            for event in pendingEvents {
                if let index = self.eventQueue.firstIndex(where: { $0.event == event.event }) {
                    self.eventQueue[index].state = .inProgress
                }
            }
            self.uploadEvents(events: pendingEvents)
        }
    }

    /**
     * Resets the retry attempts and removes all sent events from the queue.
     */
    private func resetAndCleanup() {
        queue.async {
            self.eventQueue.removeAll { $0.state == .sent }
        }
    }

    /**
     * Marks the specified events as sent by updating their state in the queue.
     * - Parameter events: The events to mark as sent.
     */
    private func markEventsAsSent(events: [EventWrapper]) {
        queue.async {
            for event in events {
                if let index = self.eventQueue.firstIndex(where: { $0.event == event.event }) {
                    self.eventQueue[index].state = .sent
                }
            }
        }
    }

    /**
     * Sets up the observers for application lifecycle events.
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

    /**
     * Called when the application enters the background.
     */
    @objc private func appDidEnterBackground() {
        stopEventUploadTimer()
        startBackgroundTask()
    }

    /**
     * Called when the application will enter the foreground.
     */
    @objc private func appWillEnterForeground() {
        endBackgroundTask()
        startEventUploadTimer()
    }

    /**
     * Called when the application will terminate.
     */
    @objc private func appWillTerminate() {
        stopEventUploadTimer()
        uploadPendingEvents()
    }

    /**
     * Starts a background task to continue uploading events when the app enters the background.
     */
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        uploadPendingEvents()
    }

    /**
     * Ends the background task.
     */
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
