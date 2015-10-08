/**
 *  Unbox - the easy to use Swift JSON decoder
 *
 *  For usage, see documentation of the classes/symbols listed in this file, as
 *  well as the guide available at: github.com/johnsundell/unbox
 *
 *  Copyright (c) 2015 John Sundell. Manfred Lau. 
 *  Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to 
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in 
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 */

import Foundation

/// Type alias defining what type of Dictionary that is Unboxable (valid JSON)
public typealias UnboxableDictionary    = [String : AnyObject]

/// Type alias defining what type of Array that is Unboxable (valid JSON)
public typealias UnboxableArray         = [UnboxableDictionary]

// MARK: - Main Unbox functions

/**
 *  Unbox (decode) a dictionary into a model
 *
 *  @param      dictionary  The dictionary to decode. Must be a valid JSON
 *  dictionary.
 *  @param      context     Any contextual object that should be available
 *  during unboxing.
 *
 *  @discussion This function gets its return type from the context in which 
 *  it's called.
 *  If the context is ambigious, you need to supply it, like:
 *
 *  `let unboxed: MyUnboxable? = Unbox(dictionary)`
 *
 *  @return     A model of type `T` or `nil` if an error was occured. If you
 *  wish to know more about any error, use: `Unbox(dictionary, logErrors: true)`
 */
public func Unbox<T: DictionaryUnboxable>(dictionary: UnboxableDictionary,
    context: AnyObject? = nil)
    -> T?
{
    do {
        let unboxed: T = try UnboxOrThrow(dictionary, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) an array into a model
 *
 *  @param      array       The array to decode. Must be a valid JSON array.
 *  @param      context     Any contextual object that should be available 
 *  during unboxing.
 *
 *  @discussion This function gets its return type from the context in which
 *  it's called.
 *  If the context is ambigious, you need to supply it, like:
 *
 *  `let unboxed: MyUnboxable? = Unbox(array)`
 *
 *  @return     A model of type `T` or `nil` if an error was occured. If you
 *  wish to know more about any error, use: `Unbox(array, logErrors: true)`
*/
public func Unbox<T: ArrayUnboxable>(array: UnboxableArray,
    context: AnyObject? = nil)
    -> T?
{
    do {
        let unboxed: T = try UnboxOrThrow(array, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a set of data into a model
 *
 *  @param      data        The data to decode. Must be convertible into a valid
 *  JSON dictionary.
 *  @param      context     Any contextual object that should be available 
 *  during unboxing.
 *
 *  @discussion See the documentation for the main Unbox(dictionary:) function 
 *  above for more information.
 */
public func Unbox<T: DictionaryUnboxable>(data: NSData,
    context: AnyObject? = nil)
    -> T?
{
    do {
        let unboxed: T = try UnboxOrThrow(data, context: context)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a set of data into a model
 *
 *  @param      data        The data to decode. Must be convertible into a valid
 *  JSON array.
 *  @param      context     Any contextual object that should be available
 *  during unboxing.
 *
 *  @discussion See the documentation for the main Unbox(array:) function above
 *  for more information.
*/
public func Unbox<T: ArrayUnboxable>(data: NSData,
    context: AnyObject? = nil)
    -> T?
{
    do {
        let unboxed: T = try UnboxOrThrow(data, context: context)
        return unboxed
    } catch {
        return nil
    }
}

// MARK: - Unbox functions with error handling
/**
 *  Unbox (decode) a dictionary into a model, or throw an UnboxError if the 
 *  operation failed
 *
 *  @param      dictionary  The dictionary to decode. Must be a valid JSON
 *  dictionary.
 *  @param      context     Any contextual object that should be available 
 *  during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied dictionary 
 *  couldn't be decoded for any reason. See the documentation for the main 
 *  Unbox() function above for more information.
 */
public func UnboxOrThrow<T: DictionaryUnboxable>(
    dictionary: UnboxableDictionary,
    context: AnyObject? = nil)
    throws
    -> T
{
    let unboxer = DictionaryUnboxer(dictionary: dictionary, context: context)
    let unboxed = T(unboxer: unboxer)
    
    if let failureInfo = unboxer.failureInfo {
        if let failedValue: AnyObject = failureInfo.value {
            throw UnboxError.InvalidKeyValue(failureInfo.key, "\(failedValue)")
        }
        
        throw UnboxError.MissingKey(failureInfo.key)
    }
    
    return unboxed
}

/**
 *  Unbox (decode) an array into a model, or throw an UnboxError if the 
 *  operation failed
 *
 *  @param      array       The array to decode. Must be a valid JSON array.
 *  @param      context     Any contextual object that should be available 
 *  during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied array 
 *  couldn't be decoded for any reason. See the documentation for the main 
 *  Unbox() function above for more information.
 */
public func UnboxOrThrow<T: ArrayUnboxable>(array: UnboxableArray,
    context: AnyObject? = nil)
    throws
    -> T
{
    let unboxer = ArrayUnboxer(array: array, context: context)
    let unboxed = T(unboxer: unboxer)
    
    if let failureInfo = unboxer.failureInfo {
        throw UnboxError.InvalidValue("\(failureInfo)")
    }
    
    return unboxed
}

/**
 *  Unbox (decode) a set of data into a model, or throw an UnboxError if the
 *  operation failed
 *
 *  @param      data        The data to decode. Must be convertible into a valid
 *  JSON dictionary.
 *  @param      context     Any contextual object that should be available 
 *  during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied data couldn't
 *  be decoded for any reason. See the documentation for the main Unbox() 
 *  function above for more information.
 */
public func UnboxOrThrow<T: DictionaryUnboxable>(data: NSData,
    context: AnyObject? = nil)
    throws
    -> T
{
    let rawJSONObject = try NSJSONSerialization
        .JSONObjectWithData(data, options: [])
    
    if let dictionary = rawJSONObject as? UnboxableDictionary {
        return try UnboxOrThrow(dictionary)
    }
    
    throw UnboxError.InvalidDictionary
}

public func UnboxOrThrow<T: ArrayUnboxable>(data: NSData,
    context: AnyObject? = nil)
    throws
    -> T
{
    let rawJSONObject = try NSJSONSerialization
        .JSONObjectWithData(data, options: [])
    
    if let array = rawJSONObject as? UnboxableArray {
        return try UnboxOrThrow(array)
    }
    
    throw UnboxError.InvalidDictionary
}

// MARK: - Error type

/// Enum describing errors that can occur during unboxing. Use the throwing
/// functions to receive any errors.
public enum UnboxError: ErrorType, CustomStringConvertible {
    public var description: String {
        let baseDescription = "[Unbox error] "
        
        switch self {
        case .MissingKey(let key):
            return baseDescription + "Missing key (\(key))"
        case .InvalidKeyValue(let key, let valueDescription):
            return baseDescription
                + "Invalid value (\(valueDescription)) for key (\(key))"
        case .InvalidValue(let valueDescription):
            return baseDescription + "Invalid value (\(valueDescription))"
        case .InvalidDictionary:
            return "Invalid dictionary"
        }
    }
    
    /// Thrown when a required key was missing in an unboxed dictionary. 
    /// Contains the missing key.
    case MissingKey(String)
    /// Thrown when a required key contained an invalid value in an unboxed 
    /// dictionary. Contains the invalid key and a description of the invalid
    /// data.
    case InvalidKeyValue(String, String)
    /// Thrown when an array contained an invalid value in an unboxed array.
    /// Contains the description of the invalid data.
    case InvalidValue(String)
    /// Thrown when an unboxed dictionary was either missing or contained 
    /// invalid data
    case InvalidDictionary
}

// MARK: - Protocols
/// Protocol used to declare a model as being DictionaryUnboxable, for use with
/// the Unbox() function
public protocol DictionaryUnboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an 
    /// DictionaryUnboxer
    init(unboxer: DictionaryUnboxer)
}

/// Protocol used to declare a model as being ArrayUnboxable, for use with the
/// Unbox() function
public protocol ArrayUnboxable {
    /// Initialize an instance of this model by unboxing an array using an 
    /// ArrayUnboxer
    init(unboxer: ArrayUnboxer)
}

/// Protocol used to enable a raw type for Unboxing. See default implementations
/// further down.
public protocol UnboxableRawType {
    /// The value to use for required properties if unboxing failed. This value
    /// will never be returned to the API user.
    static func fallbackValue() -> Self
}

/// Protocol used to declare a model as being Unboxable by using a transformer
public protocol UnboxableByTransform {
    /// The transformer type to use. See UnboxTransformer for more information.
    typealias UnboxTransformerType: UnboxTransformer
}

/// Protocol for objects that can act as Unboxing transformers, turning an 
/// unboxed value into its final form
public protocol UnboxTransformer {
    /// The raw unboxed type this transformer accepts as input
    typealias RawType
    /// The transformed type this transformer outputs
    typealias TransformedType
    
    /// Attempt to transformed an unboxed value, returning non-`nil` if
    /// successful
    static func transformUnboxedValue(unboxedValue: RawType) -> TransformedType?
    
    /// The value to use for required properties if unboxing or transformation 
    /// failed. This value will never be returned to the API user.
    static func fallbackValue() -> TransformedType
}

// MARK: - Raw types

/// Protocol making Bool an Unboxable raw type
extension Bool: UnboxableRawType {
    public static func fallbackValue() -> Bool {
        return false
    }
}

/// Protocol making Int an Unboxable raw type
extension Int: UnboxableRawType {
    public static func fallbackValue() -> Int {
        return 0
    }
}

/// Protocol making Double an Unboxable raw type
extension Double: UnboxableRawType {
    public static func fallbackValue() -> Double {
        return 0
    }
}

/// Protocol making Float an Unboxable raw type
extension Float: UnboxableRawType {
    public static func fallbackValue() -> Float {
        return 0
    }
}

/// Protocol making String an Unboxable raw type
extension String: UnboxableRawType {
    public static func fallbackValue() -> String {
        return ""
    }
}

// MARK: - Default transformers

/// A transformer that is used to transform Strings into `NSURL` instances
public class UnboxURLTransformer: UnboxTransformer {
    public typealias RawType = String
    public typealias TransformedType = NSURL
    
    public static func transformUnboxedValue(unboxedValue: RawType)
        -> TransformedType?
    {
        return NSURL(string: unboxedValue)
    }
    
    public static func fallbackValue() -> TransformedType {
        return NSURL()
    }
}

/// Protocol making NSURL Unboxable by transform
extension NSURL: UnboxableByTransform {
    public typealias UnboxTransformerType = UnboxURLTransformer
}

// MARK: - Unboxer
// MARK: Unboxer Type
private protocol UnboxerType {
    /// Whether the Unboxer has failed, and a `nil` value will be returned
    /// from the `Unbox()` function that triggered it.
    var hasFailed: Bool { get }
    
    /// Any contextual object that was supplied when unboxing was started
    var context: AnyObject? { get }
}


// MARK: Array Unboxer
/**
 *  Class used to Unbox (decode) values from an array
 *
 *  For each supported type, simply call `unbox(key)` and the correct type will
 *  be returned. If a required (non-optional) value couldn't be unboxed, the
 *  Unboxer will be marked as failed, and a `nil` value will be returned from
 *  the `Unbox()` function that triggered the Unboxer.
 *
 *  An ArrayUnboxer may also be manually failed, by using the 
 * `failForInvalidValue()` API.
*/
public class ArrayUnboxer: UnboxerType {
    private let array: UnboxableArray
    
    public var hasFailed: Bool { return self.failureInfo != nil }
    public let context: AnyObject?
    
    private var failureInfo: UnboxableDictionary?
    
    // MARK: Private initializer
    private init(array: UnboxableArray, context: AnyObject?) {
        self.array = array; self.context = context
    }
    
    // MARK: Public APIs
    /// Unbox self as an array
    public func unbox<T: DictionaryUnboxable>() -> [T] {
        return array.flatMap { Unbox($0, context: self.context) }
    }
    
    public  func failForInvalidValue(value: UnboxableDictionary) {
        failureInfo = value
    }
}

// MARK: Dictionary Unboxer
/**
 *  Class used to Unbox (decode) values from a dictionary
 *
 *  For each supported type, simply call `unbox(key)` and the correct type will
 *  be returned. If a required (non-optional) value couldn't be unboxed, the 
 *  Unboxer will be marked as failed, and a `nil` value will be returned from 
 *  the `Unbox()` function that triggered the Unboxer.
 *
 *  An DictionaryUnboxer may also be manually failed, by using the 
 *  `failForKey()` or `failForInvalidValue(forKey:)` APIs.
 */
public class DictionaryUnboxer: UnboxerType {
    private let dictionary: UnboxableDictionary
    
    public var hasFailed: Bool { return self.failureInfo != nil }
    public let context: AnyObject?
    
    public private(set) var failureInfo: (key: String, value: AnyObject?)?
    
    // MARK: Private initializer
    private init(dictionary: UnboxableDictionary, context: AnyObject?) {
        self.dictionary = dictionary; self.context = context
    }
    
    // MARK: Public APIs
    /// Unbox a required raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T {
        return DictionaryUnboxValueResolver<T>(self)
            .resolveRequiredValueForKey(key, fallbackValue: T.fallbackValue())
    }
    
    /// Unbox an optional raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T? {
        return DictionaryUnboxValueResolver<T>(self)
            .resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required Array
    public func unbox<T>(key: String) -> [T] {
        return DictionaryUnboxValueResolver<[T]>(self)
            .resolveRequiredValueForKey(key, fallbackValue: [])
    }
    
    /// Unbox an optional Array
    public func unbox<T>(key: String) -> [T]? {
        return DictionaryUnboxValueResolver<[T]>(self)
            .resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required Dictionary
    public func unbox<T>(key: String) -> [String : T] {
        return DictionaryUnboxValueResolver<[String : T]>(self)
            .resolveRequiredValueForKey(key, fallbackValue: [:])
    }
    
    /// Unbox an optional Dictionary
    public func unbox<T>(key: String) -> [String : T]? {
        return DictionaryUnboxValueResolver<[String : T]>(self)
            .resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then 
    /// using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> T {
        return DictionaryUnboxValueResolver<UnboxableDictionary>(self)
            .resolveRequiredValueForKey(key,
                fallbackValue: T(unboxer: self),
                transform: {return Unbox($0, context: self.context)})
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then 
    /// using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> T? {
        return DictionaryUnboxValueResolver<UnboxableDictionary>(self)
            .resolveOptionalValueForKey(key,
                transform: { return Unbox($0, context: self.context) })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of 
    /// Dictionaries and then using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> [T] {
        return DictionaryUnboxValueResolver<[UnboxableDictionary]>(self)
            .resolveRequiredValueForKey(key,
                fallbackValue: [],
                transform: {
                    return self.transformUnboxableDictionaryToArray($0,
                        forKey: key, 
                        required: true)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of 
    /// Dictionaries and then using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> [T]? {
        return DictionaryUnboxValueResolver<[UnboxableDictionary]>(self)
            .resolveOptionalValueForKey(key,
                transform: {
                    return self.transformUnboxableDictionaryToArray($0,
                        forKey: key,
                        required: false)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an 
    /// Dictionary of Dictionaries and then using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> [String : T] {
        return DictionaryUnboxValueResolver<UnboxableDictionary>(self)
            .resolveRequiredValueForKey(key,
                fallbackValue: [:],
                transform: {
                    return self.transformUnboxableDictionaryToDictionary($0,
                        required: true)
        })
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an 
    /// Dictionary of Dictionaries and then using a transform
    public func unbox<T: DictionaryUnboxable>(key: String) -> [String : T]? {
        return DictionaryUnboxValueResolver<UnboxableDictionary>(self)
            .resolveOptionalValueForKey(key,
                transform: {
                    return self.transformUnboxableDictionaryToDictionary($0,
                        required: false)
        })
    }
    
    /// Unbox a required value that can be transformed into its final form. 
    /// Usable for types that have an `UnboxTransformer`
    public func unbox<T: UnboxableByTransform
        where T == T.UnboxTransformerType.TransformedType>
        (key: String)
        -> T
    {
        return DictionaryUnboxValueResolver
            <T.UnboxTransformerType.RawType>(self)
            .resolveRequiredValueForKey(key,
                fallbackValue: T.UnboxTransformerType.fallbackValue(),
                transform: {
                    return T.UnboxTransformerType.transformUnboxedValue($0)
        })
    }
    
    /// Unbox an optional value that can be transformed into its final form. 
    /// Usable for types that have an `UnboxTransformer`
    public func unbox<T: UnboxableByTransform
        where T == T.UnboxTransformerType.TransformedType>
        (key: String)
        -> T.UnboxTransformerType.TransformedType?
    {
        return DictionaryUnboxValueResolver
            <T.UnboxTransformerType.RawType>(self)
            .resolveOptionalValueForKey(key,
                transform: {
                    return T.UnboxTransformerType.transformUnboxedValue($0)
        })
    }
    
    /// Make this Unboxer to fail for a certain key. This will cause the 
    /// `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForKey(key: String) {
        self.failForInvalidValue(nil, forKey: key)
    }
    
    /// Make this Unboxer to fail for a certain key and invalid value. This will
    /// cause the `Unbox()` function that triggered this Unboxer to return 
    /// `nil`.
    public func failForInvalidValue(invalidValue: AnyObject?,
        forKey key: String)
    {
        self.failureInfo = (key, invalidValue)
    }
    
    // MARK: Private Utilities
    /// Return a required contextual object of type `T` attached to this 
    /// Unboxer, or cause the Unboxer to fail (using a dummy fallback value)
    private func requiredContextWithFallbackValue<T>(
        @autoclosure fallbackValue: () -> T)
        -> T
    {
        if let context = self.context as? T {
            return context
        }
        
        self.failForInvalidValue(self.context, forKey: "Unboxer.Context")
        
        return fallbackValue()
    }
    
    private func transformUnboxableDictionaryToArray<T: DictionaryUnboxable>(
        dictionaries: [UnboxableDictionary],
        forKey key: String,
        required: Bool)
        -> [T]?
    {
        var transformed = [T]()
        
        for dictionary in dictionaries {
            if let unboxed: T = Unbox(dictionary, context: self.context) {
                transformed.append(unboxed)
            } else if required {
                self.failForInvalidValue(dictionaries, forKey: key)
            }
        }
        
        return transformed
    }
    
    private func transformUnboxableDictionaryToDictionary
        <T: DictionaryUnboxable>
        (dictionaries: UnboxableDictionary,
        required: Bool)
        -> [String : T]?
    {
        var transformed = [String : T]()
        
        for (key, dictionary) in dictionaries {
            if let unboxableDictionary = dictionary as? UnboxableDictionary,
                unboxed: T = Unbox(unboxableDictionary, context: self.context)
            {
                transformed[key] = unboxed
                continue
            }
            
            if required {
                self.failForInvalidValue(dictionary, forKey: key)
            }
        }
        
        return transformed
    }
}

// MARK: - UnboxValueResolver
private class DictionaryUnboxValueResolver<T> {
    let unboxer: DictionaryUnboxer
    
    init(_ unboxer: DictionaryUnboxer) {
        self.unboxer = unboxer
    }
    
    func resolveRequiredValueForKey(key: String,
        @autoclosure fallbackValue: () -> T)
        -> T
    {
        return self.resolveRequiredValueForKey(key,
            fallbackValue: fallbackValue,
            transform: { return $0 })
    }
    
    func resolveRequiredValueForKey<R>(key: String,
        @autoclosure fallbackValue: () -> R,
        transform: T -> R?)
        -> R
    {
        if let value = self.resolveOptionalValueForKey(key,
            transform: transform)
        {
            return value
        }
        
        self.unboxer.failForInvalidValue(self.unboxer.dictionary[key],
            forKey: key)
        
        return fallbackValue()
    }
    
    func resolveOptionalValueForKey(key: String) -> T? {
        return self.resolveOptionalValueForKey(key, transform: {
            return $0
        })
    }
    
    func resolveOptionalValueForKey<R>(key: String, transform: T -> R?) -> R? {
        if let value = self.unboxer.dictionary[key] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}

