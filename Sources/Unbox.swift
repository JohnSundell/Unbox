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

// MARK: - API
    
/// Type alias defining what type of Dictionary that is Unboxable (valid JSON)
public typealias UnboxableDictionary = [String : Any]

// MARK: - Unbox functions

/// Unbox a JSON dictionary into a model `T`. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary) throws -> T {
    return try Unboxer(dictionary: dictionary).performUnboxing()
}

/// Unbox a JSON dictionary into a model `T` beginning at a certain key. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKey key: String) throws -> T {
    let container: UnboxContainer<T> = try unbox(dictionary: dictionary, context: .key(key))
    return container.model
}

/// Unbox a JSON dictionary into a model `T` beginning at a certain key path. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKeyPath keyPath: String) throws -> T {
    let container: UnboxContainer<T> = try unbox(dictionary: dictionary, context: .keyPath(keyPath))
    return container.model
}

/// Unbox an array of JSON dictionaries into an array of `T`, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionaries: [UnboxableDictionary], allowInvalidElements: Bool = false) throws -> [T] {
    return try dictionaries.map(allowInvalidElements: allowInvalidElements, transform: unbox)
}

/// Unbox an array JSON dictionary into an array of model `T` beginning at a certain key, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKey key: String) throws -> [T] {
    let container: UnboxArrayContainer<T> = try unbox(dictionary: dictionary, context: .key(key))
    return container.models
}

/// Unbox an array JSON dictionary into an array of model `T` beginning at a certain key path, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKeyPath keyPath: String) throws -> [T] {
    let container: UnboxArrayContainer<T> = try unbox(dictionary: dictionary, context: .keyPath(keyPath))
    return container.models
}

/// Unbox binary data into a model `T`. Throws `UnboxError`.
public func unbox<T: Unboxable>(data: Data) throws -> T {
    return try data.unbox()
}

/// Unbox binary data into an array of `T`, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(data: Data, allowInvalidElements: Bool = false) throws -> [T] {
    return try data.unbox(allowInvalidElements: allowInvalidElements)
}

/// Unbox a JSON dictionary into a model `T` using a required contextual object. Throws `UnboxError`.
public func unbox<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.UnboxContext) throws -> T {
    return try Unboxer(dictionary: dictionary).performUnboxing(context: context)
}

/// Unbox an array of JSON dictionaries into an array of `T` using a required contextual object, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: UnboxableWithContext>(dictionaries: [UnboxableDictionary], context: T.UnboxContext, allowInvalidElements: Bool = false) throws -> [T] {
    return try dictionaries.map(allowInvalidElements: allowInvalidElements, transform: {
        try unbox(dictionary: $0, context: context)
    })
}

/// Unbox binary data into a model `T` using a required contextual object. Throws `UnboxError`.
public func unbox<T: UnboxableWithContext>(data: Data, context: T.UnboxContext) throws -> T {
    return try data.unbox(context: context)
}

/// Unbox binary data into an array of `T` using a required contextual object, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: UnboxableWithContext>(data: Data, context: T.UnboxContext, allowInvalidElements: Bool = false) throws -> [T] {
    return try data.unbox(context: context, allowInvalidElements: allowInvalidElements)
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
    /// Thrown when a dictionary with an invalid key type was attempted to be unboxed
    case invalidDictionaryKeyType(Any)
    /// Thrown when a collection with an invalid element type was attempted to be unboxed
    case invalidElementType(Any)
    /// Thrown when a piece of data (Data) could not be unboxed because it was considered invalid
    case invalidData
    /// Thrown when a custom unboxing closure returned nil
    case customUnboxingFailed
}

/// Extension making it possible to print descriptions from UnboxError
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
        case .invalidDictionaryKeyType(let type):
            return baseDescription + "Invalid dictionary key type (\(type)). Must be either String or UnboxableKey."
        case .invalidElementType(let type):
            return baseDescription + "Invalid collection element type (\(type)). Must be an Unbox compatible type."
        case .invalidData:
            return baseDescription + "Invalid Data"
        case .customUnboxingFailed:
            return baseDescription + "A custom unboxing closure returned nil"
        }
    }
}

// MARK: - Protocols

/// Protocol used to declare a model as being Unboxable, for use with the unbox() function
public protocol Unboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an Unboxer
    init(unboxer: Unboxer) throws
}

/// Protocol used to declare a model as being Unboxable with a certain context, for use with the unbox(context:) function
public protocol UnboxableWithContext {
    /// The type of the contextual object that this model requires when unboxed
    associatedtype UnboxContext
    
    /// Initialize an instance of this model by unboxing a dictionary & using a context
    init(unboxer: Unboxer, context: UnboxContext) throws
}

/// Protocol that types that can be used in an unboxing process must conform to. You don't conform to this protocol yourself.
public protocol UnboxCompatible {
    /// Unbox a value, or either throw or return nil if unboxing couldn't be performed
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self?
}

/// Protocol used to enable a raw type for Unboxing. See default implementations further down.
public protocol UnboxableRawType: UnboxCompatible {
    /// Transform an instance of this type from an unboxed integer
    static func transform(unboxedInt: Int) -> Self?
    /// Transform an instance of this type from an unboxed string
    static func transform(unboxedString: String) -> Self?
}

/// Protocol used to enable collections to be unboxed. Default implementations exist for Array & Dictionary
public protocol UnboxableCollection: Collection, UnboxCompatible {
    /// The raw collection type that this type can be unboxed from
    associatedtype UnboxRawCollection: Collection
    /// The value type that this collection contains
    associatedtype UnboxValue
    
    /// Unbox a collection, optionally allowing invalid elements & using a transform
    static func unbox(collection: UnboxRawCollection, allowInvalidElements: Bool, transform: UnboxTransform<UnboxValue>?) throws -> Self?
}

/// Protocol used to enable an enum to be directly unboxable
public protocol UnboxableEnum: RawRepresentable, UnboxCompatible {}

/// Protocol used to enable any type to be transformed from a JSON key into a dictionary key
public protocol UnboxableKey {
    /// Transform an unboxed key into a key that will be used in an unboxed dictionary
    static func transform(unboxedKey: String) -> Self?
}

/// Protocol used to enable any type as being unboxable, by transforming a raw value
public protocol UnboxableByTransform: UnboxCompatible {
    /// The type of raw value that this type can be transformed from. Must be a valid JSON type.
    associatedtype UnboxRawValue
    
    /// Attempt to transform a raw unboxed value into an instance of this type
    static func transform(unboxedValue: UnboxRawValue) -> Self?
}

/// Protocol used by objects that may format raw values into some other value
public protocol UnboxFormatter {
    /// The type of raw value that this formatter accepts as input
    associatedtype UnboxRawValue: UnboxableRawType
    /// The type of value that this formatter produces as output
    associatedtype UnboxFormattedType
    
    /// Format an unboxed value into another value (or nil if the formatting failed)
    func format(unboxedValue: UnboxRawValue) -> UnboxFormattedType?
}

/// Type alias defining a transform type (used internally only)
public typealias UnboxTransform<T> = (Any) throws -> T?

// MARK: - Default protocol implementations

public extension UnboxableRawType {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
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

public extension UnboxableCollection {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        return try (value as? UnboxRawCollection).map {
            try self.unbox(collection: $0,
                           allowInvalidElements: allowInvalidCollectionElements,
                           transform: nil)
        }
    }
}

public extension UnboxableByTransform {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        return (value as? UnboxRawValue).map(self.transform)
    }
}

public extension UnboxableEnum {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        return (value as? RawValue).map(self.init)
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
    public static func transform(unboxedInt: Int) -> String? {
        return String(unboxedInt)
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

// MARK: - Unboxer

/**
 *  Class used to Unbox (decode) values from a dictionary
 *
 *  For each supported type, simply call `unbox(key: string)` (where `string` is a key in the dictionary that is being unboxed)
 *  - and the correct type will be returned. If a required (non-optional) value couldn't be unboxed `UnboxError` will be thrown.
 */
public final class Unboxer {
    /// The underlying JSON dictionary that is being unboxed
    public let dictionary: UnboxableDictionary
    
    // MARK: - Private initializer
    
    fileprivate init(dictionary: UnboxableDictionary) {
        self.dictionary = dictionary
    }
    
    // MARK: - Custom unboxing API
    
    /// Perform custom unboxing using an Unboxer (created from a dictionary) passed to a closure, or throw an UnboxError
    public static func performCustomUnboxing<T>(dictionary: UnboxableDictionary, closure: (Unboxer) throws -> T?) throws -> T {
        return try Unboxer(dictionary: dictionary).performCustomUnboxing(closure: closure)
    }
    
    /// Perform custom unboxing on an array of dictionaries, executing a closure with a new Unboxer for each one, or throw an UnboxError
    public static func performCustomUnboxing<T>(array: [UnboxableDictionary], allowInvalidElements: Bool = false, closure: (Unboxer) throws -> T?) throws -> [T] {
        return try array.map(allowInvalidElements: allowInvalidElements) {
            try Unboxer(dictionary: $0).performCustomUnboxing(closure: closure)
        }
    }
    
    /// Perform custom unboxing using an Unboxer (created from binary data) passed to a closure, or throw an UnboxError
    public static func performCustomUnboxing<T>(data: Data, closure: @escaping (Unboxer) throws -> T?) throws -> T {
        return try data.unbox(closure: closure)
    }
    
    // MARK: - Unboxing required values (by key)
    
    /// Unbox a required value by key
    public func unbox<T: UnboxCompatible>(key: String) throws -> T {
        return try self.unbox(path: .key(key), transform: T.unbox)
    }
    
    /// Unbox a required collection by key
    public func unbox<T: UnboxableCollection>(key: String, allowInvalidElements: Bool) throws -> T {
        let transform = T.makeTransform(allowInvalidElements: allowInvalidElements)
        return try self.unbox(path: .key(key), transform: transform)
    }
    
    /// Unbox a required Unboxable type by key
    public func unbox<T: Unboxable>(key: String) throws -> T {
        return try self.unbox(path: .key(key), transform: T.makeTransform())
    }
    
    /// Unbox a required UnboxableWithContext type by key
    public func unbox<T: UnboxableWithContext>(key: String, context: T.UnboxContext) throws -> T {
        return try self.unbox(path: .key(key), transform: T.makeTransform(context: context))
    }
    
    /// Unbox a required collection of UnboxableWithContext values by key
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(key: String, context: V.UnboxContext, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == V {
        return try self.unbox(path: .key(key), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements))
    }
    
    /// Unbox a required value using a formatter by key
    public func unbox<F: UnboxFormatter>(key: String, formatter: F) throws -> F.UnboxFormattedType {
        return try self.unbox(path: .key(key), transform: formatter.makeTransform())
    }
    
    /// Unbox a required collection of values using a formatter by key
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(key: String, formatter: F, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == F.UnboxFormattedType {
        return try self.unbox(path: .key(key), transform: formatter.makeCollectionTransform(allowInvalidElements: allowInvalidElements))
    }
    
    // MARK: - Unboxing required values (by key path)
    
    /// Unbox a required value by key path
    public func unbox<T: UnboxCompatible>(keyPath: String) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.unbox)
    }
    
    /// Unbox a required collection by key path
    public func unbox<T: UnboxCompatible>(keyPath: String, allowInvalidElements: Bool) throws -> T where T: Collection {
        let transform = T.makeTransform(allowInvalidElements: allowInvalidElements)
        return try self.unbox(path: .keyPath(keyPath), transform: transform)
    }
    
    /// Unbox a required Unboxable by key path
    public func unbox<T: Unboxable>(keyPath: String) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.makeTransform())
    }
    
    /// Unbox a required UnboxableWithContext type by key path
    public func unbox<T: UnboxableWithContext>(keyPath: String, context: T.UnboxContext) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.makeTransform(context: context))
    }
    
    /// Unbox a required collection of UnboxableWithContext values by key path
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(keyPath: String, context: V.UnboxContext, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == V {
        return try self.unbox(path: .keyPath(keyPath), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements))
    }
    
    /// Unbox a required value using a formatter by key path
    public func unbox<F: UnboxFormatter>(keyPath: String, formatter: F) throws -> F.UnboxFormattedType {
        return try self.unbox(path: .keyPath(keyPath), transform: formatter.makeTransform())
    }
    
    /// Unbox a required collection of values using a formatter by key path
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(keyPath: String, formatter: F, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == F.UnboxFormattedType {
        return try self.unbox(path: .keyPath(keyPath), transform: formatter.makeCollectionTransform(allowInvalidElements: allowInvalidElements))
    }
    
    // MARK: - Unboxing optional values (by key)
    
    /// Unbox an optional value by key
    public func unbox<T: UnboxCompatible>(key: String) -> T? {
        return try? self.unbox(key: key)
    }
    
    /// Unbox an optional collection by key
    public func unbox<T: UnboxableCollection>(key: String, allowInvalidElements: Bool) -> T? {
        return try? self.unbox(key: key, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox an optional Unboxable type by key
    public func unbox<T: Unboxable>(key: String) -> T? {
        return try? self.unbox(key: key)
    }
    
    /// Unbox an optional UnboxableWithContext type by key
    public func unbox<T: UnboxableWithContext>(key: String, context: T.UnboxContext) -> T? {
        return try? self.unbox(key: key, context: context)
    }
    
    /// Unbox an optional collection of UnboxableWithContext values by key
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(key: String, context: V.UnboxContext, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == V {
        return try? self.unbox(key: key, context: context, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox an optional value using a formatter by key
    public func unbox<F: UnboxFormatter>(key: String, formatter: F) -> F.UnboxFormattedType? {
        return try? self.unbox(key: key, formatter: formatter)
    }
    
    /// Unbox an optional collection of values using a formatter by key
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(key: String, formatter: F, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == F.UnboxFormattedType {
        return try? self.unbox(key: key, formatter: formatter, allowInvalidElements: allowInvalidElements)
    }
    
    // MARK: - Unboxing optional values (by key path)
    
    /// Unbox an optional value by key path
    public func unbox<T: UnboxCompatible>(keyPath: String) -> T? {
        return try? self.unbox(keyPath: keyPath)
    }
    
    /// Unbox an optional collection by key path
    public func unbox<T: UnboxableCollection>(keyPath: String, allowInvalidElements: Bool) -> T? {
        return try? self.unbox(keyPath: keyPath, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox an optional Unboxable type by key path
    public func unbox<T: Unboxable>(keyPath: String) -> T? {
        return try? self.unbox(keyPath: keyPath)
    }
    
    /// Unbox an optional UnboxableWithContext type by key path
    public func unbox<T: UnboxableWithContext>(keyPath: String, context: T.UnboxContext) -> T? {
        return try? self.unbox(keyPath: keyPath, context: context)
    }
    
    /// Unbox an optional collection of UnboxableWithContext values by key path
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(keyPath: String, context: V.UnboxContext, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == V {
        return try? self.unbox(keyPath: keyPath, context: context, allowInvalidElements: allowInvalidElements)
    }
    
    /// Unbox an optional value using a formatter by key path
    public func unbox<F: UnboxFormatter>(keyPath: String, formatter: F) -> F.UnboxFormattedType? {
        return try? self.unbox(keyPath: keyPath, formatter: formatter)
    }
    
    /// Unbox an optional collection of values using a formatter by key path
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(keyPath: String, formatter: F, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == F.UnboxFormattedType {
        return try? self.unbox(keyPath: keyPath, formatter: formatter, allowInvalidElements: allowInvalidElements)
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

// MARK: - UnboxContainers

private struct UnboxContainer<T: Unboxable>: UnboxableWithContext {
    let model: T
    
    init(unboxer: Unboxer, context: UnboxPath) throws {
        switch context {
        case .key(let key):
            self.model = try unboxer.unbox(key: key)
        case .keyPath(let keyPath):
            self.model = try unboxer.unbox(keyPath: keyPath)
        }
    }
}

private struct UnboxArrayContainer<T: Unboxable>: UnboxableWithContext {
    let models: [T]
    
    init(unboxer: Unboxer, context: UnboxPath) throws {
        switch context {
        case .key(let key):
            self.models = try unboxer.unbox(key: key)
        case .keyPath(let keyPath):
            self.models = try unboxer.unbox(keyPath: keyPath)
        }
    }
}

// MARK: - Private extensions

private extension UnboxCompatible {
    static func unbox(value: Any) throws -> Self? {
        return try self.unbox(value: value, allowInvalidCollectionElements: false)
    }
}

private extension UnboxCompatible where Self: Collection {
    static func makeTransform(allowInvalidElements: Bool) -> UnboxTransform<Self> {
        return {
            try self.unbox(value: $0, allowInvalidCollectionElements: allowInvalidElements)
        }
    }
}

private extension Unboxable {
    static func makeTransform() -> UnboxTransform<Self> {
        return { try ($0 as? UnboxableDictionary).map(unbox) }
    }
}

private extension UnboxableWithContext {
    static func makeTransform(context: UnboxContext) -> UnboxTransform<Self> {
        return {
            try ($0 as? UnboxableDictionary).map {
                try unbox(dictionary: $0, context: context)
            }
        }
    }
    
    static func makeCollectionTransform<C: UnboxableCollection>(context: UnboxContext, allowInvalidElements: Bool) -> UnboxTransform<C> where C.UnboxValue == Self {
        return {
            return try ($0 as? C.UnboxRawCollection).map {
                return try C.unbox(collection: $0,
                                   allowInvalidElements: allowInvalidElements,
                                   transform: self.makeTransform(context: context))
            }
        }
    }
}

private extension UnboxFormatter {
    func makeTransform() -> UnboxTransform<UnboxFormattedType> {
        return { ($0 as? UnboxRawValue).map(self.format) }
    }
    
    func makeCollectionTransform<C: UnboxableCollection>(allowInvalidElements: Bool) -> UnboxTransform<C> where C.UnboxValue == UnboxFormattedType {
        return {
            return try ($0 as? C.UnboxRawCollection).map {
                return try C.unbox(collection: $0,
                                   allowInvalidElements: allowInvalidElements,
                                   transform: self.makeTransform())
            }
        }
    }
}

private extension Unboxer {
    func unbox<R>(path: UnboxPath, transform: UnboxTransform<R>) throws -> R {
        var currentMode = UnboxingMode.dictionary(self.dictionary)
        let components = path.components
        let lastKey = try components.last.orThrow(.emptyKeyPath)
        
        for key in components {
            switch currentMode {
            case .dictionary(let dictionary):
                currentMode = try UnboxingMode(value: dictionary[key].orThrow(.missingValue(key)))
            case .array(let array):
                guard let index = Int(key), index < array.count else {
                    throw UnboxError.missingValue(key)
                }
                
                currentMode = UnboxingMode(value: array[index])
            case .value(let value):
                throw UnboxError.invalidValue(value, key)
            }
        }
        
        return try transform(currentMode.value).orThrow(UnboxError.invalidValue(currentMode.value, lastKey))
    }
    
    func performUnboxing<T: Unboxable>() throws -> T {
        return try T(unboxer: self)
    }
    
    func performUnboxing<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try T(unboxer: self, context: context)
    }
    
    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(self).orThrow(.customUnboxingFailed)
    }
}

private extension Optional {
    func map<T>(_ transform: (Wrapped) throws -> T?) rethrows -> T? {
        guard let value = self else {
            return nil
        }
        
        return try transform(value)
    }
    
    func orThrow(_ errorClosure: @autoclosure () -> UnboxError) throws -> Wrapped {
        guard let value = self else {
            throw errorClosure()
        }
        
        return value
    }
}

private extension JSONSerialization {
    static func unbox<T>(data: Data, options: ReadingOptions = []) throws -> T {
        do {
            return try (self.jsonObject(with: data, options: options) as? T).orThrow(.invalidData)
        } catch {
            throw UnboxError.invalidData
        }
    }
}

private extension Data {
    func unbox<T: Unboxable>() throws -> T {
        return try Unbox.unbox(dictionary: JSONSerialization.unbox(data: self))
    }
    
    func unbox<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try Unbox.unbox(dictionary: JSONSerialization.unbox(data: self), context: context)
    }
    
    func unbox<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(Unboxer(dictionary: JSONSerialization.unbox(data: self))).orThrow(.customUnboxingFailed)
    }
    
    func unbox<T: Unboxable>(allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])
        return try array.map(allowInvalidElements: allowInvalidElements, transform: Unbox.unbox)
    }
    
    func unbox<T: UnboxableWithContext>(context: T.UnboxContext, allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])
        
        return try array.map(allowInvalidElements: allowInvalidElements) {
            try Unbox.unbox(dictionary: $0, context: context)
        }
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

private extension Dictionary {
    func map<K, V>(allowInvalidElements: Bool, transform: (Key, Value) throws -> (K, V)?) throws -> [K : V]? {
        var transformedDictionary = [K : V]()
        
        for (key, value) in self {
            do {
                guard let transformed = try transform(key, value) else {
                    if allowInvalidElements {
                        continue
                    }
                    
                    return nil
                }
                
                transformedDictionary[transformed.0] = transformed.1
            } catch {
                if !allowInvalidElements {
                    throw error
                }
            }
        }
        
        return transformedDictionary
    }
}
