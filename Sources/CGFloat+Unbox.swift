/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

#if !os(Linux)
    import CoreGraphics
#else
    import Foundation
#endif

/// Extension making `CGFloat` an Unboxable raw type
extension CGFloat: UnboxableByTransform {
    public typealias UnboxRawValue = Double

    public static func transform(unboxedValue: Double) -> CGFloat? {
        return CGFloat(unboxedValue)
    }
}
