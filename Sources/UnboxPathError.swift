/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/// Type for errors that can occur while unboxing a certain path
public enum UnboxPathError: Error {
    /// An empty key path was given
    case emptyKeyPath
    /// A required key was missing (contains the key)
    case missingKey(String)
    /// An invalid value was found (contains the value, its key, and the expected type)
    case invalidValue(Any, String, Any.Type)
    /// An invalid collection element type was found (contains the type)
    case invalidCollectionElementType(Any)
    /// An invalid array element was found (contains the element, and its index)
    case invalidArrayElement(Any, Int, Any.Type)
    /// An invalid dictionary key type was found (contains the type)
    case invalidDictionaryKeyType(Any)
    /// An invalid dictionary key was found (contains the key)
    case invalidDictionaryKey(Any)
    /// An invalid dictionary value was found (contains the value, its key, and the expected type)
    case invalidDictionaryValue(Any, String, Any.Type)
}

extension UnboxPathError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyKeyPath:
            return "Key path can't be empty."
        case .missingKey(let key):
            return "The key \"\(key)\" is missing."
        case .invalidValue(let value, let key, let expectedType):
            return "Invalid value (\(value)) for key \"\(key)\", JSON type \(type(of: value)) cannot be unboxed as \(expectedType)"
        case .invalidCollectionElementType(let type):
            return "Invalid collection element type: \(type). Must be UnboxCompatible or Unboxable."
        case .invalidArrayElement(let element, let index, let expectedType):
            return "Invalid array element (\(element)) at index \(index), JSON type \(type(of: element)) cannot be unboxed as \(expectedType)"
        case .invalidDictionaryKeyType(let type):
            return "Invalid dictionary key type: \(type). Must be either String or UnboxableKey."
        case .invalidDictionaryKey(let key):
            return "Invalid dictionary key: \(key)."
        case .invalidDictionaryValue(let value, let key, let expectedType):
            return "Invalid dictionary value (\(value)) for key \"\(key)\", JSON type \(type(of: value)) cannot be unboxed as \(expectedType)"
        }
    }
}
