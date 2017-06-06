/**
 *  Unbox
 *  Copyright (c) 2015-2017 John Sundell
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

extension UnboxTests {
    static var allTests: [(String, (UnboxTests) -> () throws -> Void)] {
        return [
            ("testWithOnlyValidRequiredValues", testWithOnlyValidRequiredValues),
            ("testWithMissingRequiredValues", testWithMissingRequiredValues),
            ("testWithInvalidRequiredValues", testWithInvalidRequiredValues),
            ("testWithInvalidRequiredURL", testWithInvalidRequiredURL),
            ("testAutomaticTransformationOfStringsToRawTypes", testAutomaticTransformationOfStringsToRawTypes),
            ("testUInt", testUInt),
            ("testInt32", testInt32),
            ("testInt64", testInt64),
            ("testUInt32", testUInt32),
            ("testUInt64", testUInt64),
            ("testImplicitIntegerConversion", testImplicitIntegerConversion),
            ("testArrayOfURLs", testArrayOfURLs),
            ("testArrayOfEnums", testArrayOfEnums),
            ("testRequiredDateFormatting", testRequiredDateFormatting),
            ("testOptionalDateFormattingFailureNotThrowing", testOptionalDateFormattingFailureNotThrowing),
            ("testCustomDictionaryKeyType", testCustomDictionaryKeyType),
            ("testOptionalInvalidCustomDictionaryKeyDoesNotFail", testOptionalInvalidCustomDictionaryKeyDoesNotFail),
            ("testRequiredInvalidCustomDictionaryKeyThrows", testRequiredInvalidCustomDictionaryKeyThrows),
            ("testCustomDictionaryKeyTypeWithArrayOfUnboxables", testCustomDictionaryKeyTypeWithArrayOfUnboxables),
            ("testCustomDictionaryKeyTypeWithArrayOfUnboxablesThrowsOnInvalidData", testCustomDictionaryKeyTypeWithArrayOfUnboxablesThrowsOnInvalidData),
            ("testCustomDictionaryKeyTypeWithArrayOfUnboxablesCanAllowInvalidData", testCustomDictionaryKeyTypeWithArrayOfUnboxablesCanAllowInvalidData),
            ("testOptionalCustomDictionaryKeyTypeWithArrayOfUnboxablesDoesNotFail", testOptionalCustomDictionaryKeyTypeWithArrayOfUnboxablesDoesNotFail),
            ("testWithInvalidRequiredUnboxable", testWithInvalidRequiredUnboxable),
            ("testWithInvalidOptionalValue", testWithInvalidOptionalValue),
            ("testUnboxingFromValidData", testUnboxingFromValidData),
            ("testUnboxingFromArbitraryKeysDictionary", testUnboxingFromArbitraryKeysDictionary),
            ("testUnboxingFromArbitraryKeysData", testUnboxingFromArbitraryKeysData),
            ("testUnboxingValueFromArray", testUnboxingValueFromArray),
            ("testUnboxingValueFromOutOfArrayBoundsThrows", testUnboxingValueFromOutOfArrayBoundsThrows),
            ("testUnboxingArrayOfDictionaries", testUnboxingArrayOfDictionaries),
            ("testUnboxingArrayOfDictionariesWhileAllowingInvalidElements", testUnboxingArrayOfDictionariesWhileAllowingInvalidElements),
            ("testUnboxingNestedArrayOfDictionariesWhileAllowingInvalidElements", testUnboxingNestedArrayOfDictionariesWhileAllowingInvalidElements),
            ("testUnboxingNestedDictionaryWhileAllowingInvalidElements", testUnboxingNestedDictionaryWhileAllowingInvalidElements),
            ("testNestedArray", testNestedArray),
            ("testNestedDictionary", testNestedDictionary),
            ("testNestedArrayAsValueOfDictionary", testNestedArrayAsValueOfDictionary),
            ("testThrowingForMissingRequiredValue", testThrowingForMissingRequiredValue),
            ("testThrowingForInvalidRequiredValue", testThrowingForInvalidRequiredValue),
            ("testThrowingForInvalidData", testThrowingForInvalidData),
            ("testThrowingForInvalidDataArray", testThrowingForInvalidDataArray),
            ("testThrowingForSingleInvalidDictionaryInArray", testThrowingForSingleInvalidDictionaryInArray),
            ("testRequiredContext", testRequiredContext),
            ("testAccessingNestedDictionaryWithKeyPath", testAccessingNestedDictionaryWithKeyPath),
            ("testAccessingNestedArrayWithKeyPath", testAccessingNestedArrayWithKeyPath),
            ("testKeysWithDotNotTreatedAsKeyPath", testKeysWithDotNotTreatedAsKeyPath),
            ("testCustomUnboxing", testCustomUnboxing),
            ("testCustomUnboxingFailedThrows", testCustomUnboxingFailedThrows),
            ("testCustomUnboxingFromArrayWithMultipleClasses", testCustomUnboxingFromArrayWithMultipleClasses),
            ("testCustomUnboxingFromArrayWithMultipleClassesAndAllowedInvalid", testCustomUnboxingFromArrayWithMultipleClassesAndAllowedInvalid),
            ("testBorderlineBooleansUnboxing", testBorderlineBooleansUnboxing),
            ("testUnboxingStartingAtCustomKey", testUnboxingStartingAtCustomKey),
            ("testUnboxingStartingAtMissingCustomKey", testUnboxingStartingAtMissingCustomKey),
            ("testUnboxingStartingAtCustomKeyPath", testUnboxingStartingAtCustomKeyPath),
            ("testUnboxingStartingAtMissingCustomKeyPath", testUnboxingStartingAtMissingCustomKeyPath),
            ("testUnboxingArrayStartingAtCustomKeyPath", testUnboxingArrayStartingAtCustomKeyPath),
            ("testUnboxingArrayIndexStartingAtCustomKeyPath", testUnboxingArrayIndexStartingAtCustomKeyPath),
            ("testUnboxingArrayInvalidIndexStartingAtCustomKeyPath", testUnboxingArrayInvalidIndexStartingAtCustomKeyPath),
            ("testUnboxingArrayOfStringsTransformedToInt", testUnboxingArrayOfStringsTransformedToInt),
            ("testUnboxingArrayOfBadStringsTransformedToInt", testUnboxingArrayOfBadStringsTransformedToInt),
            ("testThrowingForArrayWithInvalidElementType", testThrowingForArrayWithInvalidElementType),
            ("testThrowingForArrayWithInvalidElement", testThrowingForArrayWithInvalidElement),
            ("testThrowingForDictionaryWithInvalidKeyType", testThrowingForDictionaryWithInvalidKeyType),
            ("testThrowingForDictionaryWithInvalidValueType", testThrowingForDictionaryWithInvalidValueType),
            ("testComplexCollection", testComplexCollection),
            ("testSets", testSets)
        ]
    }
}
