//
//  UnboxWarningLogger.swift
//  Unbox
//
//  Created by Nicolas Jakubowski on 6/6/17.
//  Copyright © 2017 John Sundell. All rights reserved.
//

import Foundation

/// Warnings are things that went wrong during the unbox operation
/// These aren't thrown, instead they are sent to a logger where you'll be able to keep record of them and research why you're getting them
public enum UnboxWarning {
    
    /// An invalid element was found in an array
    case invalidElement(error: UnboxError)
    
}
