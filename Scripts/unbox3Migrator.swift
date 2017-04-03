/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation
import ShellOut
import Files

// MARK: - Extensions

private extension String {
    func replacingUnboxCall(withParameter parameter: String) -> String {
        guard let range = range(of: "unbox(\(parameter):") else {
            return self
        }

        let substringAfterCall = substring(from: range.upperBound)
        let quoteComponents = substringAfterCall.components(separatedBy: "\"")
        let replaced: String

        // Is this a string literal or not?
        if quoteComponents.count > 1 {
            let token = quoteComponents[1]
            replaced = replacingOccurrences(of: "\"\(token)\"", with: ".\(parameter)(\"\(token)\")")
        } else {
            let token = substringAfterCall.components(separatedBy: ")")[0].trimmingCharacters(in: .whitespaces)
            let replacedSubstring = substringAfterCall.replacingOccurrences(of: token, with: ".\(parameter)(\(token))")
            replaced = replacingOccurrences(of: substringAfterCall, with: replacedSubstring)
        }

        return replaced.replacingOccurrences(of: "unbox(\(parameter):", with: "unbox(at:")
    }
}

// MARK: - Script

let gitDiff = try shellOut(to: "git", arguments: ["diff", "--shortstat"])

guard gitDiff.isEmpty else {
    print("👮  The current repository has uncommited changes")
    print("👉  Please commit your changes before running the Unbox migrator")
    exit(1)
}

for file in FileSystem().currentFolder.makeFileSequence(recursive: true) {
    guard file.extension == "swift" else {
        continue
    }

    print("👉  Migrating \(file.name)... ", terminator: "")

    let fileLines = try file.readAsString().components(separatedBy: .newlines)
    var newFileContent = ""

    for line in fileLines {
        if !newFileContent.isEmpty {
            newFileContent.append("\n")
        }

        newFileContent.append(line.replacingUnboxCall(withParameter: "key").replacingUnboxCall(withParameter: "keyPath"))
    }

    try file.write(string: newFileContent)

    print("✅")
}

print("🎉  Your code was successfully converted to Unbox 3.0!")
