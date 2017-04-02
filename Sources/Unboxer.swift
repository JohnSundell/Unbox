/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

// MARK: - Public

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
        return try data.unboxed(using: closure)
    }

    // MARK: - Required values

    /// Unbox a required value
    public func unbox<T: UnboxCompatible>(at path: UnboxPath) throws -> T {
        return try self.unbox(path: path, transform: T.unbox)
    }

    /// Unbox a required collection
    public func unbox<T: UnboxableCollection>(at path: UnboxPath, allowInvalidElements: Bool) throws -> T {
        let transform = T.makeTransform(allowInvalidElements: allowInvalidElements)
        return try self.unbox(path: path, transform: transform)
    }

    /// Unbox a required `Unboxable` type
    public func unbox<T: Unboxable>(at path: UnboxPath) throws -> T {
        return try self.unbox(path: path, transform: T.makeTransform())
    }

    /// Unbox a required `UnboxableWithContext` type
    public func unbox<T: UnboxableWithContext>(at path: UnboxPath, context: T.UnboxContext) throws -> T {
        return try self.unbox(path: path, transform: T.makeTransform(context: context))
    }

    /// Unbox a required collection of `UnboxableWithContext` values
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(at path: UnboxPath, context: V.UnboxContext, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == V {
        return try self.unbox(path: path, transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements))
    }

    /// Unbox a required value using a formatter
    public func unbox<F: UnboxFormatter>(at path: UnboxPath, formatter: F) throws -> F.UnboxFormattedType {
        return try self.unbox(path: path, transform: formatter.makeTransform())
    }

    /// Unbox a required collection of values using a formatter
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(at path: UnboxPath, formatter: F, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == F.UnboxFormattedType {
        return try self.unbox(path: path, transform: formatter.makeCollectionTransform(allowInvalidElements: allowInvalidElements))
    }

    // MARK: - Optional values

    /// Unbox an optional value
    public func unbox<T: UnboxCompatible>(at path: UnboxPath) -> T? {
        return try? self.unbox(at: path)
    }

    /// Unbox an optional collection
    public func unbox<T: UnboxableCollection>(at path: UnboxPath, allowInvalidElements: Bool) -> T? {
        return try? self.unbox(at: path, allowInvalidElements: allowInvalidElements)
    }

    /// Unbox an optional `Unboxable` type
    public func unbox<T: Unboxable>(at path: UnboxPath) -> T? {
        return try? self.unbox(at: path)
    }

    /// Unbox an optional `UnboxableWithContext` type
    public func unbox<T: UnboxableWithContext>(at path: UnboxPath, context: T.UnboxContext) -> T? {
        return try? self.unbox(at: path, context: context)
    }

    /// Unbox an optional collection of `UnboxableWithContext` values
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(at path: UnboxPath, context: V.UnboxContext, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == V {
        return try? self.unbox(at: path, context: context, allowInvalidElements: allowInvalidElements)
    }

    /// Unbox an optional value using a formatter
    public func unbox<F: UnboxFormatter>(at path: UnboxPath, formatter: F) -> F.UnboxFormattedType? {
        return try? self.unbox(at: path, formatter: formatter)
    }

    /// Unbox an optional collection of values using a formatter
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(at path: UnboxPath, formatter: F, allowInvalidElements: Bool = false) -> C? where C.UnboxValue == F.UnboxFormattedType {
        return try? self.unbox(at: path, formatter: formatter, allowInvalidElements: allowInvalidElements)
    }
}

// MARK: - Internal

internal extension Unboxer {
    func performUnboxing<T: Unboxable>(at path: UnboxPath? = nil) throws -> T {
        if let path = path {
            return try unbox(at: path)
        }

        return try T(unboxer: self)
    }

    func performUnboxing<T: UnboxableWithContext>(with context: T.UnboxContext,
                                                  at path: UnboxPath? = nil) throws -> T {
        if let path = path {
            return try unbox(at: path, context: context)
        }

        return try T(unboxer: self, context: context)
    }
}

// MARK: - Private

private extension Unboxer {
    func unbox<R>(path: UnboxPath, transform: UnboxTransform<R>) throws -> R {
        do {
            switch path {
            case .key(let key):
                let value = try self.dictionary[key].orThrow(UnboxPathError.missingKey(key))
                return try transform(value).orThrow(UnboxPathError.invalidValue(value, key))
            case .keys(let keys):
                return try unbox(at: keys, transform: transform)
            case .keyPath(let keyPath):
                let keys = keyPath.components(separatedBy: ".")
                return try unbox(at: keys, transform: transform)
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

    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(self).orThrow(UnboxError.customUnboxingFailed)
    }

    private func unbox<R>(at keys: [String], transform: UnboxTransform<R>) throws -> R {
        var node: UnboxPathNode = self.dictionary
        let lastKey = keys.last

        for key in keys {
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
}
