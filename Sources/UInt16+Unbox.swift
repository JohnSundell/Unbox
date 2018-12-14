/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/// Extension making `UInt16` an Unboxable raw type
extension UInt16: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> UInt16? {
        return unboxedNumber.uint16Value
    }

    public static func transform(unboxedString: String) -> UInt16? {
        return UInt16(unboxedString)
    }
}

