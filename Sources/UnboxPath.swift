/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

public enum UnboxPath {
    case key(String)
    case keys([String])
    case keyPath(String)
}

public extension UnboxPath {
    var string: String {
        switch self {
        case .key(let key):
            return key
        case .keys(let keys):
            return keys.joined(separator: ".")
        case .keyPath(let keyPath):
            return keyPath
        }
    }
}

extension UnboxPath: ExpressibleByStringLiteral {
    public init(stringLiteral literal: String) {
        self = .key(literal)
    }

    public init(unicodeScalarLiteral literal: String) {
        self = .key(literal)
    }

    public init(extendedGraphemeClusterLiteral literal: String) {
        self = .key(literal)
    }
}

extension UnboxPath: ExpressibleByArrayLiteral {
    public init(arrayLiteral components: String...) {
        self = .keys(components)
    }
}

extension UnboxPath: CustomStringConvertible {
    public var description: String {
        return string
    }
}
