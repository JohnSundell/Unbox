//
//  UnboxWarningLogger.swift
//  Unbox
//
//  Created by Nicolas Jakubowski on 6/6/17.
//  Copyright © 2017 John Sundell. All rights reserved.
//

import Foundation

/// Takes care of dealing with warnings
public protocol UnboxWarningLogger {
    
    /// Called whenever a warning is found when Unboxing
    func log(warning: UnboxWarning)
}
