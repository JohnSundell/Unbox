import Foundation
import XCTest
import Unbox

// MARK: - Tests

class UnboxTests: XCTestCase {
    func testWithOnlyValidRequiredValues() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        let unboxed: UnboxTestMock? = try? Unbox(dictionary)
        XCTAssertNotNil(unboxed, "Failed to unbox valid dictionary")
        unboxed?.verifyAgainstDictionary(dictionary)
    }
    
    func testWithMissingRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary.removeValueForKey(key)
            
            let unboxed: UnboxTestMock? = try? Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary[key] = NSObject()
            
            let unboxed: UnboxTestMock? = try? Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredURL() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        invalidDictionary[UnboxTestMock.requiredURLKey] = "Clearly not a URL!"
        
        let unboxed: UnboxTestMock? = try? Unbox(invalidDictionary)
        XCTAssertNil(unboxed, "Unbox did not return nil for a dictionary with an invalid required URL value")
    }
    
    func testAutomaticTransformationOfStringsToRawTypes() {
        struct Model: Unboxable {
            let requiredInt: Int
            let optionalInt: Int?
            let requiredDouble: Double
            let optionalDouble: Double?
            
            init(unboxer: Unboxer) {
                self.requiredInt = unboxer.unbox("requiredInt")
                self.optionalInt = unboxer.unbox("optionalInt")
                self.requiredDouble = unboxer.unbox("requiredDouble")
                self.optionalDouble = unboxer.unbox("optionalDouble")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "requiredInt" : "7",
            "optionalInt" : "14",
            "requiredDouble" : "3.14",
            "optionalDouble" : "7.12"
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.requiredInt, 7)
            XCTAssertEqual(unboxed.optionalInt, 14)
            XCTAssertEqual(unboxed.requiredDouble, 3.14)
            XCTAssertEqual(unboxed.optionalDouble, 7.12)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUInt() {
        struct Model: Unboxable {
            let required: UInt
            let optional1: UInt?
            let optional2: UInt?
            
            init(unboxer: Unboxer) {
                self.required = unboxer.unbox("required")
                self.optional1 = unboxer.unbox("optional1")
                self.optional2 = unboxer.unbox("optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.required, 27)
            XCTAssertEqual(unboxed.optional1, 10)
            XCTAssertNil(unboxed.optional2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInt32() {
        struct Model: Unboxable {
            let required: Int32
            let optional1: Int32?
            let optional2: Int32?
            
            init(unboxer: Unboxer) {
                self.required = unboxer.unbox("required")
                self.optional1 = unboxer.unbox("optional1")
                self.optional2 = unboxer.unbox("optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.required, 27)
            XCTAssertEqual(unboxed.optional1, 10)
            XCTAssertNil(unboxed.optional2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testInt64() {
        struct Model: Unboxable {
            let required: Int64
            let optional1: Int64?
            let optional2: Int64?
            
            init(unboxer: Unboxer) {
                self.required = unboxer.unbox("required")
                self.optional1 = unboxer.unbox("optional1")
                self.optional2 = unboxer.unbox("optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.required, 27)
            XCTAssertEqual(unboxed.optional1, 10)
            XCTAssertNil(unboxed.optional2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testImplicitIntegerConversion() {
        struct Model: Unboxable {
            let bool1: Bool
            let bool2: Bool
            let bool3: Bool
            let double: Double
            let float: Float
            let string: String?
            
            init(unboxer: Unboxer) {
                self.bool1 = unboxer.unbox("bool1")
                self.bool2 = unboxer.unbox("bool2")
                self.bool3 = unboxer.unbox("bool3")
                self.double = unboxer.unbox("double")
                self.float = unboxer.unbox("float")
                self.string = unboxer.unbox("string")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "bool1" : 0,
            "bool2" : 1,
            "bool3" : 19,
            "double" : 27,
            "float" : 39,
            "string" : 7
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertFalse(unboxed.bool1)
            XCTAssertTrue(unboxed.bool2)
            XCTAssertTrue(unboxed.bool3)
            XCTAssertEqual(unboxed.double, Double(27))
            XCTAssertEqual(unboxed.float, Float(39))
            XCTAssertNil(unboxed.string)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testRequiredDateFormatting() {
        struct Model: Unboxable {
            let date: NSDate
            let dateArray: [NSDate]
            
            init(unboxer: Unboxer) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox("date", formatter: formatter)
                self.dateArray = unboxer.unbox("dateArray", formatter: formatter)
            }
        }
        
        struct AllowInvalidElementsModel: Unboxable {
            let date: NSDate
            let dateArray: [NSDate]
            
            init(unboxer: Unboxer) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox("date", formatter: formatter)
                self.dateArray = unboxer.unbox("dateArray", formatter: formatter, allowInvalidElements: true)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "date" : "2015-12-15",
            "dateArray" : ["2015-12-15"]
        ]
        
        // Valid tests:
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            
            let calendar = NSCalendar.currentCalendar()
            XCTAssertEqual(calendar.component(.Year, fromDate: unboxed.date), 2015)
            XCTAssertEqual(calendar.component(.Month, fromDate: unboxed.date), 12)
            XCTAssertEqual(calendar.component(.Day, fromDate: unboxed.date), 15)
            
            if let firstDate = unboxed.dateArray.first {
                XCTAssertEqual(calendar.component(.Year, fromDate: firstDate), 2015)
                XCTAssertEqual(calendar.component(.Month, fromDate: firstDate), 12)
                XCTAssertEqual(calendar.component(.Day, fromDate: firstDate), 15)
            } else {
                XCTFail("Array empty")
            }
            
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            let invalidValueDateArrayDictionary: UnboxableDictionary = [
                "date" : "2015-12-15",
                "dateArray" : ["2015-12-tuesday", "2015-12-15"]
            ]
            
            let unboxed: AllowInvalidElementsModel = try Unbox(invalidValueDateArrayDictionary)
            
            XCTAssertEqual(unboxed.dateArray.count, 1)
            
            if let firstDate = unboxed.dateArray.first {
                let calendar = NSCalendar.currentCalendar()
                XCTAssertEqual(calendar.component(.Year, fromDate: firstDate), 2015)
                XCTAssertEqual(calendar.component(.Month, fromDate: firstDate), 12)
                XCTAssertEqual(calendar.component(.Day, fromDate: firstDate), 15)
            } else {
                XCTFail("Array empty")
            }
        } catch {
            XCTFail("\(error)")
        }
        
        // Invalid tests:
        
        do {
            let invalidDateDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday",
                "dateArray" : ["2015-12-15"]
            ]
            
            try Unbox(invalidDateDictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
        
        do {
            let invalidDateArrayDictionary: UnboxableDictionary = [
                "date" : "2015-12-15",
                "dateArray" : ["2015-12-tuesday"]
            ]
            
            try Unbox(invalidDateArrayDictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testOptionalDateFormattingFailureNotThrowing() {
        struct Model: Unboxable {
            let date: NSDate?
            let dateArray: [NSDate]?
            
            init(unboxer: Unboxer) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox("date", formatter: formatter)
                self.dateArray = unboxer.unbox("dateArray", formatter: formatter)
            }
        }
        
        struct AllowInvalidElementsModel: Unboxable {
            let date: NSDate?
            let dateArray: [NSDate]?
            
            init(unboxer: Unboxer) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox("date", formatter: formatter)
                self.dateArray = unboxer.unbox("dateArray", formatter: formatter, allowInvalidElements: true)
            }
        }
        
        do {
            let invalidDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday",
                "dateArray" : ["2015-12-tuesday"]
            ]
            
            let unboxed: Model = try Unbox(invalidDictionary)
            XCTAssertNil(unboxed.date)
            XCTAssertNil(unboxed.dateArray)
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            let invalidDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday",
                "dateArray" : ["2015-12-15", "2015-12-tuesday"]
            ]
            
            let unboxed: AllowInvalidElementsModel = try Unbox(invalidDictionary)
            XCTAssertNil(unboxed.date)
            XCTAssertEqual(unboxed.dateArray?.count, 1)
            
            let calendar = NSCalendar.currentCalendar()
            if let firstDate = unboxed.dateArray?.first {
                XCTAssertEqual(calendar.component(.Year, fromDate: firstDate), 2015)
                XCTAssertEqual(calendar.component(.Month, fromDate: firstDate), 12)
                XCTAssertEqual(calendar.component(.Day, fromDate: firstDate), 15)
            } else {
                XCTFail("Array empty")
            }
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCustomDictionaryKeyType() {
        struct Model: Unboxable {
            let requiredIntDictionary: [UnboxTestDictionaryKey : Int]
            let optionalIntDictionary: [UnboxTestDictionaryKey : Int]?
            let requiredModelDictionary: [UnboxTestDictionaryKey : UnboxTestSimpleMock]
            let optionalModelDictionary: [UnboxTestDictionaryKey : UnboxTestSimpleMock]?
            
            init(unboxer: Unboxer) {
                self.requiredIntDictionary = unboxer.unbox("requiredIntDictionary")
                self.optionalIntDictionary = unboxer.unbox("optionalIntDictionary")
                self.requiredModelDictionary = unboxer.unbox("requiredModelDictionary")
                self.optionalModelDictionary = unboxer.unbox("optionalModelDictionary")
            }
        }
        
        do {
            let unboxed: Model = try Unbox([
                "requiredIntDictionary" : ["key" : 12],
                "optionalIntDictionary" : ["optionalKey" : 27],
                "requiredModelDictionary" : [
                    "key" : [
                        "int" : 31
                    ]
                ],
                "optionalModelDictionary" : [
                    "optionalKey" : [
                        "int" : 19
                    ]
                ]
            ])
            
            XCTAssertEqual(unboxed.requiredIntDictionary, [UnboxTestDictionaryKey(key: "key") : 12])
            XCTAssertEqual(unboxed.optionalIntDictionary ?? [:], [UnboxTestDictionaryKey(key: "optionalKey") : 27])
            XCTAssertEqual(unboxed.requiredModelDictionary, [UnboxTestDictionaryKey(key: "key") : UnboxTestSimpleMock(int: 31)])
            XCTAssertEqual(unboxed.optionalModelDictionary ?? [:], [UnboxTestDictionaryKey(key: "optionalKey") : UnboxTestSimpleMock(int: 19)])
            
            let unboxedWithoutOptionals: Model = try Unbox([
                "requiredIntDictionary" : ["key" : 12],
                "requiredModelDictionary" : [
                    "key" : [
                        "int" : 31
                    ]
                ]
            ])
            
            XCTAssertEqual(unboxedWithoutOptionals.requiredIntDictionary, [UnboxTestDictionaryKey(key: "key") : 12])
            XCTAssertEqual(unboxedWithoutOptionals.requiredModelDictionary, [UnboxTestDictionaryKey(key: "key") : UnboxTestSimpleMock(int: 31)])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testOptionalInvalidCustomDictionaryKeyDoesNotFail() {
        struct Model: Unboxable {
            let dictionary: [UnboxTestDictionaryKey : Int]?
            
            init(unboxer: Unboxer) {
                self.dictionary = unboxer.unbox("dictionary")
            }
        }
        
        do {
            let unboxed: Model = try Unbox([
                "dictionary" : [
                    "FAIL" : 59
                ]
            ])
            
            XCTAssertNil(unboxed.dictionary)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testRequiredInvalidCustomDictionaryKeyThrows() {
        struct Model: Unboxable {
            let dictionary: [UnboxTestDictionaryKey : Int]
            
            init(unboxer: Unboxer) {
                self.dictionary = unboxer.unbox("dictionary")
            }
        }
        
        do {
            try Unbox([
                "dictionary" : [
                    "FAIL" : 59
                ]
            ]) as Model
            
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testCustomDictionaryKeyTypeWithArrayOfUnboxables() {
        struct Model: Unboxable {
            let requiredModelDictionary: [UnboxTestDictionaryKey : [UnboxTestSimpleMock]]
            let optionalModelDictionary: [UnboxTestDictionaryKey : [UnboxTestSimpleMock]]?
            
            init(unboxer: Unboxer) {
                self.requiredModelDictionary = unboxer.unbox("requiredModelDictionary")
                self.optionalModelDictionary = unboxer.unbox("optionalModelDictionary")
            }
        }
        
        do {
            let unboxed: Model = try Unbox([
                "requiredModelDictionary" : [
                    "key" : [
                        ["int" : 31]
                    ]
                ],
                "optionalModelDictionary" : [
                    "optionalKey" : [
                        ["int" : 19]
                    ]
                ]
            ])
            
            if let values = unboxed.requiredModelDictionary[UnboxTestDictionaryKey(key: "key")] {
                XCTAssertEqual(values, [UnboxTestSimpleMock(int: 31)])
            } else {
                XCTFail("Key was missing from unboxed dictionary")
            }
            
            if let values = unboxed.optionalModelDictionary?[UnboxTestDictionaryKey(key: "optionalKey")] {
                XCTAssertEqual(values, [UnboxTestSimpleMock(int: 19)])
            } else {
                XCTFail("Key was missing from unboxed dictionary")
            }
            
            let unboxedWithoutOptionals: Model = try Unbox([
                "requiredModelDictionary" : [
                    "key" : [
                        ["int" : 31]
                    ]
                ]
            ])
            
            if let values = unboxedWithoutOptionals.requiredModelDictionary[UnboxTestDictionaryKey(key: "key")] {
                XCTAssertEqual(values, [UnboxTestSimpleMock(int: 31)])
            } else {
                XCTFail("Key was missing from unboxed dictionary")
            }
            XCTAssertNil(unboxedWithoutOptionals.optionalModelDictionary)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCustomDictionaryKeyTypeWithArrayOfUnboxablesThrowsOnInvalidData() {
        struct Model: Unboxable {
            let requiredModelDictionary: [UnboxTestDictionaryKey : [UnboxTestSimpleMock]]
            
            init(unboxer: Unboxer) {
                self.requiredModelDictionary = unboxer.unbox("requiredModelDictionary")
            }
        }
        
        do {
            let _ : Model = try Unbox([
                "requiredModelDictionary" : [
                    "key" : [
                        ["int" : "asdf"]
                    ]
                ],
            ])
            
            XCTFail("Should throw error when unboxing on invalid data")
        } catch {
            // Test passed
        }
    }
    
    func testCustomDictionaryKeyTypeWithArrayOfUnboxablesCanAllowInvalidData() {
        struct Model: Unboxable {
            let requiredModelDictionary: [UnboxTestDictionaryKey : [UnboxTestSimpleMock]]
            
            init(unboxer: Unboxer) {
                self.requiredModelDictionary = unboxer.unbox("requiredModelDictionary", allowInvalidElements:true)
            }
        }
        
        do {
            let unboxed : Model = try Unbox([
                "requiredModelDictionary" : [
                    "key" : [
                        ["int" : "asdf"]
                    ]
                ],
            ])
            
            if let values = unboxed.requiredModelDictionary[UnboxTestDictionaryKey(key: "key")] {
                XCTAssertEqual(values, [])
            } else {
                XCTFail("Key was missing from unboxed dictionary")
            }
        } catch {
           XCTFail("Should not throw error when unboxing on invalid data")
        }
    }
    
    func testOptionalCustomDictionaryKeyTypeWithArrayOfUnboxablesDoesNotFail() {
        struct Model: Unboxable {
            let optionalModelDictionary: [UnboxTestDictionaryKey : [UnboxTestSimpleMock]]?
            
            init(unboxer: Unboxer) {
                self.optionalModelDictionary = unboxer.unbox("optionalModelDictionary")
            }
        }
        
        do {
            let unboxed : Model = try Unbox([
                "requiredModelDictionary" : [
                    "key" : [
                        ["int" : "asdf"]
                    ]
                ],
            ])
            
            XCTAssertNil(unboxed.optionalModelDictionary)
        } catch {
            XCTFail("Should not throw error when unboxing on invalid data")
        }
    }
    
    func testWithInvalidRequiredUnboxable() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = "Totally not unboxable"
        
        let unboxedFromString: UnboxTestMock? = try? Unbox(invalidDictionary)
        XCTAssertNil(unboxedFromString, "Unbox did not return nil for a string")
        
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = ["cannotBe" : "unboxed"]
        
        let unboxedFromInvalidDictionary: UnboxTestMock? = try? Unbox(invalidDictionary)
        XCTAssertNil(unboxedFromInvalidDictionary, "Unbox did not return nil for an invalid dictionary")
    }
    
    func testWithInvalidOptionalValue() {
        var validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        validDictionary[UnboxTestMock.optionalBoolKey] = "Not a Bool"
        
        let unboxed: UnboxTestMock? = try? Unbox(validDictionary)
        XCTAssertNotNil(unboxed, "Invalid optional values should be ignored")
    }
    
    func testUnboxingFromValidData() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            let unboxed: UnboxTestMock? = try? Unbox(data)
            XCTAssertNotNil(unboxed, "Could not unbox from data")
        } catch {
            XCTFail("Could not decode data from dictionary: \(dictionary)")
        }
    }
    
    func testUnboxingValueFromArray() {
        struct Model: Unboxable {
            let required: String
            let optional: String?
            
            init(unboxer: Unboxer) {
                self.required = unboxer.unbox("required", index: 0)
                self.optional = unboxer.unbox("optional", index: 1)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required" : ["Hello", "This"],
            "optional" : ["Is", "Unbox"]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.required, "Hello")
            XCTAssertEqual(unboxed.optional, "Unbox")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUnboxingValueFromOutOfArrayBoundsThrows() {
        struct Model: Unboxable {
            let int: Int
            
            init(unboxer: Unboxer) {
                self.int = unboxer.unbox("values", index: 3)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "values" : [7, 9, 22]
        ]
        
        do {
            try Unbox(dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testUnboxingArrayOfDictionaries() {
        let dictionaries = [
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false),
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false),
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        ]
        
        guard let unboxedArray: [UnboxTestMock] = try? Unbox(dictionaries) else {
            return XCTFail()
        }
        
        XCTAssertEqual(unboxedArray.count, 3)
        
        for unboxed in unboxedArray {
            unboxed.verifyAgainstDictionary(UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false))
        }
    }
    
    func testUnboxingArrayOfDictionariesWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox("string")
            }
        }
        
        let dictionaries: [UnboxableDictionary] = [
            ["string" : "one"],
            ["invalid" : "element"],
            ["string" : "two"]
        ]
        
        do {
            let unboxed: [Model] = try Unbox(dictionaries, allowInvalidElements: true)
            XCTAssertEqual(unboxed.first?.string, "one")
            XCTAssertEqual(unboxed.last?.string, "two")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUnboxingNestedArrayOfDictionariesWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let nestedModels: [NestedModel]
            
            init(unboxer: Unboxer) {
                self.nestedModels = unboxer.unbox("nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox("string")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "nested" : [
                ["string" : "one"],
                ["invalid" : "element"],
                ["string" : "two"]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.nestedModels.first?.string, "one")
            XCTAssertEqual(unboxed.nestedModels.last?.string, "two")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUnboxingNestedDictionaryWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let nestedModels: [String : NestedModel]
            
            init(unboxer: Unboxer) {
                self.nestedModels = unboxer.unbox("nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox("string")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "nested" : [
                "one" : ["string" : "one"],
                "two" : ["invalid" : "element"],
                "three" : ["string" : "two"]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.nestedModels.count, 2)
            XCTAssertEqual(unboxed.nestedModels["one"]?.string, "one")
            XCTAssertEqual(unboxed.nestedModels["three"]?.string, "two")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testNestedArray() {
        struct Model: Unboxable {
            let arrays: [[Int]]
            
            init(unboxer: Unboxer) {
                self.arrays = unboxer.unbox("arrays")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "arrays": [
                [1, 2],
                [3, 4]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.arrays.count, 2)
            XCTAssertEqual(unboxed.arrays.first!, [1, 2])
            XCTAssertEqual(unboxed.arrays.last!, [3, 4])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testNestedDictionary() {
        struct Model: Unboxable {
            let dictionaries: [String : [String : Int]]
            
            init(unboxer: Unboxer) {
                self.dictionaries = unboxer.unbox("dictionaries")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "dictionaries" : [
                "one" : [
                    "a" : 1,
                    "b" : 2
                ],
                "two" : [
                    "c" : 3,
                    "d" : 4
                ]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.dictionaries.count, 2)
            XCTAssertEqual(unboxed.dictionaries["one"]!, ["a" : 1, "b" : 2])
            XCTAssertEqual(unboxed.dictionaries["two"]!, ["c" : 3, "d" : 4])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testNestedArrayAsValueOfDictionary() {
        struct Model: Unboxable {
            let dictionaries: [String : [Int]]
            
            init(unboxer: Unboxer) {
                self.dictionaries = unboxer.unbox("dictionaries")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "dictionaries" : [
                "one" : [1, 2],
                "two" : [3, 4]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.dictionaries.count, 2)
            XCTAssertEqual(unboxed.dictionaries["one"]!, [1, 2])
            XCTAssertEqual(unboxed.dictionaries["two"]!, [3, 4])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testThrowingForMissingRequiredValues() {
        let invalidDictionary: UnboxableDictionary = [:]
        
        do {
            try Unbox(invalidDictionary) as UnboxTestMock
            XCTFail("Unbox should have thrown for a missing value")
        } catch UnboxError.InvalidValues(let errors) where !errors.isEmpty {
            guard case .MissingValueForKey(_) = errors.first! else {
                XCTFail("Unbox did not return the correct error type")
                return
            }
        } catch {
            XCTFail("Unbox did not return the correct error type")
        }
    }
    
    func testThrowingForInvalidRequiredValues() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        
        for key in invalidDictionary.keys {
            let invalidValue = NSObject()
            invalidDictionary[key] = invalidValue
            break
        }
        
        do {
            try Unbox(invalidDictionary) as UnboxTestMock
            XCTFail("Unbox should have thrown for an invalid value")
        } catch UnboxError.InvalidValues(let errors) where !errors.isEmpty {
            guard case .InvalidValue(_, _) = errors.first! else {
                XCTFail("Unbox did not return the correct error type")
                return
            }
        } catch {
            XCTFail("Unbox did not return the correct error type")
        }
        
        defer {
            let unboxed: UnboxTestMock? = try? Unbox(invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testThrowingForInvalidData() {
        if let data = "Not a dictionary".dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                try Unbox(data) as UnboxTestMock
                XCTFail("Unbox should have thrown for invalid data")
            } catch UnboxError.InvalidData {
                // Test passed
            } catch {
                XCTFail("Unbox did not return the correct error type")
            }
        } else {
            XCTFail("Could not create data from a string")
        }
    }
    
    func testThrowingForInvalidDataArray() {
        let notDictionaryArray = [12, 13, 9]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(notDictionaryArray, options: []) else {
            return XCTFail()
        }
        
        do {
            try Unbox(data) as UnboxTestMock
            XCTFail()
        } catch UnboxError.InvalidData {
            // Test passed
        } catch {
            XCTFail("Unbox did not return the correct error type")
        }
    }
    
    func testThrowingForSingleInvalidDictionaryInArray() {
        let dictionaries = [
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false),
            ["invalid" : "dictionary"],
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        ]
        
        do {
            try Unbox(dictionaries) as [UnboxTestMock]
            XCTFail()
        } catch {
            // Test passed
        }
    }
    
    func testContext() {
        class Model: Unboxable {
            let nestedUnboxable: Model?
            
            required init(unboxer: Unboxer) {
                if let context = unboxer.context as? String {
                    XCTAssertTrue("context" == context, "")
                } else {
                    XCTFail("Context was of an unexpected type: \(unboxer.context)")
                }
                
                self.nestedUnboxable = unboxer.unbox("nested")
            }
        }
        
        let unboxed: Model? = try? Unbox(["nested" : UnboxableDictionary()], context: "context")
        
        XCTAssertFalse(unboxed == nil, "Could not unbox with a context")
    }
    
    func testRequiredContext() {
        let dictionary = [
            "nested" : [:],
            "nestedArray": [[:]]
        ]
        
        if let model: UnboxTestContextMock = try? Unbox(dictionary, context: "context") {
            XCTAssertEqual(model.context, "context")
            
            if let nestedModel = model.nested {
                XCTAssertEqual(nestedModel.context, "nestedContext")
            } else {
                XCTFail("Failed to unbox nested model")
            }
            
            if let nestedArrayModel = model.nestedArray?.first {
                XCTAssertEqual(nestedArrayModel.context, "nestedArrayContext")
            } else {
                XCTFail("Failed to unbox nested model array")
            }
        } else {
            XCTFail("Failed to unbox")
        }
    }
    
    func testNestedUnboxableContext() {
        struct Model: Unboxable {
            let nested: NestedModel
            
            init(unboxer: Unboxer) {
                self.nested = unboxer.unbox("nested", context: "Context")
            }
        }
        
        struct NestedModel: Unboxable {
            let context: Any?
            
            init(unboxer: Unboxer) {
                self.context = unboxer.context
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "nested": [:]
        ]
        
        do {
            let model: Model = try Unbox(dictionary)
            
            if let stringContext = model.nested.context as? String {
                XCTAssertEqual(stringContext, "Context")
            } else {
                XCTFail("Unexpected context: \(model.nested.context)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAccessingNestedDictionaryWithKeyPath() {
        struct KeyPathModel: Unboxable {
            let intValue: Int
            let dictionary: UnboxableDictionary

            init(unboxer: Unboxer) {
                let intKeyPathComponents = [UnboxTestMock.requiredUnboxableDictionaryKey, "test", UnboxTestMock.requiredIntKey]
                let keyPath = intKeyPathComponents.joinWithSeparator(".")
                self.intValue = unboxer.unbox(keyPath, isKeyPath: true)

                let dictionaryKeyPath = [UnboxTestMock.requiredUnboxableDictionaryKey, "test"].joinWithSeparator(".")
                self.dictionary = unboxer.unbox(dictionaryKeyPath, isKeyPath: true)
            }
        }


        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(false)
        let model: KeyPathModel? = try? Unbox(validDictionary)
        XCTAssertNotNil(model)
        XCTAssertEqual(15, model?.intValue)
        if let result = model?.dictionary[UnboxTestMock.requiredArrayKey] as? [String] {
            XCTAssertEqual(["unbox", "is", "pretty", "cool", "right?"], result)
        } else {
            XCTFail()
        }
    }
    
    func testAccessingNestedArrayWithKeyPath() {
        struct Model: Unboxable {
            let firstName: String
            let lastName: String
            
            init(unboxer: Unboxer) {
                self.firstName = unboxer.unbox("names.0")
                self.lastName = unboxer.unbox("names.1", isKeyPath: true)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "names": ["John", "Appleseed"]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.firstName, "John")
            XCTAssertEqual(unboxed.lastName, "Appleseed")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testKeysWithDotNotTreatedAsKeyPath() {
        struct Model: Unboxable {
            let int: Int
            let string: String
            
            init(unboxer: Unboxer) {
                self.int = unboxer.unbox("int.value", isKeyPath: false)
                self.string = unboxer.unbox("string.value", isKeyPath: false)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "int.value" : 15,
            "string.value" : "hello"
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary)
            XCTAssertEqual(unboxed.int, 15)
            XCTAssertEqual(unboxed.string, "hello")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCustomUnboxing() {
        struct Model {
            let int: Int
            let double: Double
            let string: String
        }
        
        do {
            let dictionary: UnboxableDictionary = [
                "int" : 5,
                "string" : "Hello"
            ]
            let data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            let context = "Context"
            
            let unboxingClosure: Unboxer -> Model? = {
                XCTAssertEqual($0.context as? String, context)
                return Model(int: $0.unbox("int"), double: 3.14, string: $0.unbox("string"))
            }
            
            let unboxedFromDictionary: Model = try Unboxer.performCustomUnboxingWithDictionary(dictionary, context: context, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromDictionary.int, 5)
            XCTAssertEqual(unboxedFromDictionary.double, 3.14)
            XCTAssertEqual(unboxedFromDictionary.string, "Hello")
            
            let unboxedFromData: Model = try Unboxer.performCustomUnboxingWithData(data, context: context, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromData.int, 5)
            XCTAssertEqual(unboxedFromData.double, 3.14)
            XCTAssertEqual(unboxedFromData.string, "Hello")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCustomUnboxingFailedThrows() {
        do {
            try Unboxer.performCustomUnboxingWithDictionary([:], closure: { $0
                return nil
            }) as UnboxTestMock
        } catch UnboxError.CustomUnboxingFailed {
            // Test passed
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCustomUnboxingFromArrayWithMultipleClasses() {
        struct ModelA {
            let int: Int
        }
        
        struct ModelB {
            let string: String
        }
        
        let array: [UnboxableDictionary] = [
            [
                "type" : "A",
                "int" : 22
            ],
            [
                "type" : "B",
                "string" : "hello"
            ]
        ]
        
        do {
            let unboxed: [Any] = try Unboxer.performCustomUnboxingWithArray(array, closure: {
                let unboxer = $0
                let type = unboxer.unbox("type") as String
                
                switch type {
                case "A":
                    return ModelA(int: unboxer.unbox("int"))
                case "B":
                    return ModelB(string: unboxer.unbox("string"))
                default:
                    XCTFail()
                }
                
                return nil
            })
            
            XCTAssertEqual((unboxed.first as! ModelA).int, 22)
            XCTAssertEqual((unboxed.last as! ModelB).string, "hello")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCustomUnboxingFromArrayWithMultipleClassesAndAllowedInvalid() {
        struct ModelA {
            let int: Int
        }
        
        struct ModelB {
            let string: String
        }
        
        let array: [UnboxableDictionary] = [
            [
                "type" : "A",
                "int" : 22
            ],
            [
                "type" : "B",
                "WrongKey" : "hello"
            ]
        ]
        do {
            let unboxed: [Any] = try Unboxer.performCustomUnboxingWithArray(array, allowInvalidElements: true, closure: {
                let unboxer = $0
                let type = unboxer.unbox("type") as String
                
                switch type {
                case "A":
                    return ModelA(int: unboxer.unbox("int"))
                case "B":
                    return ModelB(string: unboxer.unbox("string"))
                default:
                    XCTFail()
                }
                
                return nil
            })
            
            XCTAssertEqual((unboxed.first as! ModelA).int, 22)
            XCTAssertTrue(unboxed.count == 1)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingStartingAtCustomKey() {
        let dictionary: UnboxableDictionary = [
            "A": [
                "int": 14
            ]
        ]
        
        do {
            let unboxed: UnboxTestSimpleMock = try Unbox(dictionary, at: "A")
            XCTAssertEqual(unboxed.int, 14)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingStartingAtMissingCustomKey() {
        let dictionary: UnboxableDictionary = [
            "A": [
                "int": 14
            ]
        ]
        
        do {
            let _ : UnboxTestSimpleMock = try Unbox(dictionary, at: "B")
            XCTFail()
        } catch {
            // Test Passed
        }
    }
    
    func testUnboxingStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary = [
            "A": [
                "B": [
                    "int": 14
                ]
            ]
        ]
        
        do {
            let unboxed: UnboxTestSimpleMock = try Unbox(dictionary, at: "A.B", isKeyPath: true)
            XCTAssertEqual(unboxed.int, 14)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingStartingAtMissingCustomKeyPath() {
        let dictionary: UnboxableDictionary = [
            "A": [
                "int": 14
            ]
        ]
        
        do {
            let _: UnboxTestSimpleMock = try Unbox(dictionary, at: "A.B", isKeyPath: true)
            XCTFail()
        } catch {
            // Test Passed
        }
    }
    
    func testUnboxingArrayStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary = [
            "A": [
                "B": [
                    [
                        "int": 14
                    ],
                    [
                        "int": 14
                    ],
                    [
                        "int": 14
                    ]
                ]
            ]
        ]
        
        do {
            let unboxedArray: [UnboxTestSimpleMock] = try Unbox(dictionary, at: "A.B", isKeyPath: true)
            unboxedArray.forEach {
                XCTAssertEqual($0.int, 14)
            }
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingArrayIndexStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary =
            ["A": ["B": [["int": 14], ["int": 14], ["int": 20]]]]
        
        do {
            let unboxed: UnboxTestSimpleMock = try Unbox(dictionary, at: "A.B.2", isKeyPath: true)
            XCTAssertEqual(unboxed.int, 20)
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingArrayInvalidIndexStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary =
            ["A": ["B": [["int": 14], ["int": 14], ["int": 20]]]]
        
        do {
            try Unbox(dictionary, at: "A.B.3", isKeyPath: true) as UnboxTestSimpleMock
        } catch {
            // Test Passed
        }
    }
    
    func testUnboxingArrayOfStringsTransformedToInt() {
        let dictionary: UnboxableDictionary = ["intArray": ["123", "456", "789"]]
        
        struct ModelA: Unboxable {
            let intArray: [Int]
            init(unboxer: Unboxer) {
                self.intArray = unboxer.unbox("intArray")
            }
        }
        
        do {
            let modelA: ModelA = try Unbox(dictionary)
            XCTAssertEqual(modelA.intArray[0], 123)
            XCTAssertEqual(modelA.intArray[1], 456)
            XCTAssertEqual(modelA.intArray[2], 789)
        } catch {
            XCTFail()
        }
    }
    
    func testUnboxingArrayOfBadStringsTransformedToInt() {
        let dictionary: UnboxableDictionary = ["intArray": ["123", "abc", "789"]]
        
        struct ModelA: Unboxable {
            let intArray: [Int]
            init(unboxer: Unboxer) {
                self.intArray = unboxer.unbox("intArray")
            }
        }
        
        do {
            try Unbox(dictionary) as ModelA
            XCTFail()
        } catch {
            // Test Passed
        }
    }
    
}

private func UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: Bool) -> UnboxableDictionary {
    var dictionary: UnboxableDictionary = [
        UnboxTestMock.requiredBoolKey : true,
        UnboxTestMock.requiredIntKey : 15,
        UnboxTestMock.requiredDoubleKey : Double(1.5),
        UnboxTestMock.requiredFloatKey : Float(3.14),
        UnboxTestMock.requiredCGFloatKey : 0.72,
        UnboxTestMock.requiredEnumKey : 1,
        UnboxTestMock.requiredStringKey :  "hello",
        UnboxTestMock.requiredURLKey : "http://www.google.com",
        UnboxTestMock.requiredArrayKey : ["unbox", "is", "pretty", "cool", "right?"],
        UnboxTestMock.requiredEnumArrayKey : [0, 1],
    ]
    
    if !nested {
        dictionary[UnboxTestMock.requiredUnboxableKey] = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)
        dictionary[UnboxTestMock.requiredUnboxableArrayKey] = [UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)]
        dictionary[UnboxTestMock.requiredUnboxableDictionaryKey] = ["test" : UnboxTestDictionaryWithAllRequiredKeysWithValidValues(true)]
    }
    
    return dictionary
}

// MARK: - Mocks

private enum UnboxTestEnum: Int, UnboxableEnum {
    case First
    case Second
    
    private static func unboxFallbackValue() -> UnboxTestEnum {
        return .First
    }
}

private struct UnboxTestDictionaryKey: UnboxableKey {
    var hashValue: Int { return self.key.hashValue }
    
    let key: String
    
    static func transformUnboxedKey(unboxedKey: String) -> UnboxTestDictionaryKey? {
        if unboxedKey == "FAIL" {
            return nil
        }
        
        return UnboxTestDictionaryKey(key: unboxedKey)
    }
    
    static func unboxFallbackValue() -> UnboxTestDictionaryKey {
        return UnboxTestDictionaryKey(key: "")
    }
}

private func ==(lhs: UnboxTestDictionaryKey, rhs: UnboxTestDictionaryKey) -> Bool {
    return lhs.key == rhs.key
}

private class UnboxTestBaseMock: Unboxable {
    static let requiredBoolKey = "requiredBool"
    static let optionalBoolKey = "optionalBool"
    static let requiredIntKey = "requiredInt"
    static let optionalIntKey = "optionalInt"
    static let requiredDoubleKey = "requiredDouble"
    static let optionalDoubleKey = "optionalDouble"
    static let requiredFloatKey = "requiredFloat"
    static let optionalFloatKey = "optionalFloat"
    static let requiredCGFloatKey = "requiredCGFloat"
    static let optionalCGFloatKey = "optionalCGFloat"
    static let requiredEnumKey = "requiredEnum"
    static let optionalEnumKey = "optionalEnum"
    static let requiredStringKey = "requiredString"
    static let optionalStringKey = "optionalString"
    static let requiredURLKey = "requiredURL"
    static let optionalURLKey = "optionalURL"
    static let requiredArrayKey = "requiredArray"
    static let optionalArrayKey = "optionalArray"
    static let requiredEnumArrayKey = "requiredEnumArray"
    static let optionalEnumArrayKey = "optionalEnumArray"
    
    let requiredBool: Bool
    let optionalBool: Bool?
    let requiredInt: Int
    let optionalInt: Int?
    let requiredDouble: Double
    let optionalDouble: Double?
    let requiredFloat: Float
    let optionalFloat: Float?
    let requiredCGFloat: CGFloat
    let optionalCGFloat: CGFloat?
    let requiredEnum: UnboxTestEnum
    let optionalEnum: UnboxTestEnum?
    let requiredString: String
    let optionalString: String?
    let requiredURL: NSURL
    let optionalURL: NSURL?
    let requiredArray: [String]
    let optionalArray: [String]?
    let requiredEnumArray: [UnboxTestEnum]
    let optionalEnumArray: [UnboxTestEnum]?
    
    required init(unboxer: Unboxer) {
        self.requiredBool = unboxer.unbox(UnboxTestBaseMock.requiredBoolKey)
        self.optionalBool = unboxer.unbox(UnboxTestBaseMock.optionalBoolKey)
        self.requiredInt = unboxer.unbox(UnboxTestBaseMock.requiredIntKey)
        self.optionalInt = unboxer.unbox(UnboxTestBaseMock.optionalIntKey)
        self.requiredDouble = unboxer.unbox(UnboxTestBaseMock.requiredDoubleKey)
        self.optionalDouble = unboxer.unbox(UnboxTestBaseMock.optionalDoubleKey)
        self.requiredFloat = unboxer.unbox(UnboxTestBaseMock.requiredFloatKey)
        self.optionalFloat = unboxer.unbox(UnboxTestBaseMock.optionalFloatKey)
        self.requiredCGFloat = unboxer.unbox(UnboxTestBaseMock.requiredCGFloatKey)
        self.optionalCGFloat = unboxer.unbox(UnboxTestBaseMock.optionalCGFloatKey)
        self.requiredEnum = unboxer.unbox(UnboxTestBaseMock.requiredEnumKey)
        self.optionalEnum = unboxer.unbox(UnboxTestBaseMock.optionalEnumKey)
        self.requiredString = unboxer.unbox(UnboxTestBaseMock.requiredStringKey)
        self.optionalString = unboxer.unbox(UnboxTestBaseMock.optionalStringKey)
        self.requiredURL = unboxer.unbox(UnboxTestBaseMock.requiredURLKey)
        self.optionalURL = unboxer.unbox(UnboxTestBaseMock.optionalURLKey)
        self.requiredArray = unboxer.unbox(UnboxTestBaseMock.requiredArrayKey)
        self.optionalArray = unboxer.unbox(UnboxTestBaseMock.optionalArrayKey)
        self.requiredEnumArray = unboxer.unbox(UnboxTestBaseMock.requiredEnumArrayKey)
        self.optionalEnumArray = unboxer.unbox(UnboxTestBaseMock.optionalEnumArrayKey)
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
            case UnboxTestBaseMock.requiredCGFloatKey:
                verificationOutcome = self.verifyPropertyValue(self.requiredCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalCGFloatKey:
                verificationOutcome = self.verifyPropertyValue(self.optionalCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(self.requiredEnum, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(self.optionalEnum, againstDictionaryValue: value)
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
            case UnboxTestBaseMock.requiredEnumArrayKey:
                verificationOutcome = self.verifyEnumArrayPropertyValue(self.requiredEnumArray, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalEnumArrayKey:
                verificationOutcome = self.verifyEnumArrayPropertyValue(self.optionalEnumArray, againstDictionaryValue: value)
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
    
    func verifyEnumPropertyValue<T: UnboxableEnum where T: Equatable>(propertyValue: T?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let rawValue = dictionaryValue as? T.RawValue {
            if let enumValue = T(rawValue: rawValue) {
                return propertyValue == enumValue
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
    
    func verifyEnumArrayPropertyValue<T: UnboxableEnum where T: Equatable>(propertyValue: [T]?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let propertyValue = propertyValue {
            if let dictionaryArrayValue = dictionaryValue as? [T.RawValue] {
                for i in 0..<dictionaryArrayValue.count {
                    guard let enumValue = T(rawValue: dictionaryArrayValue[i]) else {
                        return false
                    }
                    
                    guard case enumValue = propertyValue[i] else {
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
    
    required init(unboxer: Unboxer) {
        self.requiredUnboxable = unboxer.unbox(UnboxTestMock.requiredUnboxableKey)
        self.optionalUnboxable = unboxer.unbox(UnboxTestMock.optionalUnboxableKey)
        self.requiredUnboxableArray = unboxer.unbox(UnboxTestMock.requiredUnboxableArrayKey)
        self.optionalUnboxableArray = unboxer.unbox(UnboxTestMock.optionalUnboxableArrayKey)
        self.requiredUnboxableDictionary = unboxer.unbox(UnboxTestMock.requiredUnboxableDictionaryKey)
        self.optionalUnboxableDictionary = unboxer.unbox(UnboxTestMock.optionalUnboxableDictionaryKey)
        
        super.init(unboxer: unboxer)
    }
}

private final class UnboxTestContextMock: UnboxableWithContext {
    let context: String
    let nested: UnboxTestContextMock?
    let nestedArray: [UnboxTestContextMock]?
    
    init(unboxer: Unboxer, context: String) {
        self.context = context
        self.nested = unboxer.unbox("nested", context: "nestedContext")
        self.nestedArray = unboxer.unbox("nestedArray", context: "nestedArrayContext")
    }
}

private struct UnboxTestSimpleMock: Unboxable, Equatable {
    let int: Int
    
    init(int: Int) {
        self.int = int
    }
    
    init(unboxer: Unboxer) {
        self.int = unboxer.unbox("int")
    }
}

private func ==(lhs: UnboxTestSimpleMock, rhs: UnboxTestSimpleMock) -> Bool {
    return lhs.int == rhs.int
}
