//
//  NtpClient.swift
//  NTP.swift
//
//  GitHub Repo and Documentation: https://github.com/danielepantaleone/NTP.swift
//
//  Copyright © 2025 Daniele Pantaleone. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A client for querying Network Time Protocol (NTP) servers.
open class NtpClient {

    // MARK: - Type definition
    
    /// Errors that may occur when making an NTP request.
    public enum Error: Swift.Error {
        /// Indicates that no data was received from the NTP server.
        case noData
    }

    // MARK: - Properties
    
    /// The URLSession used for making network requests.
    let session: URLSession
    
    // MARK: - Initialization
    
    /// Creates an instance of `NtpClient` with a custom timeout interval.
    ///
    /// - Parameter timeoutIntervalForRequest: The timeout interval for network requests. Defaults to `15.0` seconds.
    public init(timeoutIntervalForRequest: TimeInterval = 15.0) {
        guard NtpURLProtocol.registerClass() else {
            fatalError("Failed to register NTP url protocol")
        }
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(NtpURLProtocol.self, at: 0)
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.urlCache = nil
        session = URLSession(configuration: configuration)
    }
    
    // MARK: - Interface
    
    /// Requests the current time from an NTP server using a callback-based approach.
    ///
    /// - Parameters:
    ///   - url: The URL of the NTP server.
    ///   - callback: A closure that receives the result, which is either a `Date` or an error.
    open func request(_ url: URL, callback: @Sendable @escaping (Result<Date, Swift.Error>) -> Void) {
        let task = session.dataTask(with: url) { data, _, error in
            if let error {
                callback(.failure(error))
                return
            }
            guard let data, data.count > 0 else {
                callback(.failure(Error.noData))
                return
            }
            callback(.success(Date(timeIntervalSince1970: data.withUnsafeBytes {
                $0.load(as: TimeInterval.self)
            })))
        }
        task.resume()
    }
    
    /// Requests the current time from an NTP server using Swift Concurrency.
    ///
    /// - Parameter url: The URL of the NTP server.
    /// - Returns: The current date as provided by the NTP server.
    /// - Throws: An error if the request fails.
    @available(iOS 13.0, *)
    open func request(_ url: URL) async throws -> Date {
        try await withCheckedThrowingContinuation { continuation in
            request(url) { result in
                continuation.resume(with: result)
            }
        }
    }
    
}
