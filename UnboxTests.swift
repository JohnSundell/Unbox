import Foundation
import XCTest

// MARK: - Tests

class UnboxTests: XCTestCase {
    func testWithOnlyValidRequiredValues() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        let unboxed: UnboxTestMock? = Unbox(dictionary)
        XCTAssertNotNil(unboxed, "Failed to unbox valid dictionary")
        unboxed?.verifyAgainstDictionary(dictionary)
    }
    
    func testWithMissingRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary.removeValueForKey(key)
            
            let unboxed: UnboxTestMock? = Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary[key] = NSObject()
            
            let unboxed: UnboxTestMock? = Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredURL() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        invalidDictionary[UnboxTestMock.requiredURLKey] = "Clearly not a URL!"
        
        let unboxed: UnboxTestMock? = Unbox(invalidDictionary)
        XCTAssertNil(unboxed, "Unbox did not return nil for a dictionary with an invalid required URL value")
    }
    
    func testWithInvalidRequiredUnboxable() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = "Totally not unboxable"
        
        let unboxedFromString: UnboxTestMock? = Unbox(invalidDictionary)
        XCTAssertNil(unboxedFromString, "Unbox did not return nil for a string")
        
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = ["cannotBe" : "unboxed"]
        
        let unboxedFromInvalidDictionary: UnboxTestMock? = Unbox(invalidDictionary)
        XCTAssertNil(unboxedFromInvalidDictionary, "Unbox did not return nil for an invalid dictionary")
    }
    
    func testWithInvalidOptionalValue() {
        var validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        validDictionary[UnboxTestMock.optionalBoolKey] = "Not a Bool"
        
        let unboxed: UnboxTestMock? = Unbox(validDictionary)
        XCTAssertNotNil(unboxed, "Invalid optional values should be ignored")
    }
    
    func testUnboxingFromValidData() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            let unboxed: UnboxTestMock? = Unbox(data)
            XCTAssertNotNil(unboxed, "Could not unbox from data")
        } catch {
            XCTFail("Could not decode data from dictionary: \(dictionary)")
        }
    }
    
    func testThrowingForMissingRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary.removeValueForKey(key)
            
            do {
                let _: UnboxTestMock = try UnboxOrThrow(invalidDictionary)
                XCTFail("Unbox should have thrown for a missing value")
            } catch UnboxError.MissingKey(key) {
                // Test passed
            } catch {
                XCTFail("Unbox did not return the correct error type")
            }
        }
    }
    
    func testThrowingForInvalidRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            let invalidValue = NSObject()
            let invalidValueDescription = "\(invalidValue)"
            invalidDictionary[key] = invalidValue
            
            do {
                let _: UnboxTestMock = try UnboxOrThrow(invalidDictionary)
                XCTFail("Unbox should have thrown for an invalid value")
            } catch UnboxError.InvalidKeyValue(key, invalidValueDescription) {
                // Test passed
            } catch {
                XCTFail("Unbox did not return the correct error type")
            }
            
            let unboxed: UnboxTestMock? = Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testThrowingForInvalidData() {
        if let data = "Not a dictionary".dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let _: UnboxTestMock = try UnboxOrThrow(data)
                XCTFail("Unbox should have thrown for invalid data")
            } catch {
                // Test passed
            }
        } else {
            XCTFail("Could not create data from a string")
        }
    }
    
    func testContext() {
        class UnboxableWithContext: DictionaryUnboxable {
            let nestedUnboxable: UnboxableWithContext?
            
            required init(unboxer: DictionaryUnboxer) {
                if let context = unboxer.context as? String {
                    XCTAssertTrue("context" == context, "")
                } else {
                    XCTFail("Context was of an unexpected type: \(unboxer.context)")
                }
                
                self.nestedUnboxable = unboxer.unbox("nested")
            }
        }
        
        let unboxed: UnboxableWithContext? = Unbox(["nested" : UnboxableDictionary()], context: "context")
        
        XCTAssertFalse(unboxed == nil, "Could not unbox with a context")
    }

    func testAccessingNestedDictionaryWithKeyPath() {
        struct KeyPathModel: Unboxable {
            let intValue: Int
            let dictionary: UnboxableDictionary

            init(unboxer: Unboxer) {
                let intKeyPathComponents = [UnboxTestMock.requiredUnboxableDictionaryKey, "test", UnboxTestMock.requiredIntKey]
                let keyPath = intKeyPathComponents.joinWithSeparator(".")
                intValue = unboxer.unbox(keyPath)

                let dictionaryKeyPath = [UnboxTestMock.requiredUnboxableDictionaryKey, "test"].joinWithSeparator(".")
                dictionary = unboxer.unbox(dictionaryKeyPath)
            }
        }


        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        let model: KeyPathModel? = Unbox(validDictionary)
        XCTAssertNotNil(model)
        XCTAssertEqual(15, model?.intValue)
        if let result = model?.dictionary[UnboxTestMock.requiredArrayKey] as? [String] {
            XCTAssertEqual(["unbox", "is", "pretty", "cool", "right?"], result)
        } else {
            XCTFail()
        }
    }
}

private func UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: Bool) -> UnboxableDictionary {
    var dictionary: UnboxableDictionary = [
        UnboxTestMock.requiredBoolKey : true,
        UnboxTestMock.requiredIntKey : 15,
        UnboxTestMock.requiredDoubleKey : Double(1.5),
        UnboxTestMock.requiredFloatKey : Float(3.14),
        UnboxTestMock.requiredStringKey :  "hello",
        UnboxTestMock.requiredURLKey : "http://www.google.com",
        UnboxTestMock.requiredArrayKey : ["unbox", "is", "pretty", "cool", "right?"]
    ]
    
    if !nested {
        dictionary[UnboxTestMock.requiredUnboxableKey] = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)
        dictionary[UnboxTestMock.requiredUnboxableArrayKey] = [UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)]
        dictionary[UnboxTestMock.requiredUnboxableDictionaryKey] = ["test" : UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)]
    }
    
    return dictionary
}

// MARK: - Mocks

private class UnboxTestBaseMock: DictionaryUnboxable {
    static let requiredBoolKey = "requiredBool"
    static let optionalBoolKey = "optionalBool"
    static let requiredIntKey = "requiredInt"
    static let optionalIntKey = "optionalInt"
    static let requiredDoubleKey = "requiredDouble"
    static let optionalDoubleKey = "optionalDouble"
    static let requiredFloatKey = "requiredFloat"
    static let optionalFloatKey = "optionalFloat"
    static let requiredStringKey = "requiredString"
    static let optionalStringKey = "optionalString"
    static let requiredURLKey = "requiredURL"
    static let optionalURLKey = "optionalURL"
    static let requiredArrayKey = "requiredArray"
    static let optionalArrayKey = "optionalArray"
    
    let requiredBool: Bool
    let optionalBool: Bool?
    let requiredInt: Int
    let optionalInt: Int?
    let requiredDouble: Double
    let optionalDouble: Double?
    let requiredFloat: Float
    let optionalFloat: Float?
    let requiredString: String
    let optionalString: String?
    let requiredURL: NSURL
    let optionalURL: NSURL?
    let requiredArray: [String]
    let optionalArray: [String]?
    
    required init(unboxer: DictionaryUnboxer) {
        self.requiredBool = unboxer.unbox(UnboxTestBaseMock.requiredBoolKey)
        self.optionalBool = unboxer.unbox(UnboxTestBaseMock.optionalBoolKey)
        self.requiredInt = unboxer.unbox(UnboxTestBaseMock.requiredIntKey)
        self.optionalInt = unboxer.unbox(UnboxTestBaseMock.optionalIntKey)
        self.requiredDouble = unboxer.unbox(UnboxTestBaseMock.requiredDoubleKey)
        self.optionalDouble = unboxer.unbox(UnboxTestBaseMock.optionalDoubleKey)
        self.requiredFloat = unboxer.unbox(UnboxTestBaseMock.requiredFloatKey)
        self.optionalFloat = unboxer.unbox(UnboxTestBaseMock.optionalFloatKey)
        self.requiredString = unboxer.unbox(UnboxTestBaseMock.requiredStringKey)
        self.optionalString = unboxer.unbox(UnboxTestBaseMock.optionalStringKey)
        self.requiredURL = unboxer.unbox(UnboxTestBaseMock.requiredURLKey)
        self.optionalURL = unboxer.unbox(UnboxTestBaseMock.optionalURLKey)
        self.requiredArray = unboxer.unbox(UnboxTestBaseMock.requiredArrayKey)
        self.optionalArray = unboxer.unbox(UnboxTestBaseMock.optionalArrayKey)
    }
    
    func verifyAgainstDictionary(dictionary: UnboxableDictionary) {
        for (key, value) in dictionary {
            let verificationOutcome: Bool
            
            switch key {
            case UnboxTestBaseMock.requiredBoolKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredBool, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalBoolKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalBool, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredIntKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredInt, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalIntKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalInt, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredDoubleKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredDouble, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalDoubleKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalDouble, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredFloatKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalFloatKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredStringKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredString, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalStringKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalString, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredURLKey:
                verificationOutcome = self.verifyURLPropertyValue(self.requiredURL, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalURLKey:
                verificationOutcome = self.verifyURLPropertyValue(self.optionalURL, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredArrayKey:
                verificationOutcome = self.verifyArrayPropertyValue(self.requiredArray, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalArrayKey:
                verificationOutcome = self.verifyArrayPropertyValue(self.optionalArray, againstDictionaryValue: value)
            default:
                verificationOutcome = true
            }
            
            XCTAssertTrue(verificationOutcome, "Verification failed for key: " + key)
        }
    }
    
    func verifyPropertyValue<T: Equatable>(propertyValue: T?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let propertyValue = propertyValue {
            if let typedDictionaryValue = dictionaryValue as? T {
                return propertyValue == typedDictionaryValue
            }
        }
        
        return false
    }
    
    func verifyURLPropertyValue(propertyValue: NSURL?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let string = dictionaryValue as? String {
            return self.verifyPropertyValue(self.requiredURL, againstDictionaryValue: NSURL(string: string))
        }
        
        return false
    }
    
    func verifyArrayPropertyValue<T: Equatable>(propertyValue: [T]?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let propertyValue = propertyValue {
            if let dictionaryArrayValue = dictionaryValue as? [T] {
                for i in 0..<dictionaryArrayValue.count {
                    if dictionaryArrayValue[i] != propertyValue[i] {
                        return false
                    }
                }
                
                return true
            }
        }
        
        return false
    }
}

private class UnboxTestMock: UnboxTestBaseMock {
    static let requiredUnboxableKey = "requiredUnboxable"
    static let optionalUnboxableKey = "optionalUnboxable"
    static let requiredUnboxableArrayKey = "requiredUnboxableArray"
    static let optionalUnboxableArrayKey = "optionalUnboxableArray"
    static let requiredUnboxableDictionaryKey = "requiredUnboxableDictionary"
    static let optionalUnboxableDictionaryKey = "optionalUnboxableDictionary"
    
    let requiredUnboxable: UnboxTestBaseMock
    let optionalUnboxable: UnboxTestBaseMock?
    let requiredUnboxableArray: [UnboxTestBaseMock]
    let optionalUnboxableArray: [UnboxTestBaseMock]?
    let requiredUnboxableDictionary: [String : UnboxTestBaseMock]
    let optionalUnboxableDictionary: [String : UnboxTestBaseMock]?
    
    required init(unboxer: DictionaryUnboxer) {
        self.requiredUnboxable = unboxer.unbox(UnboxTestMock.requiredUnboxableKey)
        self.optionalUnboxable = unboxer.unbox(UnboxTestMock.optionalUnboxableKey)
        self.requiredUnboxableArray = unboxer.unbox(UnboxTestMock.requiredUnboxableArrayKey)
        self.optionalUnboxableArray = unboxer.unbox(UnboxTestMock.optionalUnboxableArrayKey)
        self.requiredUnboxableDictionary = unboxer.unbox(UnboxTestMock.requiredUnboxableDictionaryKey)
        self.optionalUnboxableDictionary = unboxer.unbox(UnboxTestMock.optionalUnboxableDictionaryKey)
        
        super.init(unboxer: unboxer)
    }
}
