//
//  DefaultGiniHTTPClientTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("DefaultGiniHTTPClient Tests")
struct DefaultGiniHTTPClientTests {

    private var dummyRequest: URLRequest {
        guard let url = URL(string: "https://api.gini.net/test") else {
            fatalError("Invalid test URL - this should never happen")
        }
        return URLRequest(url: url)
    }

    @Test("dataRequest returns a CancellableTask that is a URLSessionTask")
    func dataRequestReturnsCancellableTask() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())

        let task: CancellableTask = await withCheckedContinuation { continuation in
            let task = client.dataRequest(dummyRequest) { _, _, _ in }
            continuation.resume(returning: task)
        }
        #expect(task is URLSessionTask, "Expected returned task to be a URLSessionTask")
    }

    @Test("dataRequest delivers data and response via completion")
    func dataRequestDeliversResponse() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())

        let (data, response, error) = await withCheckedContinuation { (continuation: CheckedContinuation<(Data?, URLResponse?, Error?), Never>) in
            client.dataRequest(dummyRequest) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }

        #expect(data != nil, "Expected data to be non-nil")
        #expect(response != nil, "Expected response to be non-nil")
        #expect(error == nil, "Expected no error")
        if let httpResponse = response as? HTTPURLResponse {
            #expect(httpResponse.statusCode == 200, "Expected 200 status code")
        }
    }

    @Test("uploadRequest returns a CancellableTask that is a URLSessionTask")
    func uploadRequestReturnsCancellableTask() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())
        let body = Data("test body".utf8)

        let task: CancellableTask = await withCheckedContinuation { continuation in
            let task = client.uploadRequest(dummyRequest, body: body) { _, _, _ in }
            continuation.resume(returning: task)
        }
        #expect(task is URLSessionTask, "Expected returned task to be a URLSessionTask")
    }

    @Test("uploadRequest delivers data and response via completion")
    func uploadRequestDeliversResponse() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())
        let body = Data("upload data".utf8)

        let (data, response, error) = await withCheckedContinuation { (continuation: CheckedContinuation<(Data?, URLResponse?, Error?), Never>) in
            client.uploadRequest(dummyRequest, body: body) { data, response, error in
                continuation.resume(returning: (data, response, error))
            }
        }

        #expect(data != nil, "Expected data to be non-nil")
        #expect(response != nil, "Expected response to be non-nil")
        #expect(error == nil, "Expected no error")
    }

    @Test("downloadRequest returns a CancellableTask that is a URLSessionTask")
    func downloadRequestReturnsCancellableTask() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())

        let task: CancellableTask = await withCheckedContinuation { continuation in
            let task = client.downloadRequest(dummyRequest) { _, _, _ in }
            continuation.resume(returning: task)
        }
        #expect(task is URLSessionTask, "Expected returned task to be a URLSessionTask")
    }

    @Test("downloadRequest delivers response via completion")
    func downloadRequestDeliversResponse() async {
        let client = DefaultGiniHTTPClient(session: makeStubSession())

        let (response, error) = await withCheckedContinuation { (continuation: CheckedContinuation<(URLResponse?, Error?), Never>) in
            client.downloadRequest(dummyRequest) { _, response, error in
                continuation.resume(returning: (response, error))
            }
        }

        #expect(response != nil, "Expected response to be non-nil")
        #expect(error == nil, "Expected no error")
    }

    @Test("Cancelling returned task cancels the underlying URLSessionTask")
    func cancellingReturnedTaskCancelsURLSessionTask() {
        let client = DefaultGiniHTTPClient(session: makeStubSession())

        let task = client.dataRequest(dummyRequest) { _, _, _ in }
        task.cancel()

        if let urlTask = task as? URLSessionTask {
            #expect(urlTask.state == .canceling || urlTask.state == .completed,
                    "Expected task to be cancelling or completed after cancel()")
        }
    }

    @Test("URLSessionTask conforms to CancellableTask")
    func urlSessionTaskConformsToCancellableTask() {
        let session = makeStubSession()
        let urlTask = session.dataTask(with: dummyRequest)
        let cancellable: CancellableTask = urlTask

        cancellable.cancel()

        #expect(urlTask.state == .canceling || urlTask.state == .completed,
                "Expected URLSessionTask to be cancelled via CancellableTask protocol")
    }
}
