//
//  NtpURLProtocol.swift
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
import Network

/// A shared global lock to guarantee thread safety.
private let globalLock = NSLock()
 
/// A custom URL protocol for handling NTP requests.
final class NtpURLProtocol: URLProtocol, @unchecked Sendable {

    // MARK: - Type definition
    
    /// Defines errors that may occur during the NTP request.
    enum Error: Swift.Error {
        /// The request was canceled.
        case canceled
        /// No host was specified in the URL.
        case noHost
        /// The request URL is missing.
        case noURL
    }
    
    // MARK: - Properties
    
    /// The network connection for the NTP request.
    private var connection: NWConnection?
    
    /// A flag indicating if the request has been completed.
    private var completed: Bool = false
    
    /// The time interval between 1900 and 1970 in seconds.
    private let timeFrom1900to1970 = 2_208_988_800.0

    // MARK: - Registration
    
    /// Indicates whether the protocol has been registered.
    nonisolated(unsafe) private static var registered: Bool = false
    
    /// Registers the protocol class.
    ///
    /// - Returns: `true` if registration is successful, otherwise `false`.
    static func registerClass() -> Bool {
        globalLock.lock()
        defer { globalLock.unlock() }
        guard !registered else {
            return true
        }
        registered = super.registerClass(NtpURLProtocol.self)
        return registered
    }
    
    // MARK: - Class functions
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return task.currentRequest?.url?.scheme?.lowercased() == "ntp"
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme?.lowercased() == "ntp"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // MARK: - Initialization
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse? = nil, client: URLProtocolClient? = nil) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse? = nil, client: URLProtocolClient? = nil) {
        guard let request = task.currentRequest else {
            preconditionFailure("URLSessionTask must have a request")
        }
        self.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    // MARK: - Control
    
    override func startLoading() {
        globalLock.lock()
        defer { globalLock.unlock() }
        do {
            guard let url = request.url else { throw Error.noURL }
            guard let host = url.host else { throw Error.noHost }
            let endpoint = NWEndpoint.hostPort(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(rawValue: UInt16(url.port ?? 123)) ?? 123)
            completed = false
            connection = NWConnection(to: endpoint, using: .udp)
            connection?.receiveMessage { [weak self] in
                self?.receive($0, $1, $2, $3)
            }
            connection?.stateUpdateHandler = { [weak self] state in
                self?.connectionChanged(to: state)
            }
            connection?.start(queue: .global(qos: .background))
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        globalLock.lock()
        defer { globalLock.unlock() }
        connection?.cancel()
        connection = nil
    }
    
    // MARK: - Internals
    
    /// Handles state changes in the network connection.
    ///
    /// - Parameter state: The new state of the connection.
    func connectionChanged(to state: NWConnection.State) {
        globalLock.lock()
        defer { globalLock.unlock() }
        switch state {
            case .cancelled:
                if !completed {
                    client?.urlProtocol(self, didFailWithError: Error.canceled)
                }
            case .failed(let error):
                client?.urlProtocol(self, didFailWithError: error)
            case .preparing:
                break
            case .ready:
                var buffer = NtpPacket()
                let data = Data(bytes: &buffer, count: MemoryLayout.size(ofValue: buffer))
                connection?.send(
                    content: data,
                    completion: .contentProcessed({ [weak self] error in
                        guard let self else { return }
                        guard let error else { return }
                        client?.urlProtocol(self, didFailWithError: error)
                    })
                )
            case .setup:
                break
            case .waiting(let error):
                client?.urlProtocol(self, didFailWithError: error)
            @unknown default:
                break
        }
    }
    
    /// Handles received data from the network connection.
    ///
    /// - Parameters:
    ///   - message: The received data message.
    ///   - context: The content context of the message.
    ///   - isComplete: Indicates whether the message is complete.
    ///   - error: An error that occurred during reception.
    func receive(_ message: Data?,
                 _ : NWConnection.ContentContext?,
                 _ isComplete: Bool,
                 _ error: NWError?) {
        globalLock.lock()
        defer { globalLock.unlock() }
        if let error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let message {
            let packet = message.withUnsafeBytes { $0.load(as: NtpPacket.self) }.nativeEndian
            var time = packet.receiveTime.timeInterval - timeFrom1900to1970
            let data = Data(bytes: &time, count: MemoryLayout<TimeInterval>.size)
            client?.urlProtocol(self, didLoad: data)
        }
        if isComplete {
            completed = true
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
}
