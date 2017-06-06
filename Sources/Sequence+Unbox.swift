/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

internal extension Sequence {
    func map<T>(allowInvalidElements: Bool, transform: (Iterator.Element) throws -> T) throws -> [T] {
        if !allowInvalidElements {
            return try self.map(transform)
        }

        return self.flatMap {
            
            do {
                let unboxed = try transform($0)
                return unboxed
            } catch {
                if let error = error as? UnboxError {
                    let warning = UnboxWarning.invalidElement(error: error)
                    Unboxer.warningLogger?.log(warning: warning)
                }
                return nil
            }
        }
    }
}
