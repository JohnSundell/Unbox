/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/**
 *  Extension adding unboxing methods to `Data`
 *
 *  The methods in this extension are your top level entry points into Unbox's API
 *  For usage and examples, see https://github.com/johnsundell/unbox
 */
public extension Data {
    /**
     *   Unbox this data into an `Unboxable` type
     *
     *  - parameter path: Optionally begin unboxing at a given path within the data
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: Unboxable>(at path: UnboxPath? = nil) throws -> T {
        return try Unboxer(data: self).performUnboxing(at: path)
    }

    /**
     *  Unbox this data into an `UnboxableWithContext` type
     *
     *  - parameter context: The context to use during unboxing, as required by the type
     *  - parameter path: Optionally begin unboxing at a given path within the data
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: UnboxableWithContext>(with context: T.UnboxContext, at path: UnboxPath? = nil) throws -> T {
        return try Unboxer(data: self).performUnboxing(with: context, at: path)
    }

    /**
     *  Unbox this data into an array of an `Unboxable` type
     *
     *  - parameter path: Optionally begin unboxing at a given path within the data
     *  - parameter allowInvalidElements: Optionally skip invalid elements instead of throwing
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: Unboxable>(at path: UnboxPath? = nil, allowInvalidElements: Bool = false) throws -> [T] {
        if let path = path {
            return try Unboxer(data: self).unbox(at: path, allowInvalidElements: allowInvalidElements)
        }

        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])

        return try array.map(allowInvalidElements: allowInvalidElements) { dictionary in
            return try dictionary.unboxed()
        }
    }

    /**
     *  Unbox this data into an array of an `UnboxableWithContext` type
     *
     *  - parameter context: The context to use during unboxing, as required by the type
     *  - parameter path: Optionally begin unboxing at a given path within the data
     *  - parameter allowInvalidElements: Optionally skip invalid elements instead of throwing
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T: UnboxableWithContext>(with context: T.UnboxContext, at path: UnboxPath? = nil, allowInvalidElements: Bool = false) throws -> [T] {
        if let path = path {
            return try Unboxer(data: self).unbox(at: path, context: context, allowInvalidElements: allowInvalidElements)
        }

        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])

        return try array.map(allowInvalidElements: allowInvalidElements) { dictionary in
            return try dictionary.unboxed(with: context)
        }
    }

    /**
     *  Unbox this data into a custom type using a closure
     *
     *  - parameter closure: A closure to use for unboxing, takes an `Unboxer´ as input
     *  - throws: `UnboxError` if the unboxing failed
     */
    func unboxed<T>(using closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(Unboxer(data: self)).orThrow(UnboxError.customUnboxingFailed)
    }
}
