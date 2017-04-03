/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/**
 *  Extension adding unboxing methods to JSON-like dictionaries
 *
 *  The methods in this extension are your top level entry points into Unbox's API
 *  For usage and examples, see https://github.com/johnsundell/unbox
 */
extension Dictionary where Key == String {
    /**
     *  Unbox this dictionary into an `Unboxable` type
     *
     *  - parameter path: Optionally begin unboxing at a given path within the dictionary
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: Unboxable>(at path: UnboxPath? = nil) throws -> T {
        let unboxer = Unboxer(dictionary: self)
        return try unboxer.performUnboxing(at: path)
    }

    /**
     *  Unbox this dictionary into an `UnboxableWithContext` type
     *
     *  - parameter context: The context to use during unboxing, as required by the type
     *  - parameter path: Optionally begin unboxing at a given path within the dictionary
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: UnboxableWithContext>(with context: T.UnboxContext, at path: UnboxPath? = nil) throws -> T {
        let unboxer = Unboxer(dictionary: self)
        return try unboxer.performUnboxing(with: context, at: path)
    }

    /**
     *  Unbox the value for a path in this dictionary into an array of an `Unboxable` type
     *
     *  - parameter path: The path to begin unboxing at within this dictionary
     *  - parameter allowInvalidElements: Optionally skip invalid elements instead of throwing
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: Unboxable>(at path: UnboxPath, allowInvalidElements: Bool = false) throws -> [T] {
        let unboxer = Unboxer(dictionary: self)
        return try unboxer.unbox(at: path, allowInvalidElements: allowInvalidElements)
    }
}

/// Extension making `Dictionary` an unboxable collection
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

/// Extension making `Dictionary` an unbox path node
extension Dictionary: UnboxPathNode {
    func unboxPathValue(forKey key: String) -> Any? {
        return self[key as! Key]
    }
}

// MARK: - Utilities

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
