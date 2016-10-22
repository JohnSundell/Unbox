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

internal extension UnboxCompatible {
    static func unbox(value: Any) throws -> Self? {
        return try self.unbox(value: value, allowInvalidCollectionElements: false)
    }
}

internal extension UnboxCompatible where Self: Collection {
    static func makeTransform(allowInvalidElements: Bool) -> UnboxTransform<Self> {
        return {
            try self.unbox(value: $0, allowInvalidCollectionElements: allowInvalidElements)
        }
    }
}

internal extension Unboxable {
    static func makeTransform() -> UnboxTransform<Self> {
        return { try ($0 as? UnboxableDictionary).map(unbox) }
    }
}

internal extension UnboxableWithContext {
    static func makeTransform(context: UnboxContext) -> UnboxTransform<Self> {
        return {
            try ($0 as? UnboxableDictionary).map {
                try unbox(dictionary: $0, context: context)
            }
        }
    }

    static func makeCollectionTransform<C: UnboxableCollection>(context: UnboxContext, allowInvalidElements: Bool) -> UnboxTransform<C> where C.UnboxValue == Self {
        return {
            return try ($0 as? C.UnboxRawCollection).map {
                return try C.unbox(collection: $0,
                                   allowInvalidElements: allowInvalidElements,
                                   transform: self.makeTransform(context: context))
            }
        }
    }
}

internal extension UnboxFormatter {
    func makeTransform() -> UnboxTransform<UnboxFormattedType> {
        return { ($0 as? UnboxRawValue).map(self.format) }
    }

    func makeCollectionTransform<C: UnboxableCollection>(allowInvalidElements: Bool) -> UnboxTransform<C> where C.UnboxValue == UnboxFormattedType {
        return {
            return try ($0 as? C.UnboxRawCollection).map {
                return try C.unbox(collection: $0,
                                   allowInvalidElements: allowInvalidElements,
                                   transform: self.makeTransform())
            }
        }
    }
}

internal extension Unboxer {
    func unbox<R>(path: UnboxPath, transform: UnboxTransform<R>) throws -> R {
        var currentMode = UnboxingMode.dictionary(self.dictionary)
        let components = path.components
        let lastKey = try components.last.orThrow(.emptyKeyPath)

        for key in components {
            switch currentMode {
            case .dictionary(let dictionary):
                currentMode = try UnboxingMode(value: dictionary[key].orThrow(.missingValue(key)))
            case .array(let array):
                guard let index = Int(key), index < array.count else {
                    throw UnboxError.missingValue(key)
                }

                currentMode = UnboxingMode(value: array[index])
            case .value(let value):
                throw UnboxError.invalidValue(value, key)
            }
        }

        return try transform(currentMode.value).orThrow(UnboxError.invalidValue(currentMode.value, lastKey))
    }

    func performUnboxing<T: Unboxable>() throws -> T {
        return try T(unboxer: self)
    }

    func performUnboxing<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try T(unboxer: self, context: context)
    }

    func performCustomUnboxing<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(self).orThrow(.customUnboxingFailed)
    }
}

internal extension Optional {
    func map<T>(_ transform: (Wrapped) throws -> T?) rethrows -> T? {
        guard let value = self else {
            return nil
        }

        return try transform(value)
    }

    func orThrow(_ errorClosure: @autoclosure () -> UnboxError) throws -> Wrapped {
        guard let value = self else {
            throw errorClosure()
        }

        return value
    }
}

internal extension JSONSerialization {
    static func unbox<T>(data: Data, options: ReadingOptions = []) throws -> T {
        do {
            return try (self.jsonObject(with: data, options: options) as? T).orThrow(.invalidData)
        } catch {
            throw UnboxError.invalidData
        }
    }
}

internal extension Data {
    func unbox<T: Unboxable>() throws -> T {
        return try Unboxer(data: self).performUnboxing()
    }

    func unbox<T: UnboxableWithContext>(context: T.UnboxContext) throws -> T {
        return try Unboxer(data: self).performUnboxing(context: context)
    }

    func unbox<T>(closure: (Unboxer) throws -> T?) throws -> T {
        return try closure(Unboxer(data: self)).orThrow(.customUnboxingFailed)
    }

    func unbox<T: Unboxable>(allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])
        return try array.map(allowInvalidElements: allowInvalidElements, transform: Unbox.unbox)
    }

    func unbox<T: UnboxableWithContext>(context: T.UnboxContext, allowInvalidElements: Bool) throws -> [T] {
        let array: [UnboxableDictionary] = try JSONSerialization.unbox(data: self, options: [.allowFragments])

        return try array.map(allowInvalidElements: allowInvalidElements) {
            try Unbox.unbox(dictionary: $0, context: context)
        }
    }
}
