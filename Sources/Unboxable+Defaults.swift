/**
 *  Unbox - the easy to use Swift JSON decoder
 *
 *  For usage, see documentation of the classes/symbols listed in this file, as well
 *  as the guide available at: github.com/johnsundell/unbox
 *
 *  Copyright (c) 2015 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation
#if !os(Linux)
import CoreGraphics
#endif


/// Extension making Bool an Unboxable raw type
extension Bool: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Bool? {
        return unboxedNumber.boolValue
    }

    public static func transform(unboxedString: String) -> Bool? {
        switch unboxedString.lowercased() {
        case "true", "t", "y", "yes": return true
        case "false", "f" , "n", "no": return false
        default: return nil
        }
    }
}

/// Extension making Int an Unboxable raw type
extension Int: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Int? {
        return unboxedNumber.intValue
    }

    public static func transform(unboxedString: String) -> Int? {
        return Int(unboxedString)
    }
}

/// Extension making UInt an Unboxable raw type
extension UInt: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> UInt? {
        return unboxedNumber.uintValue
    }

    public static func transform(unboxedString: String) -> UInt? {
        return UInt(unboxedString)
    }
}

/// Extension making Int32 an Unboxable raw type
extension Int32: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Int32? {
        return unboxedNumber.int32Value
    }

    public static func transform(unboxedString: String) -> Int32? {
        return Int32(unboxedString)
    }
}

/// Extension making Int64 an Unboxable raw type
extension Int64: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Int64? {
        return unboxedNumber.int64Value
    }

    public static func transform(unboxedString: String) -> Int64? {
        return Int64(unboxedString)
    }
}

/// Extension making UInt32 an Unboxable raw type
extension UInt32: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> UInt32? {
        return unboxedNumber.uint32Value
    }

    public static func transform(unboxedString: String) -> UInt32? {
        return UInt32(unboxedString)
    }
}

/// Extension making UInt64 an Unboxable raw type
extension UInt64: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> UInt64? {
        return unboxedNumber.uint64Value
    }

    public static func transform(unboxedString: String) -> UInt64? {
        return UInt64(unboxedString)
    }
}

/// Extension making Double an Unboxable raw type
extension Double: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Double? {
        return unboxedNumber.doubleValue
    }

    public static func transform(unboxedString: String) -> Double? {
        return Double(unboxedString)
    }
}

/// Extension making Float an Unboxable raw type
extension Float: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Float? {
        return unboxedNumber.floatValue
    }

    public static func transform(unboxedString: String) -> Float? {
        return Float(unboxedString)
    }
}

/// Extension making Array an unboxable collection
extension Array: UnboxableCollection {
    public typealias UnboxRawCollection = [Any]
    public typealias UnboxValue = Element

    public static func unbox(collection: [Any], allowInvalidElements: Bool, transform: UnboxTransform<Element>?) throws -> Array? {
        return try collection.map(allowInvalidElements: allowInvalidElements) { element in
            if let transform = transform {
                return try transform(element)
            }

            if let elementType = Element.self as? UnboxCompatible.Type {
                guard let value = try elementType.unbox(value: element, allowInvalidCollectionElements: allowInvalidElements) else {
                    return nil
                }

                let unboxedElement = value as! Element
                return unboxedElement
            }

            if let elementType = Element.self as? Unboxable.Type {
                guard let dictionary = element as? UnboxableDictionary else {
                    return nil
                }

                let unboxer = Unboxer(dictionary: dictionary)
                let unboxedElement = try elementType.init(unboxer: unboxer) as! Element
                return unboxedElement
            }

            return nil
        }
    }
}

/// Extension making Dictionary an unboxable collection
extension Dictionary: UnboxableCollection {
    public typealias UnboxRawCollection = [String : Any]
    public typealias UnboxValue = Value

    public static func unbox(collection: [String : Any], allowInvalidElements: Bool, transform: UnboxTransform<Value>?) throws -> Dictionary? {
        return try collection.map(allowInvalidElements: allowInvalidElements) { key, value in
            let unboxedKey: Key

            if let keyType = Key.self as? UnboxableKey.Type {
                guard let transformedKey = keyType.transform(unboxedKey: key) else {
                    return nil
                }

                unboxedKey = transformedKey as! Key
            } else if Key.self is String.Type {
                unboxedKey = key as! Key
            } else {
                throw UnboxError.invalidDictionaryKeyType(Key.self)
            }

            let unboxedValue: Value

            if let transform = transform {
                guard let transformedValue = try transform(value) else {
                    return nil
                }

                unboxedValue = transformedValue
            } else if let matchingValue = value as? Value {
                unboxedValue = matchingValue
            } else if let valueType = Value.self as? UnboxCompatible.Type {
                guard let optionalUnboxedValue = try valueType.unbox(value: value, allowInvalidCollectionElements: allowInvalidElements) else {
                    return nil
                }

                unboxedValue = optionalUnboxedValue as! Value
            } else if let valueType = Value.self as? Unboxable.Type {
                guard let nestedDictionary = value as? UnboxableDictionary else {
                    return nil
                }

                let unboxer = Unboxer(dictionary: nestedDictionary)
                unboxedValue = try valueType.init(unboxer: unboxer) as! Value
            } else {
                throw UnboxError.invalidElementType(Value.self)
            }

            return (unboxedKey, unboxedValue)
        }
    }
}

#if !os(Linux)
    /// Extension making CGFloat an Unboxable raw type
    extension CGFloat: UnboxableByTransform {
        public typealias UnboxRawValue = Double

        public static func transform(unboxedValue: Double) -> CGFloat? {
            return CGFloat(unboxedValue)
        }
    }
#endif

/// Extension making String an Unboxable raw type
extension String: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> String? {
        return unboxedNumber.stringValue
    }

    public static func transform(unboxedString: String) -> String? {
        return unboxedString
    }
}

/// Extension making URL Unboxable by transform
extension URL: UnboxableByTransform {
    public typealias UnboxRawValue = String

    public static func transform(unboxedValue: String) -> URL? {
        return URL(string: unboxedValue)
    }
}

/// Extension making Decimal Unboxable by transform
extension Decimal: UnboxableByTransform {
    public typealias UnboxRawValue = String

    public static func transform(unboxedValue: String) -> Decimal? {
        return self.init(string: unboxedValue)
    }
}

/// Extension making String values usable as an Unboxable keys
extension String: UnboxableKey {
    public static func transform(unboxedKey: String) -> String? {
        return unboxedKey
    }
}

/// Extension making DateFormatter usable as a UnboxFormatter
extension DateFormatter: UnboxFormatter {
    public func format(unboxedValue: String) -> Date? {
        return self.date(from: unboxedValue)
    }
}
