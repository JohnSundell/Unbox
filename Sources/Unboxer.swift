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
