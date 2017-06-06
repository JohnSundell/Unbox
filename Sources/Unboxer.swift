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
    
    /// Takes care of logging warnings found during the unbox.
    /// Warnings are not fatal as errors, they just indicate that something is wrong.
    /// For instance, if we fail to unbox an optional key, we'll move forward but you'll receive a warning as this key was present but couldn't be parsed meaning that some data was lost.
    public static var warningLogger: UnboxWarningLogger?
    
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
        return try self.unbox(path: .key(key), transform: T.unbox, unboxedValueIsOptional: false)
    }

    /// Unbox a required collection by key
    public func unbox<T: UnboxableCollection>(key: String, allowInvalidElements: Bool) throws -> T {
        let transform = T.makeTransform(allowInvalidElements: allowInvalidElements)
        return try self.unbox(path: .key(key), transform: transform, unboxedValueIsOptional: false)
    }

    /// Unbox a required Unboxable type by key
    public func unbox<T: Unboxable>(key: String) throws -> T {
        return try self.unbox(path: .key(key), transform: T.makeTransform(), unboxedValueIsOptional: false)
    }

    /// Unbox a required UnboxableWithContext type by key
    public func unbox<T: UnboxableWithContext>(key: String, context: T.UnboxContext) throws -> T {
        return try self.unbox(path: .key(key), transform: T.makeTransform(context: context), unboxedValueIsOptional: false)
    }

    /// Unbox a required collection of UnboxableWithContext values by key
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(key: String, context: V.UnboxContext, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == V {
        return try self.unbox(path: .key(key), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: false)
    }

    /// Unbox a required value using a formatter by key
    public func unbox<F: UnboxFormatter>(key: String, formatter: F) throws -> F.UnboxFormattedType {
        return try self.unbox(path: .key(key), transform: formatter.makeTransform(), unboxedValueIsOptional: false)
    }

    /// Unbox a required collection of values using a formatter by key
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(key: String, formatter: F, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == F.UnboxFormattedType {
        return try self.unbox(path: .key(key), transform: formatter.makeCollectionTransform(allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: false)
    }

    // MARK: - Unboxing required values (by key path)

    /// Unbox a required value by key path
    public func unbox<T: UnboxCompatible>(keyPath: String) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.unbox, unboxedValueIsOptional: true)
    }

    /// Unbox a required collection by key path
    public func unbox<T: UnboxCompatible>(keyPath: String, allowInvalidElements: Bool) throws -> T where T: Collection {
        let transform = T.makeTransform(allowInvalidElements: allowInvalidElements)
        return try self.unbox(path: .keyPath(keyPath), transform: transform, unboxedValueIsOptional: true)
    }

    /// Unbox a required Unboxable by key path
    public func unbox<T: Unboxable>(keyPath: String) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.makeTransform(), unboxedValueIsOptional: true)
    }

    /// Unbox a required UnboxableWithContext type by key path
    public func unbox<T: UnboxableWithContext>(keyPath: String, context: T.UnboxContext) throws -> T {
        return try self.unbox(path: .keyPath(keyPath), transform: T.makeTransform(context: context), unboxedValueIsOptional: true)
    }

    /// Unbox a required collection of UnboxableWithContext values by key path
    public func unbox<C: UnboxableCollection, V: UnboxableWithContext>(keyPath: String, context: V.UnboxContext, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == V {
        return try self.unbox(path: .keyPath(keyPath), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: true)
    }

    /// Unbox a required value using a formatter by key path
    public func unbox<F: UnboxFormatter>(keyPath: String, formatter: F) throws -> F.UnboxFormattedType {
        return try self.unbox(path: .keyPath(keyPath), transform: formatter.makeTransform(), unboxedValueIsOptional: true)
    }

    /// Unbox a required collection of values using a formatter by key path
    public func unbox<C: UnboxableCollection, F: UnboxFormatter>(keyPath: String, formatter: F, allowInvalidElements: Bool = false) throws -> C where C.UnboxValue == F.UnboxFormattedType {
        return try self.unbox(path: .keyPath(keyPath), transform: formatter.makeCollectionTransform(allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: true)
    }

    // MARK: - Unboxing optional values (by key)

    /// Unbox an optional value by key
    public func unbox<T: UnboxCompatible>(key: String) -> T? {
        do {
            return try unbox(key: key) as T
        } catch {
            (error as? UnboxError)?.logAsWarningForOptionalValueIfNeeded()
            return nil
        }
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
        return try? self.unbox(path: .key(key), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: true)
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
        return try? self.unbox(path: .keyPath(keyPath), transform: V.makeCollectionTransform(context: context, allowInvalidElements: allowInvalidElements), unboxedValueIsOptional: true)
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

// MARK: - Internal

internal extension Unboxer {
    func performUnboxing<T: Unboxable>() throws -> T {
        return try T(unboxer: self)
    }

    func performUnboxing<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try T(unboxer: self, context: context)
    }
}

// MARK: - Private

private extension Unboxer {
    func unbox<R>(path: UnboxPath, transform: UnboxTransform<R>, unboxedValueIsOptional isOptional: Bool) throws -> R {
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
            var processedError: UnboxError? = nil
            
            if let publicError = error as? UnboxError {
                processedError = publicError
            } else if let pathError = error as? UnboxPathError {
                processedError = UnboxError.pathError(pathError, path.description)
            }
            
            // log a warning only if we have a processed error
            if let processedError = processedError,
                isOptional,
                processedError.isOptionalKeyFailedtoUnboxWarning {
                
                let warning = UnboxWarning.optionalKeyFailedToUnbox(error: processedError)
                Unboxer.warningLogger?.log(warning: warning)
                
            }

            throw processedError ?? error
        }
    }

    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(self).orThrow(UnboxError.customUnboxingFailed)
    }
}

private extension UnboxError {
    
    /// When unboxing an optional value, an error is generated
    /// If the key was present in the dictionary we want to log this error as a warning
    func logAsWarningForOptionalValueIfNeeded() {
        guard isOptionalKeyFailedtoUnboxWarning else {
            return
        }
        
        let warning = UnboxWarning.optionalKeyFailedToUnbox(error: self)
        Unboxer.warningLogger?.log(warning: warning)
    }
    
}
