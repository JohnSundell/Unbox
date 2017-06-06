//
//  UnboxWarningLogger.swift
//  Unbox
//
//  Created by Nicolas Jakubowski on 6/6/17.
//  Copyright © 2017 John Sundell. All rights reserved.
//

import Foundation

/// Warnings are things that went wrong during the unbox operation but that didn't break unboxing
/// These aren't thrown, instead they are sent to a logger where you'll be able to keep record of them and research why you're getting this
public enum UnboxWarning {
    
    /// An invalid element was found in an array
    case invalidElement(error: UnboxError)
    
    /// Failed to unbox an optional key
    case optionalKeyFailedToUnbox(error: UnboxError)
}

internal extension UnboxError {
    
    /// Defines whether the receiver can be threated as a warning for the `optionalKeyFailedToUnbox` case
    /// We only want to generate a warning if the key is not missing
    var isOptionalKeyFailedtoUnboxWarning: Bool {
        switch self {
        case .customUnboxingFailed, .invalidData:
            return true
        case .pathError(let error, _):
            
            switch error {
            case .emptyKeyPath, .missingKey:
                return false
            case .invalidArrayElement, .invalidCollectionElementType, .invalidDictionaryKey, .invalidDictionaryKeyType, .invalidDictionaryValue, .invalidValue:
                return true
            }
            
        }
    }
    
}
