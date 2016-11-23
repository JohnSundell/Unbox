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
    
/// Type alias defining what type of Dictionary that is Unboxable (valid JSON)
public typealias UnboxableDictionary = [String : Any]

// MARK: - Unbox functions

/// Unbox a JSON dictionary into a model `T`, optionally using a contextual object. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, context: Any? = nil) throws -> T {
    return try Unboxer(dictionary: dictionary, context: context).performUnboxing()
}

/// Unbox a JSON dictionary into a model `T` beginning at a provided key, optionally using a contextual object. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, at key: String, isKeyPath: Bool = true, context: Any? = nil) throws -> T {
    let containerContext = UnboxContainerContext(key: key, isKeyPath: isKeyPath, context: context)
    let container: UnboxContainer<T> = try Unbox(dictionary: dictionary, context: containerContext)
    return container.model
}

/// Unbox an array of JSON dictionaries into an array of `T`, optionally using a contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionaries: [UnboxableDictionary], context: Any? = nil, allowInvalidElements: Bool = false) throws -> [T] {
    return try dictionaries.map(allowInvalidElements: allowInvalidElements, transform: {
        try Unbox(dictionary: $0, context: context)
    })
}

/// Unbox an array JSON dictionary into an array of model `T` beginning at a provided key, optionally using a contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, at key: String, isKeyPath: Bool = true, context: Any? = nil) throws -> [T] {
    let containerContext = UnboxContainerContext(key: key, isKeyPath: isKeyPath, context: context)
    let container: UnboxArrayContainer<T> = try Unbox(dictionary: dictionary, context: containerContext)
    return container.models
}

/// Unbox binary data into a model `T`, optionally using a contextual object. Throws `UnboxError`.
public func Unbox<T: Unboxable>(data: Data, context: Any? = nil) throws -> T {
    return try Unboxer.unboxer(from: data, context: context).performUnboxing()
}

/// Unbox binary data into an array of `T`, optionally using a contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: Unboxable>(data: Data, context: Any? = nil, allowInvalidElements: Bool = false) throws -> [T] {
    return try Unboxer.unboxersFromData(data: data, context: context).map(allowInvalidElements: allowInvalidElements, transform: {
        return try $0.performUnboxing()
    })
}

/// Unbox a JSON dictionary into a model `T` using a required contextual object. Throws `UnboxError`.
public func Unbox<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.ContextType) throws -> T {
    return try Unboxer(dictionary: dictionary, context: context).performUnboxing(context: context)
}

/// Unbox an array of JSON dictionaries into an array of `T` using a required contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: UnboxableWithContext>(dictionaries: [UnboxableDictionary], context: T.ContextType, allowInvalidElements: Bool = false) throws -> [T] {
    return try dictionaries.map(allowInvalidElements: allowInvalidElements, transform: {
        try Unbox(dictionary: $0, context: context)
    })
}

/// Unbox binary data into a model `T` using a required contextual object. Throws `UnboxError`.
public func Unbox<T: UnboxableWithContext>(data: Data, context: T.ContextType) throws -> T {
    return try Unboxer.unboxer(from: data, context: context).performUnboxing(context: context)
}

/// Unbox binary data into an array of `T` using a required contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: UnboxableWithContext>(data: Data, context: T.ContextType, allowInvalidElements: Bool = false) throws -> [T] {
    return try Unboxer.unboxersFromData(data: data, context: context).map(allowInvalidElements: allowInvalidElements, transform: {
        return try $0.performUnboxing(context: context)
    })
}

// MARK: - Error type

/// Enum describing unboxing errors that were caused by invalid or missing values
public enum UnboxValueError: Error, CustomStringConvertible {
    public var description: String {
        switch self {
        case .MissingValueForKey(let key):
            return "Missing key (\(key))"
        case .InvalidValue(let key, let valueDescription):
            return "Invalid value (\(valueDescription)) for key (\(key))"
        }
    }
    
    /// Thrown when a required key/value was missing in an unboxed dictionary. Contains the missing key.
    case MissingValueForKey(String)
    /// Thrown when a required key contained an invalid value in an unboxed dictionary. Contains the invalid
    /// key and a description of the invalid data.
    case InvalidValue(String, String)
}

/// Enum describing errors that can occur during unboxing
public enum UnboxError: Error, CustomStringConvertible {
    public var description: String {
        let baseDescription = "[Unbox error] "
        
        switch self {
        case .InvalidValues(let errors):
            return baseDescription + "Invalid values were encountered. Errors: " + errors.map({"\($0)"}).joined(separator: ", ")
        case .InvalidData:
            return baseDescription + "Invalid Data"
        case .CustomUnboxingFailed:
            return baseDescription + "A custom unboxing closure returned nil"
        }
    }
    
    /// Thrown when one or many invalid values were encountered. Contains errors for each value. See UnboxValueError for more info.
    case InvalidValues([UnboxValueError])
    /// Thrown when a piece of data (Data) could not be unboxed because it was considered invalid
    case InvalidData
    /// Thrown when a custom unboxing closure returned nil
    case CustomUnboxingFailed
}

// MARK: - Protocols

/// Protocol used to declare a model as being Unboxable, for use with the Unbox() function
public protocol Unboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an Unboxer
    init(unboxer: Unboxer)
}

/// Protocol used to declare a model as being Unboxable with a certain context, for use with the Unbox(context:) function
public protocol UnboxableWithContext {
    /// The type of the contextual object that this model requires when unboxed
    associatedtype ContextType
    
    /// Initialize an instance of this model by unboxing a dictionary & using a context
    init(unboxer: Unboxer, context: ContextType)
}

/// Protocol that types that can be used in an unboxing process must conform to
public protocol UnboxCompatibleType {
    /// The value to use for required properties if unboxing failed. Typically a dummy value.
    static func unboxFallbackValue() -> Self
}

/// Protocol used to enable a raw type for Unboxing. See default implementations further down.
public protocol UnboxableRawType: UnboxCompatibleType {
    /// Transform an instance of this type from an unboxed integer
    static func transform(unboxedInt: Int) -> Self?
    /// Transform an instance of this type from an unboxed string
    static func transform(unboxedString: String) -> Self?
}

/// Protocol used to enable an enum to be directly unboxable
public protocol UnboxableEnum: RawRepresentable, UnboxCompatibleType {}

/// Protocol used to enable any type to be transformed from a JSON key into a dictionary key
public protocol UnboxableKey: Hashable, UnboxCompatibleType {
    /// Transform an unboxed key into a key that will be used in an unboxed dictionary
    static func transform(unboxedKey: String) -> Self?
}

/// Protocol used to enable any type as being unboxable, by transforming a raw value
public protocol UnboxableByTransform: UnboxCompatibleType {
    /// The type of raw value that this type can be transformed from. Must be a valid JSON type.
    associatedtype UnboxRawValueType
    
    /// Attempt to transform a raw unboxed value into an instance of this type
    static func transform(unboxedValue: UnboxRawValueType) -> Self?
}

/// Protocol used to enable any type as being unboxable with a certain formatter type
public protocol UnboxableWithFormatter: UnboxCompatibleType {
    /// The type of formatter to use to format an unboxed value into a value of this type
    associatedtype UnboxFormatterType: UnboxFormatter
}

/// Protocol used by objects that may format raw values into some other value
public protocol UnboxFormatter {
    /// The type of raw value that this formatter accepts as input
    associatedtype UnboxRawValueType: UnboxableRawType
    /// The type of value that this formatter produces as output
    associatedtype UnboxFormattedType
    
    /// Format an unboxed value into another value (or nil if the formatting failed)
    func format(unboxedValue: UnboxRawValueType) -> UnboxFormattedType?
}

// MARK: - Extensions

/// Extension making Bool an Unboxable raw type
extension Bool: UnboxableRawType {
    public static func unboxFallbackValue() -> Bool {
        return false
    }
    
    public static func transform(unboxedInt: Int) -> Bool? {
        return unboxedInt != 0
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
    public static func unboxFallbackValue() -> Int {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> Int? {
        return unboxedInt
    }
    
    public static func transform(unboxedString: String) -> Int? {
        return Int(unboxedString)
    }
}

/// Extension making UInt an Unboxable raw type
extension UInt: UnboxableRawType {
    public static func unboxFallbackValue() -> UInt {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> UInt? {
        return UInt(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> UInt? {
        return UInt(unboxedString)
    }
}

/// Extension making Int32 an Unboxable raw type
extension Int32: UnboxableRawType {
    public static func unboxFallbackValue() -> Int32 {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> Int32? {
        return Int32(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Int32? {
        return Int32(unboxedString)
    }
}

/// Extension making Int64 an Unboxable raw type
extension Int64: UnboxableRawType {
    public static func unboxFallbackValue() -> Int64 {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> Int64? {
        return Int64(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Int64? {
        return Int64(unboxedString)
    }
}

/// Extension making Double an Unboxable raw type
extension Double: UnboxableRawType {
    public static func unboxFallbackValue() -> Double {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> Double? {
        return Double(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Double? {
        return Double(unboxedString)
    }
}

/// Extension making Float an Unboxable raw type
extension Float: UnboxableRawType {
    public static func unboxFallbackValue() -> Float {
        return 0
    }
    
    public static func transform(unboxedInt: Int) -> Float? {
        return Float(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Float? {
        return Float(unboxedString)
    }
}

#if !os(Linux)
/// Extension making CGFloat an Unboxable raw type
extension CGFloat: UnboxableByTransform {
    public typealias UnboxRawValueType = Double
    
    public static func unboxFallbackValue() -> CGFloat {
        return 0
    }
    
    public static func transform(unboxedValue: Double) -> CGFloat? {
        return CGFloat(unboxedValue)
    }
}
#endif
    
/// Extension making String an Unboxable raw type
extension String: UnboxableRawType {
    public static func unboxFallbackValue() -> String {
        return ""
    }
    
    public static func transform(unboxedInt: Int) -> String? {
        return String(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> String? {
        return unboxedString
    }
}

/// Extension making URL Unboxable by transform
extension URL: UnboxableByTransform {
    public typealias UnboxRawValueType = String
    
    public static func transform(unboxedValue: String) -> URL? {
        return URL(string: unboxedValue)
    }
    
    public static func unboxFallbackValue() -> URL {
        return URL(string: "unbox.fallback")!
    }
}

/// Extension making String values usable as an Unboxable keys
extension String: UnboxableKey {
    public static func transform(unboxedKey: String) -> String? {
        return unboxedKey
    }
}

/// Extension making Date unboxable with an DateFormatter
extension Date: UnboxableWithFormatter {
    public typealias UnboxFormatterType = DateFormatter
    
    public static func unboxFallbackValue() -> Date {
        return self.init()
    }
}

/// Extension making DateFormatter usable as an UnboxFormatter
extension DateFormatter: UnboxFormatter {
    public func format(unboxedValue: String) -> Date? {
        return self.date(from: unboxedValue)
    }
}

/// Extension making ISO8601DateFormatter usable as an UnboxFormatter
extension ISO8601DateFormatter: UnboxFormatter {
    public func format(unboxedValue: String) -> Date? {
        return self.date(from: unboxedValue)
    }
}

// MARK: - Unboxer

/**
 *  Class used to Unbox (decode) values from a dictionary
 *
 *  For each supported type, simply call `unbox(string)` (where `string` is either a key or a key path in the dictionary
 *  that is being unboxed) - and the correct type will be returned. If a required (non-optional) value couldn't be
 *  unboxed, the Unboxer will be marked as failed, and a `nil` value will be returned from the `Unbox()` function that
 *  triggered the Unboxer.
 *
 *  An Unboxer may also be manually failed, by using the `failForKey()` or `failForInvalidValue(forKey:)` APIs.
 */
public class Unboxer {
    /// The underlying JSON dictionary that is being unboxed
    public let dictionary: UnboxableDictionary
    /// Whether the Unboxer has failed, and a `nil` value will be returned from the `Unbox()` function that triggered it.
    public var hasFailed: Bool { return !self.failureInfo.isEmpty }
    /// Any contextual object that was supplied when unboxing was started
    public let context: Any?
    
    fileprivate var failureInfo = [(key: String, value: Any?)]()
    
    // MARK: - Private initializer
    
    fileprivate init(dictionary: UnboxableDictionary, context: Any?) {
        self.dictionary = dictionary
        self.context = context
    }
    
    // MARK: - Custom unboxing API
    
    /// Perform custom unboxing using an Unboxer (created from a dictionary) passed to a closure, or throw an UnboxError
    public static func performCustomUnboxing<T>(dictionary: UnboxableDictionary, context: Any? = nil, closure: (Unboxer) throws -> T?) throws -> T {
        return try Unboxer(dictionary: dictionary, context: context).performCustomUnboxing(closure: closure)
    }
    
    /// Perform custom unboxing on an array of dictionaries, executing a closure with a new Unboxer for each one, or throw an UnboxError
    public static func performCustomUnboxing<T>(array: [UnboxableDictionary], context: Any? = nil, allowInvalidElements: Bool = false, closure: (Unboxer) throws -> T?) throws -> [T] {
        
        if allowInvalidElements {
            return array.flatMap { (dictionary) -> T? in
                return try? self.performCustomUnboxing(dictionary: dictionary, context: context, closure: closure)
            }
        } else {
            return try array.map { (dictionary) -> T in
                return try self.performCustomUnboxing(dictionary: dictionary, context: context, closure: closure)
            }
        }
    }
    
    /// Perform custom unboxing using an Unboxer (created from NSData) passed to a closure, or throw an UnboxError
    public static func performCustomUnboxing<T>(data: Data, context: Any? = nil, closure: (Unboxer) throws -> T?) throws -> T {
        return try Unboxer.unboxer(from: data, context: context).performCustomUnboxing(closure: closure)
    }
    
    // MARK: - Value accessing API
    
    /// Unbox a required raw type
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> T {
        if let rawValue = UnboxValueResolver<T>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath) {
            return rawValue
        }
        
        let transformedString = UnboxValueResolver<String>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return T.transform(unboxedString: $0)
        })
        
        if let transformedString = transformedString {
            return transformedString
        }
        
        return UnboxValueResolver<Int>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            return T.transform(unboxedInt: $0)
        })
    }
    
    /// Unbox an optional raw type
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> T? {
        if let rawValue = UnboxValueResolver<T>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath) {
            return rawValue
        }
        
        let transformedString = UnboxValueResolver<String>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return T.transform(unboxedString: $0)
        })
        
        if let transformedString = transformedString {
            return transformedString
        }
        
        return UnboxValueResolver<Int>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return T.transform(unboxedInt: $0)
        })
    }
    
    /// Unbox a required Array containing values of a raw type
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> [T] {
        if let rawValueArray = UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath) {
            return rawValueArray
        }
        
        let transformedStringArray = UnboxValueResolver<[String]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: { stringArray -> [T]? in
            var transformedStringArray = [T]()
            for string in stringArray {
                guard let transformedUnboxedString = T.transform(unboxedString: string) else { return nil }
                transformedStringArray.append(transformedUnboxedString)
            }
            return transformedStringArray
        })
        
        if let transformedStringArray = transformedStringArray {
            return transformedStringArray
        }
        
        return UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [])
    }
    
    /// Unbox an optional Array containing values of a raw type
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> [T]? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox a required Array of collections
    public func unbox<T: Collection>(key: String, isKeyPath: Bool = true) -> [T] {
        return UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [])
    }
    
    /// Unbox an optional Array of collections
    public func unbox<T: Collection>(key: String, isKeyPath: Bool = true) -> [T]? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath)
    }

    /// Unbox a required Array of values that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [T] {
        let transform = T.makeArrayTransformClosure(allowInvalidElements: allowInvalidElements)
        return UnboxValueResolver<[T.UnboxRawValueType]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [], transform: transform)
    }

    /// Unbox an optional Array of values that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [T]? {
        let transform = T.makeArrayTransformClosure(allowInvalidElements: allowInvalidElements)
        return UnboxValueResolver<[T.UnboxRawValueType]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: transform)
    }
    
    /// Unbox a required raw value from a certain index in a nested Array
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true, index: Int) -> T {
        return UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            if index < 0 || index >= $0.count {
                return nil
            }
            
            return $0[index]
        })
    }
    
    /// Unbox an optional raw value from a certain index in a nested Array
    public func unbox<T: UnboxableRawType>(key: String, isKeyPath: Bool = true, index: Int) -> T? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            if index < 0 || index >= $0.count {
                return nil
            }
            
            return $0[index]
        })
    }
    
    /// Unbox a required Dictionary with values of multiple/unknown types
    public func unbox(key: String, isKeyPath: Bool = true) -> UnboxableDictionary {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: UnboxableDictionary())
    }
    
    /// Unbox an optional Dictionary with values of multiple/unknown types
    public func unbox(key: String, isKeyPath: Bool = true) -> UnboxableDictionary? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox a required Dictionary with values of a single type
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> [K : V] {
        return UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: false, valueTransform: { $0 }) ?? [:]
    }
    
    /// Unbox an optional Dictionary with values of a single type
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> [K : V]? {
        return UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: false, valueTransform: { $0 })
    }
    
    /// Unbox a required Dictionary containing dictionaries
    public func unbox<K: UnboxableKey, V>(key: String, isKeyPath: Bool = true) -> [K : V] where V: Collection, V: ExpressibleByDictionaryLiteral, V.Key: Hashable, V.Iterator == DictionaryIterator<V.Key, V.Value> {
        return UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: false, valueTransform: { $0 }) ?? [:]
    }

    /// Unbox an optional Dictionary containing dictionaries
    public func unbox<K: UnboxableKey, V>(key: String, isKeyPath: Bool = true) -> [K : V]? where V: Collection, V: ExpressibleByDictionaryLiteral, V.Key: Hashable, V.Iterator == DictionaryIterator<V.Key, V.Value> {
        return UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: false, valueTransform: { $0 })
    }
    
    /// Unbox a required Dictionary containing array of simple values
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]] {
        return UnboxValueResolver<[String: [V]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements) {
            return $0
        } ?? [K: [V]]()
    }
    
    /// Unbox an optional Dictionary containing array of simple values
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]]? {
        return UnboxValueResolver<[String: [V]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements) {
            return $0
        }
    }
    
    /// Unbox a required Dictionary containing array of Unboxables
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]] {
        return UnboxValueResolver<[String: [UnboxableDictionary]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements) {
            return try? Unbox(dictionaries: $0, context: self.context, allowInvalidElements: allowInvalidElements)
        } ?? [K: [V]]()
    }

    /// Unbox an optional Dictionary containing array of Unboxables
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]]? {
        return UnboxValueResolver<[String: [UnboxableDictionary]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements) {
            return try? Unbox(dictionaries: $0, context: self.context, allowInvalidElements: allowInvalidElements)
        }
    }
    
    /// Unbox a required enum value
    public func unbox<T: UnboxableEnum>(key: String, isKeyPath: Bool = true) -> T {
        return UnboxValueResolver<T.RawValue>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox an optional enum value
    public func unbox<T: UnboxableEnum>(key: String, isKeyPath: Bool = true) -> T? {
        return UnboxValueResolver<T.RawValue>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox a required Array of enum raw values to an Array of enums using a transform
    public func unbox<T: UnboxableEnum>(key: String, isKeyPath: Bool = true) -> [T] {
        return UnboxValueResolver<[T.RawValue]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [], transform: { (array) -> [T]? in
            return array.flatMap({ T(rawValue: $0) })
        })
    }
    
    /// Unbox an optional Array of enum raw values to an Array of enums using a transform
    public func unbox<T: UnboxableEnum>(key: String, isKeyPath: Bool = true) -> [T]? {
        return UnboxValueResolver<[T.RawValue]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: { (array) -> [T]? in
            return array.flatMap({ T(rawValue: $0) })
        })
    }
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            return try? Unbox(dictionary: $0, context: context ?? self.context)
        })
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionary: $0, context: context ?? self.context)
        })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil, allowInvalidElements: Bool = false) -> [T] {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [], transform: {
            return try? Unbox(dictionaries: $0, context: context ?? self.context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil, allowInvalidElements: Bool = false) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, context: context ?? self.context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : V] {
        return UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements, valueTransform: {
            return try? Unbox(dictionary: $0, context: self.context)
        }) ?? [:]
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : V]? {
        return UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements, valueTransform: {
            return try? Unbox(dictionary: $0, context: self.context)
        })
    }
    
    /// Unbox a required nested UnboxableWithContext type
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValueWithContext(context: context), transform: {
            return try? Unbox(dictionary: $0, context: context)
        })
    }
    
    /// Unbox an optional nested UnboxableWithContext type
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionary: $0, context: context)
        })
    }
    
    /// Unbox a required Array of nested UnboxableWithContext types, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType, allowInvalidElements: Bool = false) -> [T] {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [], transform: {
            return try? Unbox(dictionaries: $0, context: context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox an optional Array of nested UnboxableWithContext types, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType, allowInvalidElements: Bool = false) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, context: context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox a required value that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String, isKeyPath: Bool = true) -> T {
        return UnboxValueResolver<T.UnboxRawValueType>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            return T.transform(unboxedValue: $0)
        })
    }
    
    /// Unbox an optional value that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String, isKeyPath: Bool = true) -> T? {
        return UnboxValueResolver<T.UnboxRawValueType>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return T.transform(unboxedValue: $0)
        })
    }
    
    /// Unbox a required value that can be formatted using a formatter
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F) -> T where F.UnboxFormattedType == T {
        return UnboxValueResolver<F.UnboxRawValueType>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: T.unboxFallbackValue(), transform: {
            return formatter.format(unboxedValue: $0)
        })
    }
    
    /// Unbox an optional value that can be formatted using a formatter
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F) -> T? where F.UnboxFormattedType == T {
        return UnboxValueResolver<F.UnboxRawValueType>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return formatter.format(unboxedValue: $0)
        })
    }
    
    /// Unbox a required Array containing values that can be formatted using a formatter (optionally allowing invalid elements)
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F, allowInvalidElements: Bool = false) -> [T] where F.UnboxFormattedType == T {
        return UnboxValueResolver<[F.UnboxRawValueType]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: [], transform: { (array) -> [T]? in
            if allowInvalidElements {
                return array.flatMap({ formatter.format(unboxedValue: $0) })
            } else {
                return array.map({ (value) -> T in
                    if let formattedValue = formatter.format(unboxedValue: value) {
                        return formattedValue
                    }
                    
                    self.failForInvalidValue(invalidValue: value, forKey: key)
                    return T.unboxFallbackValue()
                })
            }
        })
    }
    
    /// Unbox an optional Array containing values that can be formatted using a formatter (optionally allowing invalid elements)
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F, allowInvalidElements: Bool = false) -> [T]? where F.UnboxFormattedType == T {
        return UnboxValueResolver<[F.UnboxRawValueType]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: { (array) -> [T]? in
            if allowInvalidElements {
                return array.flatMap({ formatter.format(unboxedValue: $0) })
            } else {
                var formattedArray = [T]()
                
                for value in array {
                    guard let formattedValue = formatter.format(unboxedValue: value) else {
                        return nil
                    }
                    
                    formattedArray.append(formattedValue)
                }
                
                return formattedArray
            }
        })
    }
    
    /// Make this Unboxer fail for a certain key. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForKey(key: String) {
        self.failForInvalidValue(invalidValue: nil, forKey: key)
    }
    
    /// Make this Unboxer fail for a certain key and invalid value. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForInvalidValue(invalidValue: Any?, forKey key: String) {
        self.failureInfo.append((key, invalidValue))
    }
}

// MARK: - UnboxValueResolver

private class UnboxValueResolver<T> {
    let unboxer: Unboxer
    
    init(_ unboxer: Unboxer) {
        self.unboxer = unboxer
    }
    
    func resolveRequiredValueForKey(key: String, isKeyPath: Bool, fallbackValue: @autoclosure () -> T) -> T {
        return self.resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, fallbackValue: fallbackValue, transform: {
            return $0
        })
    }
    
    func resolveRequiredValueForKey<R>(key: String, isKeyPath: Bool, fallbackValue: @autoclosure () -> R, transform: (T) -> R?) -> R {
        if let value = self.resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: transform) {
            return value
        }
        
        self.unboxer.failForInvalidValue(invalidValue: self.unboxer.dictionary[key], forKey: key)
        
        return fallbackValue()
    }
    
    func resolveOptionalValueForKey(key: String, isKeyPath: Bool) -> T? {
        return self.resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return $0
        })
    }
    
    func resolveOptionalValueForKey<R>(key: String, isKeyPath: Bool, transform: (T) -> R?) -> R? {
        var dictionary = self.unboxer.dictionary
        var array: [AnyObject]?
        var modifiedKey = key
        
        if isKeyPath && key.contains(".") {
            let components = key.components(separatedBy: ".")
            for i in 0 ..< components.count {
                let keyPathComponent = components[i]
                
                if i == components.count - 1 {
                    modifiedKey = keyPathComponent
                } else if let nestedDictionary = dictionary[keyPathComponent] as? UnboxableDictionary {
                    dictionary = nestedDictionary
                } else if let nestedArray = dictionary[keyPathComponent] as? [AnyObject] {
                    array = nestedArray
                } else if let array = array, let index = Int(keyPathComponent), index < array.count, let nestedDictionary = array[index] as? UnboxableDictionary {
                    dictionary = nestedDictionary
                } else {
                    return nil
                }
            }
        }
        
        if let value = dictionary[modifiedKey] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        } else if let index = Int(modifiedKey), let array = array, index < array.count, let value = array[index] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}

extension UnboxValueResolver where T: Collection, T: ExpressibleByDictionaryLiteral, T.Key == String, T.Iterator == DictionaryIterator<T.Key, T.Value> {
    func resolveDictionaryValuesForKey<K: UnboxableKey, V>(key: String, isKeyPath: Bool, required: Bool, allowInvalidElements: Bool, valueTransform: (T.Value) -> V?) -> [K : V]? {
        if let unboxedDictionary = self.resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath) {
            var transformedDictionary = [K : V]()
            
            for (unboxedKey, unboxedValue) in unboxedDictionary {
                let transformedKey = K.transform(unboxedKey: unboxedKey)
                let transformedValue = valueTransform(unboxedValue)
                
                if let transformedKey = transformedKey {
                    if let transformedValue = transformedValue {
                        transformedDictionary[transformedKey] = transformedValue
                        continue
                    } else if allowInvalidElements {
                        continue
                    }
                }
                
                if required {
                    self.unboxer.failForInvalidValue(invalidValue: unboxedDictionary, forKey: key)
                }
                
                return nil
            }
            
            return transformedDictionary
        } else if required {
            self.unboxer.failForInvalidValue(invalidValue: self.unboxer.dictionary[key], forKey: key)
        }
        
        return nil
    }
}

// MARK: - UnboxContainerContext

private struct UnboxContainerContext {
    let key: String
    let isKeyPath: Bool
    let context: Any?
}

private struct UnboxContainer<T: Unboxable>: UnboxableWithContext {
    let model: T
    
    init(unboxer: Unboxer, context: UnboxContainerContext) {
        self.model = unboxer.unbox(key: context.key, isKeyPath: context.isKeyPath, context: context.context)
    }
}

private struct UnboxArrayContainer<T: Unboxable>: UnboxableWithContext {
    let models: [T]
    
    init(unboxer: Unboxer, context: UnboxContainerContext) {
        self.models = unboxer.unbox(key: context.key, isKeyPath: context.isKeyPath)
    }
}

// MARK: - Private extensions

private extension Unboxable {
    static func unboxFallbackValue() -> Self {
        return self.init(unboxer: Unboxer(dictionary: [:], context: nil))
    }
}

private extension UnboxableWithContext {
    static func unboxFallbackValueWithContext(context: ContextType) -> Self {
        return self.init(unboxer: Unboxer(dictionary: [:], context: context), context: context)
    }
}

private extension UnboxableByTransform {
    static func makeArrayTransformClosure(allowInvalidElements: Bool) -> ([UnboxRawValueType]) -> [Self]? {
        return {
            if allowInvalidElements {
                return $0.flatMap { Self.transform(unboxedValue: $0) }
            }
            
            var transformedValues = [Self]()
            
            for rawValue in $0 {
                guard let transformedvalue = Self.transform(unboxedValue: rawValue) else {
                    return nil
                }
                
                transformedValues.append(transformedvalue)
            }
            
            return transformedValues
        }
    }
}

private extension Unboxer {
    static func unboxer(from data: Data, context: Any?) throws -> Unboxer {
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? UnboxableDictionary else {
                throw UnboxError.InvalidData
            }
            
            return Unboxer(dictionary: dictionary, context: context)
        } catch {
            throw UnboxError.InvalidData
        }
    }
    
    static func unboxersFromData(data: Data, context: Any?) throws -> [Unboxer] {
        do {
            guard let array = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [UnboxableDictionary] else {
                throw UnboxError.InvalidData
            }
            
            return array.map {
                return Unboxer(dictionary: $0, context: context)
            }
        } catch {
            throw UnboxError.InvalidData
        }
    }
    
    func performUnboxing<T: Unboxable>() throws -> T {
        let unboxed = T(unboxer: self)
        try self.throwIfFailed()
        return unboxed
    }
    
    func performUnboxing<T: UnboxableWithContext>(context: T.ContextType) throws -> T {
        let unboxed = T(unboxer: self, context: context)
        try self.throwIfFailed()
        return unboxed
    }
    
    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        guard let unboxed: T = try closure(self) else {
            throw UnboxError.CustomUnboxingFailed
        }
        
        try self.throwIfFailed()
        
        return unboxed
    }
    
    func throwIfFailed() throws {
        guard !self.failureInfo.isEmpty else {
            return
        }
        
        var inputErrors = [UnboxValueError]()
        
        for failure in self.failureInfo {
            if let failedValue: Any = failure.value {
                inputErrors.append(.InvalidValue(failure.key, "\(failedValue)"))
            }
            else {
                inputErrors.append(.MissingValueForKey(failure.key))
            }
        }
        
        throw UnboxError.InvalidValues(inputErrors)
    }
}

private extension Array {
    func map<T>(allowInvalidElements: Bool, transform: (Element) throws -> T) throws -> [T] {
        var transformedArray = [T]()
        
        for element in self {
            do {
                let transformed = try transform(element)
                transformedArray.append(transformed)
            } catch {
                if !allowInvalidElements {
                    throw error
                }
            }
        }
        
        return transformedArray
    }
}
