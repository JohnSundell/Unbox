/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/// Extension making `Int16` an Unboxable raw type
extension Int16: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Int16? {
        return unboxedNumber.int16Value
    }

    public static func transform(unboxedString: String) -> Int16? {
        return Int16(unboxedString)
    }
}
