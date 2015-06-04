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
 *
 *  @discussion This function gets its return type from the context in which it's called.
 *  If the context is ambigious, you need to supply it, like:
 *
 *  `let unboxed: MyUnboxable? = Unbox(dictionary)`
 *
 *  @return A model of type `T` or `nil` if an error was occured. If you wish to know more
 *  about any error, use: `Unbox(dictionary, logErrors: true)`
 */
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary) -> T? {
    return Unbox(dictionary, logErrors: false)
}

/**
 *  Unbox (decode) a dictionary into a model, optionally logging any error that occured
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param logErrors Whether any encountered error should be logged to the console
 *
 *  @idscussion See the documentation for the main Unbox() function above for more information.
 */
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, #logErrors: Bool) -> T? {
    let unboxer = Unboxer(dictionary)
    let unboxed = T(unboxer: unboxer)
    
    if let failureInfo = unboxer.failureInfo {
        if logErrors {
            var failureMessage = "Unbox: Failed to unbox dictionary for type: \(T.self). "
            
            if let failedValue: AnyObject = failureInfo.value {
                failureMessage.extend("Invalid value found (\(failedValue)) for key: \(failureInfo.key)")
            } else {
                failureMessage.extend("Missing value for key: \(failureInfo.key)")
            }
            
            println(failureMessage)
        }
        
        return nil
    }
    
    return unboxed
}

/**
 *  Unbox (decode) a set of data into a model
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *
 *  @discussion See the documentation for the main Unbox(dictionary:) function above for more information.
 */
public func Unbox<T: Unboxable>(data: NSData) -> T? {
    return Unbox(data, logErrors: false)
}

/**
 *  Unbox (decode) a set of data into a model, optionally logging any error that occured
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *
 *  @discussion See the documentation for the main Unbox(dictionary:) function above for more information.
 */
public func Unbox<T: Unboxable>(data: NSData, #logErrors: Bool) -> T? {
    var dataDecodingError: NSError?
    
    if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &dataDecodingError) as? UnboxableDictionary {
        return Unbox(dictionary, logErrors: logErrors)
    }
    
    if logErrors {
        println("Unbox: Failed to convert data into a Unboxable Dictionary. Error: \(dataDecodingError)")
    }
    
    return nil
}

// MARK: - Protocols

/// Protocol used to declare a model as being Unboxable, for use with the Unbox() function
public protocol Unboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an Unboxer
    init(unboxer: Unboxer)
}

/// Protocol used to enable a raw type for Unboxing. See default implementations further down.
public protocol UnboxableRawType {
    /// The value to use for required properties if unboxing failed. This value will never be returned to the API user.
    static func fallbackValue() -> Self
}

/// Protocol used to declare a model as being Unboxable by using a transformer
public protocol UnboxableByTransform {
    /// The transformer type to use. See UnboxTransformer for more information.
    typealias UnboxTransformerType: UnboxTransformer
}

/// Protocol for objects that can act as Unboxing transformers, turning an unboxed value into its final form
public protocol UnboxTransformer {
    /// The raw unboxed type this transformer expects as input
    typealias RawType
    /// The transformed type this transformer outputs
    typealias TransformedType
    
    /// Attempt to transformed an unboxed value, returning non-`nil` if successful
    static func transformUnboxedValue(unboxedValue: RawType) -> TransformedType?
    /// The value to use for required properties if unboxing or transformation failed. This value will never be returned to the API user.
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
    
    public static func transformUnboxedValue(unboxedValue: RawType) -> TransformedType? {
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

/**
 *  Class used to Unbox (decode) values from a dictionary
 *
 *  For each supported type, simply call `unbox(key)` and the correct type will be returned. If a required (non-optional)
 *  value couldn't be unboxed, the Unboxer will be marked as failed, and a `nil` value will be returned from the `Unbox()`
 *  function that triggered the Unboxer.
 *
 *  An Unboxer may also be manually failed, by using the `failForKey()` or `failForInvalidValue(forKey:)` APIs.
 */
public class Unboxer {
    /// Whether the Unboxer has failed, and a `nil` value will be returned from the `Unbox()` function that triggered it.
    public var hasFailed: Bool { return self.failureInfo != nil }
    
    private var failureInfo: (key: String, value: AnyObject?)?
    private let dictionary: UnboxableDictionary
    
    // MARK: - Private initializer
    
    private init(_ dictionary: UnboxableDictionary) {
        self.dictionary = dictionary
    }
    
    // MARK: - Public API
    
    /// Unbox a required raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T {
        return UnboxValueResolver<T>(self).resolveRequiredValueForKey(key, fallbackValue: T.fallbackValue())
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
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: T(unboxer: self), transform: {
            return Unbox($0)
        })
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key, transform: {
            return Unbox($0)
        })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T] {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key, fallbackValue: [], transform: {
            return self.transformUnboxableDictionaryArray($0, forKey: key, required: true)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key, transform: {
            return self.transformUnboxableDictionaryArray($0, forKey: key, required: false)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T] {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: [:], transform: {
            return self.transformUnboxableDictionaryDictionary($0, required: true)
        })
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T]? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key, transform: {
            return self.transformUnboxableDictionaryDictionary($0, required: false)
        })
    }
    
    /// Unbox a required value that can be transformed into its final form. Usable for types that have an `UnboxTransformer`
    public func unbox<T: UnboxableByTransform where T == T.UnboxTransformerType.TransformedType>(key: String) -> T {
        return UnboxValueResolver<T.UnboxTransformerType.RawType>(self).resolveRequiredValueForKey(key, fallbackValue: T.UnboxTransformerType.fallbackValue(), transform: {
            return T.UnboxTransformerType.transformUnboxedValue($0)
        })
    }
    
    /// Unbox an optional value that can be transformed into its final form. Usable for types that have an `UnboxTransformer`
    public func unbox<T: UnboxableByTransform where T == T.UnboxTransformerType.TransformedType>(key: String) -> T.UnboxTransformerType.TransformedType? {
        return UnboxValueResolver<T.UnboxTransformerType.RawType>(self).resolveOptionalValueForKey(key, transform: {
            return T.UnboxTransformerType.transformUnboxedValue($0)
        })
    }
    
    /// Cause this Unboxer to fail for a certain key. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForKey(key: String) {
        self.failForInvalidValue(nil, forKey: key)
    }
    
    /// Cause this Unboxer to fail for a certain key and invalid value. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForInvalidValue(invalidValue: AnyObject?, forKey key: String) {
        self.failureInfo = (key, invalidValue)
    }
    
    // MARK: - Private utilities
    
    private func transformUnboxableDictionaryArray<T: Unboxable>(dictionaries: [UnboxableDictionary], forKey key: String, required: Bool) -> [T]? {
        var transformed = [T]()
        
        for dictionary in dictionaries {
            if let unboxed: T = Unbox(dictionary) {
                transformed.append(unboxed)
            } else if required {
                self.failForInvalidValue(dictionaries, forKey: key)
            }
        }
        
        return transformed
    }
    
    private func transformUnboxableDictionaryDictionary<T: Unboxable>(dictionaries: UnboxableDictionary, required: Bool) -> [String : T]? {
        var transformed = [String : T]()
        
        for (key, dictionary) in dictionaries {
            if let unboxableDictionary = dictionary as? UnboxableDictionary {
                if let unboxed: T = Unbox(unboxableDictionary) {
                    transformed[key] = unboxed
                    continue
                }
            }
            
            if required {
                self.failForInvalidValue(dictionary, forKey: key)
            }
        }
        
        return transformed
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
    
    func resolveOptionalValueForKey<R>(key: String, transform: T -> R?) -> R? {
        if let value = self.unboxer.dictionary[key] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}
