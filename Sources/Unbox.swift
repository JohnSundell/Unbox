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

/// Unbox a JSON dictionary into a model `T`. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary) throws -> T {
    return try Unboxer(dictionary: dictionary).performUnboxing()
}

/// Unbox a JSON dictionary into a model `T` beginning at a provided key. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, at key: String, isKeyPath: Bool = true) throws -> T {
    let containerContext = UnboxContainerContext(key: key, isKeyPath: isKeyPath)
    let container: UnboxContainer<T> = try Unbox(dictionary: dictionary, context: containerContext)
    return container.model
}

/// Unbox an array of JSON dictionaries into an array of `T`, optionally allowing invalid elements. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionaries: [UnboxableDictionary], allowInvalidElements: Bool = false) throws -> [T] {
    return try dictionaries.map(allowInvalidElements: allowInvalidElements, transform: Unbox)
}

/// Unbox an array JSON dictionary into an array of model `T` beginning at a provided key, optionally using a contextual object and/or invalid elements. Throws `UnboxError`.
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, at key: String, isKeyPath: Bool = true, context: Any? = nil) throws -> [T] {
    let containerContext = UnboxContainerContext(key: key, isKeyPath: isKeyPath)
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
    return try Unboxer(dictionary: dictionary).performUnboxing(context: context)
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

/// Enum describing errors that can occur during unboxing
public enum UnboxError: Error {
    /// Thrown when an invalid required value was encountered. Contains the value and the key.
    case invalidValue(Any, String)
    /// Thrown when a required value was missing. Contains the key.
    case missingValue(String)
    /// Thrown when an empty key path was supplied
    case emptyKeyPath
    /// Thrown when a piece of data (Data) could not be unboxed because it was considered invalid
    case invalidData
    /// Thrown when a custom unboxing closure returned nil
    case customUnboxingFailed
}

extension UnboxError: CustomStringConvertible {
    public var description: String {
        let baseDescription = "[Unbox error] "
        
        switch self {
        case .invalidValue(let value, let key):
            return baseDescription + "Invalid value found (\(value)) for key \"\(key)\""
        case .missingValue(let key):
            return baseDescription + "Missing value for key \"\(key)\""
        case .emptyKeyPath:
            return baseDescription + "Empty key path"
        case .invalidData:
            return baseDescription + "Invalid Data"
        case .customUnboxingFailed:
            return baseDescription + "A custom unboxing closure returned nil"
        }
    }
}

// MARK: - Protocols

/// Protocol used to declare a model as being Unboxable, for use with the Unbox() function
public protocol Unboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an Unboxer
    init(unboxer: Unboxer) throws
}

/// Protocol used to declare a model as being Unboxable with a certain context, for use with the Unbox(context:) function
public protocol UnboxableWithContext {
    /// The type of the contextual object that this model requires when unboxed
    associatedtype ContextType
    
    /// Initialize an instance of this model by unboxing a dictionary & using a context
    init(unboxer: Unboxer, context: ContextType) throws
}

/// Protocol that types that can be used in an unboxing process must conform to
public protocol UnboxCompatibleType {
    /// Unbox a value, or either throw or return nil if unboxing couldn't be performed
    static func unbox(value: Any) throws -> Self?
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
public protocol UnboxableKey: Hashable {
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
public protocol UnboxableWithFormatter {
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

// MARK: - Default protocol implementations

public extension UnboxableRawType {
    static func unbox(value: Any) throws -> Self? {
        if let matchedValue = value as? Self {
            return matchedValue
        }
        
        if let string = value as? String {
            return self.transform(unboxedString: string)
        }

        if let int = value as? Int {
            return self.transform(unboxedInt: int)
        }

        return nil
    }
}

public extension UnboxableByTransform {
    static func unbox(value: Any) throws -> Self? {
        guard let rawValue = value as? UnboxRawValueType else {
            return nil
        }
        
        return self.transform(unboxedValue: rawValue)
    }
}

public extension UnboxableEnum {
    static func unbox(value: Any) throws -> Self? {
        guard let rawValue = value as? RawValue else {
            return nil
        }
        
        return self.init(rawValue: rawValue)
    }
}

// MARK: - Extensions

/// Extension making Bool an Unboxable raw type
extension Bool: UnboxableRawType {
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
    public static func transform(unboxedInt: Int) -> Int? {
        return unboxedInt
    }
    
    public static func transform(unboxedString: String) -> Int? {
        return Int(unboxedString)
    }
}

/// Extension making UInt an Unboxable raw type
extension UInt: UnboxableRawType {
    public static func transform(unboxedInt: Int) -> UInt? {
        return UInt(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> UInt? {
        return UInt(unboxedString)
    }
}

/// Extension making Int32 an Unboxable raw type
extension Int32: UnboxableRawType {
    public static func transform(unboxedInt: Int) -> Int32? {
        return Int32(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Int32? {
        return Int32(unboxedString)
    }
}

/// Extension making Int64 an Unboxable raw type
extension Int64: UnboxableRawType {
    public static func transform(unboxedInt: Int) -> Int64? {
        return Int64(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Int64? {
        return Int64(unboxedString)
    }
}

/// Extension making Double an Unboxable raw type
extension Double: UnboxableRawType {
    public static func transform(unboxedInt: Int) -> Double? {
        return Double(unboxedInt)
    }
    
    public static func transform(unboxedString: String) -> Double? {
        return Double(unboxedString)
    }
}

/// Extension making Float an Unboxable raw type
extension Float: UnboxableRawType {
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
    
    public static func transform(unboxedValue: Double) -> CGFloat? {
        return CGFloat(unboxedValue)
    }
}
#endif
    
/// Extension making String an Unboxable raw type
extension String: UnboxableRawType {
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
}

/// Extension making DateFormatter usable as a UnboxFormatter
extension DateFormatter: UnboxFormatter {
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
 */
public class Unboxer {
    /// The underlying JSON dictionary that is being unboxed
    public let dictionary: UnboxableDictionary
    
    // MARK: - Private initializer
    
    fileprivate init(dictionary: UnboxableDictionary) {
        self.dictionary = dictionary
    }
    
    // MARK: - Custom unboxing API
    
    /// Perform custom unboxing using an Unboxer (created from a dictionary) passed to a closure, or throw an UnboxError
    public static func performCustomUnboxing<T>(dictionary: UnboxableDictionary, context: Any? = nil, closure: (Unboxer) throws -> T?) throws -> T {
        return try Unboxer(dictionary: dictionary).performCustomUnboxing(closure: closure)
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
    
    /// Unbox a required value by key
    public func unbox<T: UnboxCompatibleType>(key: String) throws -> T {
        return try UnboxValueResolver<Any>(self).resolveValue(forPath: .key(key), transform: T.unbox)
    }
    
    /// Unbox a required value by key path
    public func unbox<T: UnboxCompatibleType>(keyPath: String) throws -> T {
        return try UnboxValueResolver<Any>(self).resolveValue(forPath: .keyPath(keyPath), transform: T.unbox)
    }
    
    /// Unbox an optional value by key
    public func unbox<T: UnboxCompatibleType>(key: String) -> T? {
        return try? self.unbox(key: key)
    }
    
    /// Unbox an optional value by key path
    public func unbox<T: UnboxCompatibleType>(keyPath: String) -> T? {
        return try? self.unbox(keyPath: keyPath)
    }
    
    /// Unbox a required array by key
    public func unbox<T: UnboxCompatibleType>(key: String, allowInvalidElements: Bool = false) throws -> [T] {
        let transform = T.makeArrayTransformClosure(allowInvalidElements: allowInvalidElements)
        return try UnboxValueResolver<[Any]>(self).resolveValue(forPath: .key(key), transform: transform)
    }
    
    /// Unbox a required array by key path
    public func unbox<T: UnboxCompatibleType>(keyPath: String, allowInvalidElements: Bool = false) throws -> [T] {
        let transform = T.makeArrayTransformClosure(allowInvalidElements: allowInvalidElements)
        return try UnboxValueResolver<[Any]>(self).resolveValue(forPath: .keyPath(keyPath), transform: transform)
    }
    
    /// Unbox an optional array by key
    public func unbox<T: UnboxCompatibleType>(key: String, allowInvalidElements: Bool = false) -> [T]? {
        return try? self.unbox(key: key, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox an optional array by key path
    public func unbox<T: UnboxCompatibleType>(keyPath: String, allowInvalidElements: Bool = false) -> [T]? {
        return try? self.unbox(keyPath: keyPath, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox a required Array of collections
    public func unbox<T: Collection>(key: String, isKeyPath: Bool = true) throws -> [T] {
        return try UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox an optional Array of collections
    public func unbox<T: Collection>(key: String, isKeyPath: Bool = true) -> [T]? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox a required Dictionary with values of multiple/unknown types
    public func unbox(key: String, isKeyPath: Bool = true) throws -> UnboxableDictionary {
        return try UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox an optional Dictionary with values of multiple/unknown types
    public func unbox(key: String, isKeyPath: Bool = true) -> UnboxableDictionary? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath)
    }
    
    /// Unbox a required Dictionary with values of a single type
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true) throws -> [K : V] {
        return try UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: false, valueTransform: { $0 })
    }
    
    /// Unbox an optional Dictionary with values of a single type
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true) -> [K : V]? {
        return try? UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: false, valueTransform: { $0 })
    }
    
    /// Unbox a required Dictionary containing dictionaries
    public func unbox<K: UnboxableKey, V>(key: String, isKeyPath: Bool = true) throws -> [K : V] where V: Collection, V: ExpressibleByDictionaryLiteral, V.Key: Hashable, V.Iterator == DictionaryIterator<V.Key, V.Value> {
        return try UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: false, valueTransform: { $0 })
    }

    /// Unbox an optional Dictionary containing dictionaries
    public func unbox<K: UnboxableKey, V>(key: String, isKeyPath: Bool = true) -> [K : V]? where V: Collection, V: ExpressibleByDictionaryLiteral, V.Key: Hashable, V.Iterator == DictionaryIterator<V.Key, V.Value> {
        return try? UnboxValueResolver<[String : V]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: false, valueTransform: { $0 })
    }
    
    /// Unbox a required Dictionary containing array of simple values
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) throws -> [K : [V]] {
        return try UnboxValueResolver<[String: [V]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements) {
            return $0
        }
    }
    
    /// Unbox an optional Dictionary containing array of simple values
    public func unbox<K: UnboxableKey, V: UnboxableRawType>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]]? {
        return try? UnboxValueResolver<[String: [V]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements) {
            return $0
        }
    }
    
    /// Unbox a required Dictionary containing array of Unboxables
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) throws -> [K : [V]] {
        return try UnboxValueResolver<[String: [UnboxableDictionary]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements) {
            return try? Unbox(dictionaries: $0, allowInvalidElements: allowInvalidElements)
        }
    }

    /// Unbox an optional Dictionary containing array of Unboxables
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : [V]]? {
        return try? UnboxValueResolver<[String: [UnboxableDictionary]]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements) {
            return try? Unbox(dictionaries: $0, allowInvalidElements: allowInvalidElements)
        }
    }
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil) throws -> T {
        return try UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionary: $0)
        })
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionary: $0)
        })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil, allowInvalidElements: Bool = false) throws -> [T] {
        return try UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: Unboxable>(key: String, isKeyPath: Bool = true, context: Any? = nil, allowInvalidElements: Bool = false) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) throws -> [K : V] {
        return try UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: true, allowInvalidElements: allowInvalidElements, valueTransform: {
            return try? Unbox(dictionary: $0)
        })
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<K: UnboxableKey, V: Unboxable>(key: String, isKeyPath: Bool = true, allowInvalidElements: Bool = false) -> [K : V]? {
        return try? UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key: key, isKeyPath: isKeyPath, required: false, allowInvalidElements: allowInvalidElements, valueTransform: {
            return try? Unbox(dictionary: $0)
        })
    }
    
    /// Unbox a required nested UnboxableWithContext type
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType) throws -> T {
        return try UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
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
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType, allowInvalidElements: Bool = false) throws -> [T] {
        return try UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, context: context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox an optional Array of nested UnboxableWithContext types, by unboxing an Array of Dictionaries and then using a transform (optionally allowing invalid elements)
    public func unbox<T: UnboxableWithContext>(key: String, isKeyPath: Bool = true, context: T.ContextType, allowInvalidElements: Bool = false) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return try? Unbox(dictionaries: $0, context: context, allowInvalidElements: allowInvalidElements)
        })
    }
    
    /// Unbox a required value that can be formatted using a formatter
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F) throws -> T where F.UnboxFormattedType == T {
        return try UnboxValueResolver<F.UnboxRawValueType>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
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
    public func unbox<T: UnboxableWithFormatter, F: UnboxFormatter>(key: String, isKeyPath: Bool = true, formatter: F, allowInvalidElements: Bool = false) throws -> [T] where F.UnboxFormattedType == T {
        return try UnboxValueResolver<[F.UnboxRawValueType]>(self).resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: { array in
            if allowInvalidElements {
                return array.flatMap {
                    formatter.format(unboxedValue: $0)
                }
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
}

// MARK: - UnboxPath

private enum UnboxPath {
    case key(String)
    case keyPath(String)
}

extension UnboxPath {
    var components: [String] {
        switch self {
        case .key(let key):
            return [key]
        case .keyPath(let keyPath):
            return keyPath.components(separatedBy: ".")
        }
    }
}

// MARK: - UnboxingMode

private enum UnboxingMode {
    case dictionary(UnboxableDictionary)
    case array([Any])
    case value(Any)
}

extension UnboxingMode {
    var value: Any {
        switch self {
        case .dictionary(let dictionary):
            return dictionary
        case .array(let array):
            return array
        case .value(let value):
            return value
        }
    }
    
    init(value: Any) {
        if let dictionary = value as? UnboxableDictionary {
            self = .dictionary(dictionary)
        } else if let array = value as? [Any] {
            self = .array(array)
        } else {
            self = .value(value)
        }
    }
}

// MARK: - UnboxValueResolver

private class UnboxValueResolver<T> {
    let unboxer: Unboxer
    
    init(_ unboxer: Unboxer) {
        self.unboxer = unboxer
    }
    
    func resolveValue<R>(forPath path: UnboxPath, transform: (T) throws -> R?) throws -> R {
        var currentMode = UnboxingMode.dictionary(self.unboxer.dictionary)
        let components = path.components
        
        guard let lastKey = components.last else {
            throw UnboxError.emptyKeyPath
        }
        
        for key in components {
            switch currentMode {
            case .dictionary(let dictionary):
                guard let value = dictionary[key] else {
                    throw UnboxError.missingValue(key)
                }
                
                currentMode = UnboxingMode(value: value)
            case .array(let array):
                guard let index = Int(key), index < array.count else {
                    throw UnboxError.missingValue(key)
                }
                
                currentMode = UnboxingMode(value: array[index])
            case .value(let value):
                throw UnboxError.invalidValue(value, key)
            }
        }
        
        guard let rawValue = currentMode.value as? T else {
            throw UnboxError.invalidValue(currentMode.value, lastKey)
        }
        
        guard let value = try transform(rawValue) else {
            throw UnboxError.invalidValue(rawValue, lastKey)
        }
        
        return value
    }
    
    func resolveRequiredValueForKey(key: String, isKeyPath: Bool) throws -> T {
        return try self.resolveRequiredValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return $0
        })
    }
    
    func resolveRequiredValueForKey<R>(key: String, isKeyPath: Bool, transform: (T) throws -> R?) throws -> R {
        if let value = self.resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: transform) {
            return value
        }
        
        if self.unboxer.dictionary[key] == nil {
            throw UnboxError.missingValue(key)
        }
        
        throw UnboxError.invalidValue(self.unboxer.dictionary[key], key)
    }
    
    func resolveOptionalValueForKey(key: String, isKeyPath: Bool) -> T? {
        return self.resolveOptionalValueForKey(key: key, isKeyPath: isKeyPath, transform: {
            return $0
        })
    }
    
    func resolveOptionalValueForKey<R>(key: String, isKeyPath: Bool, transform: (T) throws -> R?) -> R? {
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
            if let transformed = try? transform(value) {
                return transformed
            }
        } else if let index = Int(modifiedKey), let array = array, index < array.count, let value = array[index] as? T {
            if let transformed = try? transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}

extension UnboxValueResolver where T: Collection, T: ExpressibleByDictionaryLiteral, T.Key == String, T.Iterator == DictionaryIterator<T.Key, T.Value> {
    func resolveDictionaryValuesForKey<K: UnboxableKey, V>(key: String, isKeyPath: Bool, required: Bool, allowInvalidElements: Bool, valueTransform: (T.Value) -> V?) throws -> [K : V] {
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
                
                throw UnboxError.invalidValue(unboxedDictionary, key)
            }
            
            return transformedDictionary
        }
        
        if let invalidValue = self.unboxer.dictionary[key] {
            throw UnboxError.invalidValue(invalidValue, key)
        }
        
        throw UnboxError.missingValue(key)
    }
}

// MARK: - UnboxContainerContext

private struct UnboxContainerContext {
    let key: String
    let isKeyPath: Bool
}

private struct UnboxContainer<T: Unboxable>: UnboxableWithContext {
    let model: T
    
    init(unboxer: Unboxer, context: UnboxContainerContext) throws {
        self.model = try unboxer.unbox(key: context.key, isKeyPath: context.isKeyPath)
    }
}

private struct UnboxArrayContainer<T: Unboxable>: UnboxableWithContext {
    let models: [T]
    
    init(unboxer: Unboxer, context: UnboxContainerContext) throws {
        self.models = try unboxer.unbox(key: context.key, isKeyPath: context.isKeyPath)
    }
}

// MARK: - Private extensions

private extension UnboxCompatibleType {
    static func makeArrayTransformClosure(allowInvalidElements: Bool) -> ([Any]) throws -> [Self]? {
        return {
            try $0.map(allowInvalidElements: allowInvalidElements, transform: self.unbox)
        }
    }
}

private extension Unboxer {
    static func unboxer(from data: Data, context: Any?) throws -> Unboxer {
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? UnboxableDictionary else {
                throw UnboxError.invalidData
            }
            
            return Unboxer(dictionary: dictionary)
        } catch {
            throw UnboxError.invalidData
        }
    }
    
    static func unboxersFromData(data: Data, context: Any?) throws -> [Unboxer] {
        do {
            guard let array = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [UnboxableDictionary] else {
                throw UnboxError.invalidData
            }
            
            return array.map(Unboxer.init)
        } catch {
            throw UnboxError.invalidData
        }
    }
    
    func performUnboxing<T: Unboxable>() throws -> T {
        return try T(unboxer: self)
    }
    
    func performUnboxing<T: UnboxableWithContext>(context: T.ContextType) throws -> T {
        return try T(unboxer: self, context: context)
    }
    
    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        guard let unboxed: T = try closure(self) else {
            throw UnboxError.customUnboxingFailed
        }
        
        return unboxed
    }
}

private extension Array {
    func map<T>(allowInvalidElements: Bool, transform: (Element) throws -> T) throws -> [T] {
        return try self.flatMap {
            do {
                return try transform($0)
            } catch {
                if !allowInvalidElements {
                    throw error
                }
                
                return nil
            }
        }
    }
    
    func map<T>(allowInvalidElements: Bool, transform: (Element) throws -> T?) throws -> [T]? {
        var transformedArray = [T]()
        
        for element in self {
            do {
                guard let transformed = try transform(element) else {
                    if allowInvalidElements {
                        continue
                    }
                    
                    return nil
                }
                
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
