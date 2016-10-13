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
