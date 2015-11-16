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

/// Type alias defining what type of Dictionary that is Unboxable (valid JSON)
public typealias UnboxableDictionary = [String : AnyObject]

// MARK: - Main Unbox functions

/**
 *  Unbox (decode) a dictionary into a model
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *
 *  @discussion This function gets its return type from the context in which it's called.
 *  If the context is ambigious, you need to supply it, like:
 *
 *  `let unboxed: MyUnboxable? = Unbox(dictionary)`
 *
 *  @return A model of type `T` or `nil` if an error was occured. If you prefer do, try, catch
 *  error handling instead of optionals; use `UnboxOrThrow` instead.
 */
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, context: Any? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(dictionary, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a set of data into a model
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *
 *  @discussion See the documentation for the main `Unbox(dictionary:)` function above for more information.
 */
public func Unbox<T: Unboxable>(data: NSData, context: Any? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(data, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a dictionary into a model using a context
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context The contextual object to use during unboxing.
 *
 *  @discussion See the documentation for `Unbox(dictionary:)` for more information.
 */
public func Unbox<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.ContextType) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(dictionary, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a set of data into a model using a context
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context The contextual object to use during unboxing.
 *
 *  @discussion See the documentation for `Unbox(data:)` for more information.
 */
public func Unbox<T: UnboxableWithContext>(data: NSData, context: T.ContextType) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(data, context: context)
        return unboxed
    } catch {
        return nil
    }
}

// MARK: - Unbox functions with error handling

/**
 *  Unbox (decode) a dictionary into a model, or throw an UnboxError if the operation failed
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied dictionary couldn't be decoded
 *  for any reason. See the documentation for the main Unbox() function above for more information.
 */
public func UnboxOrThrow<T: Unboxable>(dictionary: UnboxableDictionary, context: Any? = nil) throws -> T {
    let unboxer = Unboxer(dictionary: dictionary, context: context)
    let unboxed = T(unboxer: unboxer)
    
    try unboxer.throwIfFailed()
    
    return unboxed
}

/**
 *  Unbox (decode) a set of data into a model, or throw an UnboxError if the operation failed
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied data couldn't be decoded for
 *  any reason. See the documentation for the main Unbox() function above for more information.
 */
public func UnboxOrThrow<T: Unboxable>(data: NSData, context: Any? = nil) throws -> T {
    if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? UnboxableDictionary {
        return try UnboxOrThrow(dictionary)
    }
    
    throw UnboxError.InvalidDictionary
}

/**
 *  Unbox (decode) a dictionary into a model using a context, or throw an UnboxError if the operation failed
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context The contextual object to use during unboxing.
 *
 *  @discussion See the documentation for `UnboxOrThrow(dictionary:)` for more information.
 */
public func UnboxOrThrow<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.ContextType) throws -> T {
    let unboxer = Unboxer(dictionary: dictionary, context: context)
    let unboxed = T(unboxer: unboxer, context: context)
    
    try unboxer.throwIfFailed()
    
    return unboxed
}

/**
 *  Unbox (decode) a set of data into a model using a context, or throw an UnboxError if the operation failed
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context The contextual object to use during unboxing.
 *
 *  @discussion See the documentation for `UnboxOrThrow(data:)` for more information.
 */
public func UnboxOrThrow<T: UnboxableWithContext>(data: NSData, context: T.ContextType) throws -> T {
    if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? UnboxableDictionary {
        return try UnboxOrThrow(dictionary, context: context)
    }
    
    throw UnboxError.InvalidDictionary
}

// MARK: - Error type

/// Enum describing errors that can occur during unboxing. Use the throwing functions to receive any errors.
public enum UnboxError: ErrorType, CustomStringConvertible {
    public var description: String {
        let baseDescription = "[Unbox error] "
        
        switch self {
        case .MissingKey(let key):
            return baseDescription + "Missing key (\(key))"
        case .InvalidValue(let key, let valueDescription):
            return baseDescription + "Invalid value (\(valueDescription)) for key (\(key))"
        case .InvalidDictionary:
            return "Invalid dictionary"
        }
    }
    
    /// Thrown when a required key was missing in an unboxed dictionary. Contains the missing key.
    case MissingKey(String)
    /// Thrown when a required key contained an invalid value in an unboxed dictionary. Contains the invalid
    /// key and a description of the invalid data.
    case InvalidValue(String, String)
    /// Thrown when an unboxed dictionary was either missing or contained invalid data
    case InvalidDictionary
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
    typealias ContextType
    
    /// Initialize an instance of this model by unboxing a dictionary & using a context
    init(unboxer: Unboxer, context: ContextType)
}

/// Protocol that types that can be used in an unboxing process must conform to
public protocol UnboxCompatibleType {
    /// The value to use for required properties if unboxing failed. Typically a dummy value.
    static func unboxFallbackValue() -> Self
}

/// Protocol used to enable a raw type for Unboxing. See default implementations further down.
public protocol UnboxableRawType: UnboxCompatibleType {}

/// Protocol used to enable an enum to be directly unboxable
public protocol UnboxableEnum: RawRepresentable, UnboxCompatibleType {}

/// Protocol used to enable any type as being unboxable, by transforming a raw value
public protocol UnboxableByTransform: UnboxCompatibleType {
    /// The type of raw value that this type can be transformed from
    typealias UnboxRawValueType: UnboxableRawType
    
    /// Attempt to transform a raw unboxed value into an instance of this type
    static func transformUnboxedValue(unboxedValue: UnboxRawValueType) -> Self?
}

// MARK: - Extensions

/// Extension making Bool an Unboxable raw type
extension Bool: UnboxableRawType {
    public static func unboxFallbackValue() -> Bool {
        return false
    }
}

/// Extension making Int an Unboxable raw type
extension Int: UnboxableRawType {
    public static func unboxFallbackValue() -> Int {
        return 0
    }
}

/// Extension making Double an Unboxable raw type
extension Double: UnboxableRawType {
    public static func unboxFallbackValue() -> Double {
        return 0
    }
}

/// Extension making Float an Unboxable raw type
extension Float: UnboxableRawType {
    public static func unboxFallbackValue() -> Float {
        return 0
    }
}

/// Extension making String an Unboxable raw type
extension String: UnboxableRawType {
    public static func unboxFallbackValue() -> String {
        return ""
    }
}

/// Extension making NSURL Unboxable by transform
extension NSURL: UnboxableByTransform {
    public typealias UnboxRawValueType = String
    
    public static func transformUnboxedValue(rawValue: String) -> Self? {
        return self.init(string: rawValue)
    }
    
    public static func unboxFallbackValue() -> Self {
        return self.init()
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
    /// All keys contained within the underlying JSON data that is being unboxed
    public var allKeys: [String] { return Array(self.dictionary.keys) }
    /// Whether the Unboxer has failed, and a `nil` value will be returned from the `Unbox()` function that triggered it.
    public var hasFailed: Bool { return self.failureInfo != nil }
    /// Any contextual object that was supplied when unboxing was started
    public let context: Any?
    
    private var failureInfo: (key: String, value: Any?)?
    private let dictionary: UnboxableDictionary
    
    // MARK: - Private initializer
    
    private init(dictionary: UnboxableDictionary, context: Any?) {
        self.dictionary = dictionary
        self.context = context
    }
    
    // MARK: - Public API
    
    /// Unbox a required raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T {
        return UnboxValueResolver<T>(self).resolveRequiredValueForKey(key, fallbackValue: T.unboxFallbackValue())
    }
    
    /// Unbox an optional raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T? {
        return UnboxValueResolver<T>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required Array
    public func unbox<T>(key: String) -> [T] {
        return UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key, fallbackValue: [])
    }
    
    /// Unbox an optional Array
    public func unbox<T>(key: String) -> [T]? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required Dictionary
    public func unbox<T>(key: String) -> [String : T] {
        return UnboxValueResolver<[String : T]>(self).resolveRequiredValueForKey(key, fallbackValue: [:])
    }
    
    /// Unbox an optional Dictionary
    public func unbox<T>(key: String) -> [String : T]? {
        return UnboxValueResolver<[String : T]>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required enum value
    public func unbox<T: UnboxableEnum>(key: String) -> T {
        return UnboxValueResolver<T.RawValue>(self).resolveRequiredValueForKey(key, fallbackValue: T.unboxFallbackValue(), transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox an optional enum value
    public func unbox<T: UnboxableEnum>(key: String) -> T? {
        return UnboxValueResolver<T.RawValue>(self).resolveOptionalValueForKey(key, transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: T(unboxer: self), transform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key, transform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T] {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveCollectionValuesForKey(key, required: true, valueTransform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveCollectionValuesForKey(key, required: false, valueTransform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T] {
        return UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key, required: true, valueTransform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T]? {
        return UnboxValueResolver<[String : UnboxableDictionary]>(self).resolveDictionaryValuesForKey(key, required: false, valueTransform: {
            return Unbox($0, context: self.context)
        })
    }
    
    /// Unbox a required value that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String) -> T {
        return UnboxValueResolver<T.UnboxRawValueType>(self).resolveRequiredValueForKey(key, fallbackValue: T.unboxFallbackValue(), transform: {
            return T.transformUnboxedValue($0)
        })
    }
    
    /// Unbox an optional value that can be transformed into its final form
    public func unbox<T: UnboxableByTransform>(key: String) -> T? {
        return UnboxValueResolver<T.UnboxRawValueType>(self).resolveOptionalValueForKey(key, transform: {
            return T.transformUnboxedValue($0)
        })
    }
    
    /// Return a required contextual object of type `T` attached to this Unboxer, or cause the Unboxer to fail (using a dummy fallback value)
    public func requiredContextWithFallbackValue<T>(@autoclosure fallbackValue: () -> T) -> T {
        if let context = self.context as? T {
            return context
        }
        
        self.failForInvalidValue(self.context, forKey: "Unboxer.Context")
        
        return fallbackValue()
    }
    
    /// Make this Unboxer to fail for a certain key. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForKey(key: String) {
        self.failForInvalidValue(nil, forKey: key)
    }
    
    /// Make this Unboxer to fail for a certain key and invalid value. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForInvalidValue(invalidValue: Any?, forKey key: String) {
        self.failureInfo = (key, invalidValue)
    }
    
    // MARK: - Private
    
    private func throwIfFailed() throws {
        guard let failureInfo = self.failureInfo else {
            return
        }
        
        if let failedValue: Any = failureInfo.value {
            throw UnboxError.InvalidValue(failureInfo.key, "\(failedValue)")
        }
        
        throw UnboxError.MissingKey(failureInfo.key)
    }
}

// MARK: - UnboxValueResolver

private class UnboxValueResolver<T> {
    let unboxer: Unboxer
    
    init(_ unboxer: Unboxer) {
        self.unboxer = unboxer
    }
    
    func resolveRequiredValueForKey(key: String, @autoclosure fallbackValue: () -> T) -> T {
        return self.resolveRequiredValueForKey(key, fallbackValue: fallbackValue, transform: {
            return $0
        })
    }
    
    func resolveRequiredValueForKey<R>(key: String, @autoclosure fallbackValue: () -> R, transform: T -> R?) -> R {
        if let value = self.resolveOptionalValueForKey(key, transform: transform) {
            return value
        }
        
        self.unboxer.failForInvalidValue(self.unboxer.dictionary[key], forKey: key)
        
        return fallbackValue()
    }
    
    func resolveOptionalValueForKey(key: String) -> T? {
        return self.resolveOptionalValueForKey(key, transform: {
            return $0
        })
    }
    
    func resolveOptionalValueForKey<R>(var key: String, transform: T -> R?) -> R? {
        var dictionary = self.unboxer.dictionary
        let isKeyPath = key.rangeOfString(".") != nil
        if isKeyPath {
            let components = key.componentsSeparatedByString(".")
            for var i = 0; i < components.count; i++ {
                let keyPathComponent = components[i]
                let isLast = i == components.count - 1
                if isLast {
                    key = keyPathComponent
                } else if let nestedDictionary = dictionary[keyPathComponent] as? UnboxableDictionary {
                    dictionary = nestedDictionary
                } else {
                    return nil
                }
            }
        }

        if let value = dictionary[key] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}

extension UnboxValueResolver where T: CollectionType {
    func resolveCollectionValuesForKey<R>(key: String, required: Bool, valueTransform: T.Generator.Element -> R?) -> [R] {
        if let unboxedArray = self.resolveOptionalValueForKey(key) {
            var transformedArray = [R]()
            
            for unboxedValue in unboxedArray {
                if let transformed = valueTransform(unboxedValue) {
                    transformedArray.append(transformed)
                } else if required {
                    self.unboxer.failForInvalidValue(unboxedValue, forKey: key)
                    return []
                }
            }
            
            return transformedArray
        } else if required {
            self.unboxer.failForInvalidValue(self.unboxer.dictionary[key], forKey: key)
        }
        
        return []
    }
}

extension UnboxValueResolver where T: CollectionType, T: DictionaryLiteralConvertible, T.Key: Hashable, T.Generator == DictionaryGenerator<T.Key, T.Value> {
    func resolveDictionaryValuesForKey<K, V>(key: String, required: Bool, keyTransform: (T.Key -> K?)? = nil, valueTransform: T.Value -> V?) -> [K : V] {
        if let unboxedDictionary = self.resolveOptionalValueForKey(key) {
            var transformedDictionary = [K : V]()
            
            for (unboxedKey, unboxedValue) in unboxedDictionary {
                let transformedKey: K?
                
                if let keyTransform = keyTransform {
                    transformedKey = keyTransform(unboxedKey)
                } else {
                    transformedKey = unboxedKey as? K
                }
                
                if let transformedKey = transformedKey, transformedValue = valueTransform(unboxedValue) {
                    transformedDictionary[transformedKey] = transformedValue
                } else if required {
                    self.unboxer.failForInvalidValue(unboxedValue, forKey: key)
                    return [:]
                }
            }
            
            return transformedDictionary
        } else if required {
            self.unboxer.failForInvalidValue(self.unboxer.dictionary[key], forKey: key)
        }
        
        return [:]
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
