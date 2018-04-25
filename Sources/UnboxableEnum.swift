/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

/// Protocol used to enable an enum to be directly unboxable
public protocol UnboxableEnum: RawRepresentable, UnboxCompatible {}

/// Default implementation of `UnboxCompatible` for enums
public extension UnboxableEnum {
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        return (value as? RawValue).map(self.init)
    }
}

/// Specialized implementation of `UnboxCompatible` for enums 
/// that are expressible by String literal.
public extension UnboxableEnum where RawValue:ExpressibleByStringLiteral{
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        guard let literal = value as? RawValue.StringLiteralType else {
            return nil
        }
        
        return self.init(rawValue: RawValue(stringLiteral: literal))
    }
}

/// Specialized implementation of `UnboxCompatible` for enums
/// that are expressible by Int literal.
public extension UnboxableEnum where RawValue:ExpressibleByIntegerLiteral{
    static func unbox(value: Any, allowInvalidCollectionElements: Bool) throws -> Self? {
        guard let literal = value as? RawValue.IntegerLiteralType else {
            return nil
        }
        
        return self.init(rawValue: RawValue(integerLiteral: literal))
    }
}
