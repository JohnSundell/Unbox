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
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKey key: String, allowInvalidElements: Bool = false) throws -> [T] {
    let container: UnboxArrayContainer<T> = try unbox(dictionary: dictionary, context: (.key(key), allowInvalidElements))
    return container.models
}

/// Unbox an array JSON dictionary into an array of model `T` beginning at a certain key path, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary, atKeyPath keyPath: String, allowInvalidElements: Bool = false) throws -> [T] {
    let container: UnboxArrayContainer<T> = try unbox(dictionary: dictionary, context: (.keyPath(keyPath), allowInvalidElements))
    return container.models
}

/// Unbox binary data into a model `T`. Throws `UnboxError`.
public func unbox<T: Unboxable>(data: Data) throws -> T {
    return try data.unbox()
}

/// Unbox binary data into an array of `T`, optionally allowing invalid elements. Throws `UnboxError`.
public func unbox<T: Unboxable>(data: Data, atKeyPath keyPath: String? = nil, allowInvalidElements: Bool = false) throws -> [T] {
    if let keyPath = keyPath {
        return try unbox(dictionary: JSONSerialization.unbox(data: data), atKeyPath: keyPath, allowInvalidElements: allowInvalidElements)
    }
    
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

/// Unbox binary data into a dictionary of type `[String: T]`. Throws `UnboxError`.
public func unbox<T: Unboxable>(data: Data) throws -> [String: T] {
    let dictionary : [String: [String: Any]] = try JSONSerialization.unbox(data: data)
    return try unbox(dictionary: dictionary)
}

/// Unbox `UnboxableDictionary` into a dictionary of type `[String: T]` where `T` is `Unboxable`. Throws `UnboxError`.
public func unbox<T: Unboxable>(dictionary: UnboxableDictionary) throws -> [String: T] {
    var mappedDictionary = [String: T]()
    try dictionary.forEach { key, value in
        guard let innerDictionary = value as? UnboxableDictionary else {
            throw UnboxError.invalidData
        }
        let data : T = try unbox(dictionary: innerDictionary)
        mappedDictionary[key] = data
    }
    return mappedDictionary
}

// MARK: - Error type

/// Error type that Unbox throws in case an unrecoverable error was encountered
public enum UnboxError: Error {
    /// Invalid data was provided when calling unbox(data:...)
    case invalidData
    /// Custom unboxing failed, either by throwing or returning `nil`
    case customUnboxingFailed
    /// An error occured while unboxing a value for a path (contains the underlying path error, and the path)
    case pathError(UnboxPathError, String)
}

/// Extension making `UnboxError` conform to `CustomStringConvertible`
extension UnboxError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidData:
            return "[UnboxError] Invalid data."
        case .customUnboxingFailed:
            return "[UnboxError] Custom unboxing failed."
        case .pathError(let error, let path):
            return "[UnboxError] An error occured while unboxing path \"\(path)\": \(error)"
        }
    }
}

/// Type for errors that can occur while unboxing a certain path
public enum UnboxPathError: Error {
    /// An empty key path was given
    case emptyKeyPath
    /// A required key was missing (contains the key)
    case missingKey(String)
    /// An invalid value was found (contains the value, and its key)
    case invalidValue(Any, String)
    /// An invalid collection element type was found (contains the type)
    case invalidCollectionElementType(Any)
    /// An invalid array element was found (contains the element, and its index)
    case invalidArrayElement(Any, Int)
    /// An invalid dictionary key type was found (contains the type)
    case invalidDictionaryKeyType(Any)
    /// An invalid dictionary key was found (contains the key)
    case invalidDictionaryKey(Any)
    /// An invalid dictionary value was found (contains the value, and its key)
    case invalidDictionaryValue(Any, String)
}

extension UnboxPathError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyKeyPath:
            return "Key path can't be empty."
        case .missingKey(let key):
            return "The key \"\(key)\" is missing."
        case .invalidValue(let value, let key):
            return "Invalid value (\(value)) for key \"\(key)\"."
        case .invalidCollectionElementType(let type):
            return "Invalid collection element type: \(type). Must be UnboxCompatible or Unboxable."
        case .invalidArrayElement(let element, let index):
            return "Invalid array element (\(element)) at index \(index)."
        case .invalidDictionaryKeyType(let type):
            return "Invalid dictionary key type: \(type). Must be either String or UnboxableKey."
        case .invalidDictionaryKey(let key):
            return "Invalid dictionary key: \(key)."
        case .invalidDictionaryValue(let value, let key):
            return "Invalid dictionary value (\(value)) for key \"\(key)\"."
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
    /// Transform an instance of this type from an unboxed number
    static func transform(unboxedNumber: NSNumber) -> Self?
    /// Transform an instance of this type from an unboxed string
    static func transform(unboxedString: String) -> Self?
}

/// Protocol used to enable collections to be unboxed. Default implementations exist for Array & Dictionary
public protocol UnboxableCollection: Collection, UnboxCompatible {
    /// The value type that this collection contains
    associatedtype UnboxValue
    
    /// Unbox a value into a collection, optionally allowing invalid elements
    static func unbox<T: UnboxCollectionElementTransformer>(value: Any, allowInvalidElements: Bool, transformer: T) throws -> Self? where T.UnboxedElement == UnboxValue
}

/// Protocol used to unbox an element in a collection. Unbox provides default implementations of this protocol.
public protocol UnboxCollectionElementTransformer {
    /// The raw element type that this transformer expects as input
    associatedtype UnboxRawElement
    /// The unboxed element type that this transformer outputs
    associatedtype UnboxedElement
    
    /// Unbox an element from a collection, optionally allowing invalid elements for nested collections
    func unbox(element: UnboxRawElement, allowInvalidCollectionElements: Bool) throws -> UnboxedElement?
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

// MARK: - Default protocol implementations

public extension UnboxableRawType {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        if let matchedValue = value as? Self {
            return matchedValue
        }
        
        if let string = value as? String {
            return self.transform(unboxedString: string)
        }

        if let number = value as? NSNumber {
            return self.transform(unboxedNumber: number)
        }

        return nil
    }
}

public extension UnboxableCollection {
    public static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        if let matchingCollection = value as? Self {
            return matchingCollection
        }
        
        if let unboxableType = UnboxValue.self as? Unboxable.Type {
            let transformer = UnboxCollectionElementClosureTransformer<UnboxableDictionary, UnboxValue>() { element in
                let unboxer = Unboxer(dictionary: element)
                return try unboxableType.init(unboxer: unboxer) as? UnboxValue
            }
            
            return try self.unbox(value: value, allowInvalidElements: allowInvalidCollectionElements, transformer: transformer)
        }
        
        if let unboxCompatibleType = UnboxValue.self as? UnboxCompatible.Type {
            let transformer = UnboxCollectionElementClosureTransformer<Any, UnboxValue>() { element in
                return try unboxCompatibleType.unbox(value: element, allowInvalidCollectionElements: allowInvalidCollectionElements) as? UnboxValue
            }
            
            return try self.unbox(value: value, allowInvalidElements: allowInvalidCollectionElements, transformer: transformer)
        }
        
        throw UnboxPathError.invalidCollectionElementType(UnboxValue.self)
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

/// Extension making Decimal an Unboxable raw type
extension Decimal: UnboxableRawType {
    public static func transform(unboxedNumber: NSNumber) -> Decimal? {
        return Decimal(string: unboxedNumber.stringValue)
    }
    
    public static func transform(unboxedString unboxedValue: String) -> Decimal? {
        return Decimal(string: unboxedValue)
    }
}

/// Extension making Array an unboxable collection
extension Array: UnboxableCollection {
    public typealias UnboxValue = Element
    
    public static func unbox<T: UnboxCollectionElementTransformer>(value: Any, allowInvalidElements: Bool, transformer: T) throws -> Array? where T.UnboxedElement == UnboxValue {
        guard let array = value as? [T.UnboxRawElement] else {
            return nil
        }
        
        return try array.enumerated().map(allowInvalidElements: allowInvalidElements) { index, element in
            try transformer.unbox(element: element, allowInvalidCollectionElements: allowInvalidElements).orThrow(UnboxPathError.invalidArrayElement(element, index))
        }
    }
}

/// Extension making Set an unboxable collection
extension Set: UnboxableCollection {
    public typealias UnboxValue = Element
  
    public static func unbox<T: UnboxCollectionElementTransformer>(value: Any, allowInvalidElements: Bool, transformer: T) throws -> Set? where T.UnboxedElement == UnboxValue {
        guard let array = try [UnboxValue].unbox(value: value, allowInvalidElements: allowInvalidElements, transformer: transformer) else {
            return nil
        }
        
        return Set(array)
    }
}

/// Extension making Dictionary an unboxable collection
extension Dictionary: UnboxableCollection {
    public typealias UnboxValue = Value

    public static func unbox<T: UnboxCollectionElementTransformer>(value: Any, allowInvalidElements: Bool, transformer: T) throws -> Dictionary? where T.UnboxedElement == UnboxValue {
        guard let dictionary = value as? [String : T.UnboxRawElement] else {
            return nil
        }
        
        let keyTransform = try self.makeKeyTransform()
        
        return try dictionary.map(allowInvalidElements: allowInvalidElements) { key, value in
            guard let unboxedKey = keyTransform(key) else {
                throw UnboxPathError.invalidDictionaryKey(key)
            }
            
            guard let unboxedValue = try transformer.unbox(element: value, allowInvalidCollectionElements: allowInvalidElements) else {
                throw UnboxPathError.invalidDictionaryValue(value, key)
            }
            
            return (unboxedKey, unboxedValue)
        }
    }
    
    private static func makeKeyTransform() throws -> (String) -> Key? {
        if Key.self is String.Type {
            return { $0 as? Key }
        }
        
        if let keyType = Key.self as? UnboxableKey.Type {
            return { keyType.transform(unboxedKey: $0) as? Key }
        }
        
        throw UnboxPathError.invalidDictionaryKeyType(Key.self)
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
    
    // MARK: - Initializer
    
    /// Initialize an instance with a dictionary that can then be decoded using the `unbox()` methods.
    public init(dictionary: UnboxableDictionary) {
        self.dictionary = dictionary
    }
    
    /// Initialize an instance with binary data than can then be decoded using the `unbox()` methods. Throws `UnboxError` for invalid data.
    public init(data: Data) throws {
        self.dictionary = try JSONSerialization.unbox(data: data)
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

// MARK: - UnboxTransform

private typealias UnboxTransform<T> = (Any) throws -> T?

// MARK: - UnboxPath

private enum UnboxPath {
    case key(String)
    case keyPath(String)
}

extension UnboxPath: CustomStringConvertible {
    var description: String {
        switch self {
        case .key(let key):
            return key
        case .keyPath(let keyPath):
            return keyPath
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
    
    init(unboxer: Unboxer, context: (path: UnboxPath, allowInvalidElements: Bool)) throws {
        switch context.path {
        case .key(let key):
            self.models = try unboxer.unbox(key: key, allowInvalidElements: context.allowInvalidElements)
        case .keyPath(let keyPath):
            self.models = try unboxer.unbox(keyPath: keyPath, allowInvalidElements: context.allowInvalidElements)
        }
    }
}

// MARK: - Collection element transformers

private class UnboxCollectionElementClosureTransformer<I, O>: UnboxCollectionElementTransformer {
    private let closure: (I) throws -> O?
    
    init(closure: @escaping (I) throws -> O?) {
        self.closure = closure
    }
    
    func unbox(element: I, allowInvalidCollectionElements: Bool) throws -> O? {
        return try self.closure(element)
    }
}

private class UnboxableWithContextCollectionElementTransformer<T: UnboxableWithContext>: UnboxCollectionElementTransformer {
    private let context: T.UnboxContext
    
    init(context: T.UnboxContext) {
        self.context = context
    }
    
    func unbox(element: UnboxableDictionary, allowInvalidCollectionElements: Bool) throws -> T? {
        let unboxer = Unboxer(dictionary: element)
        return try T(unboxer: unboxer, context: self.context)
    }
}

private class UnboxFormatterCollectionElementTransformer<T: UnboxFormatter>: UnboxCollectionElementTransformer {
    private let formatter: T
    
    init(formatter: T) {
        self.formatter = formatter
    }
    
    func unbox(element: T.UnboxRawValue, allowInvalidCollectionElements: Bool) throws -> T.UnboxFormattedType? {
        return self.formatter.format(unboxedValue: element)
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
            let transformer = UnboxableWithContextCollectionElementTransformer<Self>(context: context)
            return try C.unbox(value: $0, allowInvalidElements: allowInvalidElements, transformer: transformer)
        }
    }
}

private extension UnboxFormatter {
    func makeTransform() -> UnboxTransform<UnboxFormattedType> {
        return { ($0 as? UnboxRawValue).map(self.format) }
    }
    
    func makeCollectionTransform<C: UnboxableCollection>(allowInvalidElements: Bool) -> UnboxTransform<C> where C.UnboxValue == UnboxFormattedType {
        return {
            let transformer = UnboxFormatterCollectionElementTransformer(formatter: self)
            return try C.unbox(value: $0, allowInvalidElements: allowInvalidElements, transformer: transformer)
        }
    }
}

// MARK: - Path nodes

private protocol UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any?
}

extension Dictionary: UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any? {
        return self[key as! Key]
    }
}

extension Array: UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any? {
        guard let index = Int(key) else {
            return nil
        }
        
        if index >= self.count {
            return nil
        }
        
        return self[index]
    }
}

#if !os(Linux)
extension NSDictionary: UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any? {
        return self[key]
    }
}
    
extension NSArray: UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any? {
        return (self as Array).unboxPathValue(forKey: key)
    }
}
#endif

private extension Unboxer {
    func unbox<R>(path: UnboxPath, transform: UnboxTransform<R>) throws -> R {
        do {
            switch path {
            case .key(let key):
                let value = try self.dictionary[key].orThrow(UnboxPathError.missingKey(key))
                return try transform(value).orThrow(UnboxPathError.invalidValue(value, key))
            case .keyPath(let keyPath):
                var node: UnboxPathNode = self.dictionary
                let components = keyPath.components(separatedBy: ".")
                let lastKey = components.last
                
                for key in components {
                    guard let nextValue = node.unboxPathValue(forKey: key) else {
                        throw UnboxPathError.missingKey(key)
                    }
                    
                    if key == lastKey {
                        return try transform(nextValue).orThrow(UnboxPathError.invalidValue(nextValue, key))
                    }
                    
                    guard let nextNode = nextValue as? UnboxPathNode else {
                        throw UnboxPathError.invalidValue(nextValue, key)
                    }
                    
                    node = nextNode
                }
                
                throw UnboxPathError.emptyKeyPath
            }
        } catch {
            if let publicError = error as? UnboxError {
                throw publicError
            } else if let pathError = error as? UnboxPathError {
                throw UnboxError.pathError(pathError, path.description)
            }
            
            throw error
        }
    }
    
    func performUnboxing<T: Unboxable>() throws -> T {
        return try T(unboxer: self)
    }
    
    func performUnboxing<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try T(unboxer: self, context: context)
    }
    
    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(self).orThrow(UnboxError.customUnboxingFailed)
    }
}

private extension Optional {
    func map<T>(_ transform: (Wrapped) throws -> T?) rethrows -> T? {
        guard let value = self else {
            return nil
        }
        
        return try transform(value)
    }
    
    func orThrow<E: Error>(_ errorClosure: @autoclosure () -> E) throws -> Wrapped {
        guard let value = self else {
            throw errorClosure()
        }
        
        return value
    }
}

private extension JSONSerialization {
    static func unbox<T>(data: Data, options: ReadingOptions = []) throws -> T {
        do {
            return try (self.jsonObject(with: data, options: options) as? T).orThrow(UnboxError.invalidData)
        } catch {
            throw UnboxError.invalidData
        }
    }
}

private extension Data {
    func unbox<T: Unboxable>() throws -> T {
        return try Unboxer(data: self).performUnboxing()
    }
    
    func unbox<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try Unboxer(data: self).performUnboxing(context: context)
    }
    
    func unbox<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(Unboxer(data: self)).orThrow(UnboxError.customUnboxingFailed)
    }
    
    func unbox<T: Unboxable>(allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])
        return try array.map(allowInvalidElements: allowInvalidElements) { dictionary in
            return try Unboxer(dictionary: dictionary).performUnboxing()
        }
    }
    
    func unbox<T: UnboxableWithContext>(context: T.UnboxContext, allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])
        
        return try array.map(allowInvalidElements: allowInvalidElements) { dictionary in
            return try Unboxer(dictionary: dictionary).performUnboxing(context: context)
        }
    }
}

private extension Sequence {
    func map<T>(allowInvalidElements: Bool, transform: (Iterator.Element) throws -> T) throws -> [T] {
        if !allowInvalidElements {
            return try self.map(transform)
        }
        
        return self.flatMap {
            return try? transform($0)
        }
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
