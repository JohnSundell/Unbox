/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/// Extension making `URL` Unboxable by transform
extension URL: UnboxableByTransform {
    public typealias UnboxRawValue = String

    public static func transform(unboxedValue: String) -> URL? {
        guard let encodedString = unboxedValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: encodedString)
    }
}
