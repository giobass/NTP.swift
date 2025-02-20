//
//  NtpTime64.swift
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

/// A structure representing a 64-bit NTP timestamp, composed of a whole part and a fractional part.
struct NtpTime64 {
    
    /// The whole part of the NTP timestamp.
    var whole: UInt32
    
    /// The fractional part of the NTP timestamp.
    var fraction: UInt32
    
    /// Returns a new `NtpTime64` instance with byte-swapped values for both the whole and fractional parts.
    var byteSwapped: NtpTime64 {
        return NtpTime64(whole: whole.byteSwapped, fraction: fraction.byteSwapped)
    }
    
    /// Converts the NTP timestamp to a `TimeInterval`.
    ///
    /// This attempts to construct a floating-point representation from the `whole` and `fraction` parts.
    /// If conversion fails, it falls back to returning `whole` as a `TimeInterval`.
    var timeInterval: TimeInterval {
        guard let double = Double("\(whole).\(fraction)") else {
            return TimeInterval(whole)
        }
        return TimeInterval(double)
    }
    
}
