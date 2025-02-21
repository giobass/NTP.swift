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

import Foundation
import Network
import Testing

@testable import NTP

struct NTPTests {
    
    // MARK: - Tests
    
    @Test
    func testNtpApple() async throws {
        try await test(url: "ntp://time.apple.com")
    }
    
    @Test
    func testNtpAppleEuro() async throws {
        try await test(url: "ntp://time.euro.apple.com")
    }
    
    @Test
    func testGoogleNtp1() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    @Test
    func testGoogleNtp2() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    @Test
    func testGoogleNtp3() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    @Test
    func testGoogleNtp4() async throws {
        try await test(url: "ntp://time1.google.com")
    }
    
    @Test
    func testCloudflare() async throws {
        try await test(url: "ntp://time.cloudflare.com")
    }
    
    @Test
    func testInvalidNtpService() async throws {
        await #expect(throws: Error.self) {
            try await test(url: "ntp://time.invalid-server.com")
        }
    }
    
    // MARK: - Internals
    
    func test(url: String) async throws {
        let ntpClient: NtpClient = NtpClient(timeoutIntervalForRequest: 10)
        let date = try await ntpClient.request(URL(string: url)!)
        let local = Date()
        let difference = abs(date.timeIntervalSince(local))
        if difference >= 1.0 {
            Issue.record("Local date time and NTP server datetime differ by \(difference) seconds: LOCAL=\(local), NTP=\(date)")
        }
    }
    
}
