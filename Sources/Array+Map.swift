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

internal extension Array {
    func map<T>(allowInvalidElements: Bool, transform: (Element) throws -> T) throws -> [T] {
        return try self.flatMap {
            do {
                return try transform($0)
            } catch {
                if !allowInvalidElements {
                    throw error
                }

                return nil
            }
        }
    }

    func map<T>(allowInvalidElements: Bool, transform: (Element) throws -> T?) throws -> [T]? {
        var transformedArray = [T]()

        for element in self {
            do {
                guard let transformed = try transform(element) else {
                    if allowInvalidElements {
                        continue
                    }

                    return nil
                }

                transformedArray.append(transformed)
            } catch {
                if !allowInvalidElements {
                    throw error
                }
            }
        }
        
        return transformedArray
    }
}
