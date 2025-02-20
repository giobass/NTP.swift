//
//  NTPTests.swift
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

import XCTest

@testable import NTP

final class NTPTests: XCTestCase {
    
    // MARK: - Properties
    
    var ntpClient: NtpClient!
    
    // MARK: - Initialization
    
    override func setUp() {
        super.setUp()
        ntpClient = NtpClient(timeoutIntervalForRequest: 10)
    }
    
    override func tearDown() {
        ntpClient = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testNtpApple() {
        test(url: "ntp://time.apple.com")
    }
    
    func testNtpAppleEuro() {
        test(url: "ntp://time.euro.apple.com")
    }
    
    func testGoogleNtp1() {
        test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp2() {
        test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp3() {
        test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp4() {
        test(url: "ntp://time1.google.com")
    }
    
    func testCloudflare() {
        test(url: "ntp://time.cloudflare.com")
    }
    
    // MARK: - Asynchronous tests
    
    func testNtpAppleAsync() async throws {
        try await test(url: "ntp://time.apple.com")
    }
    
    func testNtpAppleEuroAsync() async throws {
        try await test(url: "ntp://time.euro.apple.com")
    }
    
    func testGoogleNtp1Async() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp2Async() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp3Async() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    func testGoogleNtp4Async() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    func testCloudflareAsync() async throws {
        try await test(url: "ntp://time.cloudflare.com")
    }
    
    // MARK: - Internals
    
    func test(url: String) {
        let expectation = expectation(description: "waiting for NTP server '\(url)' to provide current datetime")
        ntpClient.request(URL(string: url)!) { result in
            switch result {
                case .success(let date):
                    let local = Date()
                    let difference = abs(date.timeIntervalSince(local))
                    if difference < 1.0 {
                        expectation.fulfill()
                    } else {
                        XCTFail("Local date time and NTP server datetime differ by \(difference) seconds: LOCAL=\(local), NTP=\(date)")
                    }
                case .failure(let error):
                    XCTFail("Failed to retrieve current datetime from NTP server '\(url)': \(error)")
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test(url: String) async throws {
        let date = try await ntpClient.request(URL(string: url)!)
        let local = Date()
        let difference = abs(date.timeIntervalSince(local))
        if difference >= 1.0 {
            XCTFail("Local date time and NTP server datetime differ by \(difference) seconds: LOCAL=\(local), NTP=\(date)")
        }
    }
    
}
