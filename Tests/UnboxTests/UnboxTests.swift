import Foundation
import XCTest
import Unbox

// MARK: - Tests

class UnboxTests: XCTestCase {
    func testWithOnlyValidRequiredValues() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        let unboxed: UnboxTestMock? = try? unbox(dictionary: dictionary)
        XCTAssertNotNil(unboxed, "Failed to unbox valid dictionary")
        unboxed?.verifyAgainstDictionary(dictionary: dictionary)
    }
    
    func testWithMissingRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary.removeValue(forKey: key)
            
            let unboxed: UnboxTestMock? = try? unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary[key] = NSObject()
            
            let unboxed: UnboxTestMock? = try? unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredURL() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        invalidDictionary[UnboxTestMock.requiredURLKey] = "Clearly not a URL!"
        
        let unboxed: UnboxTestMock? = try? unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxed, "Unbox did not return nil for a dictionary with an invalid required URL value")
    }
    
    func testAutomaticTransformationOfStringsToRawTypes() {
        struct Model: Unboxable {
            let requiredInt: Int
            let optionalInt: Int?
            let requiredDouble: Double
            let optionalDouble: Double?
            
            init(unboxer: Unboxer) throws {
                self.requiredInt = try unboxer.unbox(key: "requiredInt")
                self.optionalInt = unboxer.unbox(key: "optionalInt")
                self.requiredDouble = try unboxer.unbox(key: "requiredDouble")
                self.optionalDouble = unboxer.unbox(key: "optionalDouble")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "requiredInt" : "7",
            "optionalInt" : "14",
            "requiredDouble" : "3.14",
            "optionalDouble" : "7.12"
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": Int32.max,
            "optional1": Int32.max
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.required, Int32.max)
            XCTAssertEqual(unboxed.optional1, Int32.max)
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
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": Int64.max,
            "optional1": Int64.max
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.required, Int64.max)
            XCTAssertEqual(unboxed.optional1, Int64.max)
            XCTAssertNil(unboxed.optional2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUInt32() {
        struct Model: Unboxable {
            let required: UInt32
            let optional1: UInt32?
            let optional2: UInt32?
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": UInt32.max,
            "optional1": UInt32.min
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.required, UInt32.max)
            XCTAssertEqual(unboxed.optional1, UInt32.min)
            XCTAssertNil(unboxed.optional2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUInt64() {
        struct Model: Unboxable {
            let required: UInt64
            let optional1: UInt64?
            let optional2: UInt64?
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": UInt64.max,
            "optional1": UInt64.min
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.required, UInt64.max)
            XCTAssertEqual(unboxed.optional1, UInt64.min)
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
            
            init(unboxer: Unboxer) throws {
                self.bool1 = try unboxer.unbox(key: "bool1")
                self.bool2 = try unboxer.unbox(key: "bool2")
                self.bool3 = try unboxer.unbox(key: "bool3")
                self.double = try unboxer.unbox(key: "double")
                self.float = try unboxer.unbox(key: "float")
                self.string = unboxer.unbox(key: "string")
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
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertFalse(unboxed.bool1)
            XCTAssertTrue(unboxed.bool2)
            XCTAssertTrue(unboxed.bool3)
            XCTAssertEqual(unboxed.double, Double(27))
            XCTAssertEqual(unboxed.float, Float(39))
            XCTAssertEqual(unboxed.string, "7")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testArrayOfURLs() {
        struct Model: Unboxable {
            let optional: [URL]?
            let required: [URL]
            
            init(unboxer: Unboxer) throws {
                self.optional = unboxer.unbox(key: "optional")
                self.required = try unboxer.unbox(key: "required")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "optional" : ["https://www.google.com"],
            "required" : ["https://github.com/johnsundell/unbox"]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.optional?.count, 1)
            XCTAssertEqual(unboxed.optional?.first, URL(string: "https://www.google.com"))
            XCTAssertEqual(unboxed.required, [URL(string: "https://github.com/johnsundell/unbox")!])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testArrayOfEnums() {
        struct Model: Unboxable {
            let optionalA: [UnboxTestEnum]?
            let optionalB: [UnboxTestEnum]?
            let required: [UnboxTestEnum]
            
            init(unboxer: Unboxer) throws {
                self.optionalA = unboxer.unbox(key: "optionalA")
                self.optionalB = unboxer.unbox(key: "optionalB")
                self.required = try unboxer.unbox(key: "required")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "optionalA" : [0, 1],
            "required" : [1, 0]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.optionalA!, [.First, .Second])
            XCTAssertNil(unboxed.optionalB)
            XCTAssertEqual(unboxed.required, [.Second, .First])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testRequiredDateFormatting() {
        struct Model: Unboxable {
            let date: Date
            let dateArray: [Date]
            
            init(unboxer: Unboxer) throws {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = try unboxer.unbox(key: "date", formatter: formatter)
                self.dateArray = try unboxer.unbox(key: "dateArray", formatter: formatter)
            }
        }
        
        struct AllowInvalidElementsModel: Unboxable {
            let date: Date
            let dateArray: [Date]
            
            init(unboxer: Unboxer) throws {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = try unboxer.unbox(key: "date", formatter: formatter)
                self.dateArray = try unboxer.unbox(key: "dateArray", formatter: formatter, allowInvalidElements: true)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "date" : "2015-12-15",
            "dateArray" : ["2015-12-15"]
        ]
        
        // Valid tests:
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.year, from: unboxed.date), 2015)
            XCTAssertEqual(calendar.component(.month, from: unboxed.date), 12)
            XCTAssertEqual(calendar.component(.day, from: unboxed.date), 15)
            
            if let firstDate = unboxed.dateArray.first {
                XCTAssertEqual(calendar.component(.year, from: firstDate), 2015)
                XCTAssertEqual(calendar.component(.month, from: firstDate), 12)
                XCTAssertEqual(calendar.component(.day, from: firstDate), 15)
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
            
            let unboxed: AllowInvalidElementsModel = try unbox(dictionary: invalidValueDateArrayDictionary)
            
            XCTAssertEqual(unboxed.dateArray.count, 1)
            
            if let firstDate = unboxed.dateArray.first {
                let calendar = Calendar.current
                XCTAssertEqual(calendar.component(.year, from: firstDate), 2015)
                XCTAssertEqual(calendar.component(.month, from: firstDate), 12)
                XCTAssertEqual(calendar.component(.day, from: firstDate), 15)
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
            
            _ = try unbox(dictionary: invalidDateDictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
        
        do {
            let invalidDateArrayDictionary: UnboxableDictionary = [
                "date" : "2015-12-15",
                "dateArray" : ["2015-12-tuesday"]
            ]
            
            _ = try unbox(dictionary: invalidDateArrayDictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testOptionalDateFormattingFailureNotThrowing() {
        struct Model: Unboxable {
            let date: Date?
            let dateArray: [Date]?
            
            init(unboxer: Unboxer) {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox(key: "date", formatter: formatter)
                self.dateArray = unboxer.unbox(key: "dateArray", formatter: formatter)
            }
        }
        
        struct AllowInvalidElementsModel: Unboxable {
            let date: Date?
            let dateArray: [Date]?
            
            init(unboxer: Unboxer) {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox(key: "date", formatter: formatter)
                self.dateArray = unboxer.unbox(key: "dateArray", formatter: formatter, allowInvalidElements: true)
            }
        }
        
        do {
            let invalidDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday",
                "dateArray" : ["2015-12-tuesday"]
            ]
            
            let unboxed: Model = try unbox(dictionary: invalidDictionary)
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
            
            let unboxed: AllowInvalidElementsModel = try unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed.date)
            XCTAssertEqual(unboxed.dateArray?.count, 1)
            
            let calendar = Calendar.current
            if let firstDate = unboxed.dateArray?.first {
                XCTAssertEqual(calendar.component(.year, from: firstDate), 2015)
                XCTAssertEqual(calendar.component(.month, from: firstDate), 12)
                XCTAssertEqual(calendar.component(.day, from: firstDate), 15)
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
            
            init(unboxer: Unboxer) throws {
                self.requiredIntDictionary = try unboxer.unbox(key: "requiredIntDictionary")
                self.optionalIntDictionary = unboxer.unbox(key: "optionalIntDictionary")
                self.requiredModelDictionary = try unboxer.unbox(key: "requiredModelDictionary")
                self.optionalModelDictionary = unboxer.unbox(key: "optionalModelDictionary")
            }
        }
        
        do {
            let unboxed: Model = try unbox(dictionary: [
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
            
            let unboxedWithoutOptionals: Model = try unbox(dictionary: [
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
                self.dictionary = unboxer.unbox(key: "dictionary")
            }
        }
        
        do {
            let unboxed: Model = try unbox(dictionary: [
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
            
            init(unboxer: Unboxer) throws {
                self.dictionary = try unboxer.unbox(key: "dictionary")
            }
        }
        
        do {
            _ = try unbox(dictionary: [
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
            
            init(unboxer: Unboxer) throws {
                self.requiredModelDictionary = try unboxer.unbox(key: "requiredModelDictionary")
                self.optionalModelDictionary = unboxer.unbox(key: "optionalModelDictionary")
            }
        }
        
        do {
            let unboxed: Model = try unbox(dictionary: [
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
            
            let unboxedWithoutOptionals: Model = try unbox(dictionary: [
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
            
            init(unboxer: Unboxer) throws {
                self.requiredModelDictionary = try unboxer.unbox(key: "requiredModelDictionary")
            }
        }
        
        do {
            let _ : Model = try unbox(dictionary: [
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
            
            init(unboxer: Unboxer) throws {
                self.requiredModelDictionary = try unboxer.unbox(key: "requiredModelDictionary", allowInvalidElements:true)
            }
        }
        
        do {
            let unboxed : Model = try unbox(dictionary: [
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
                self.optionalModelDictionary = unboxer.unbox(key: "optionalModelDictionary")
            }
        }
        
        do {
            let unboxed : Model = try unbox(dictionary: [
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
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = "Totally not unboxable"
        
        let unboxedFromString: UnboxTestMock? = try? unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxedFromString, "Unbox did not return nil for a string")
        
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = ["cannotBe" : "unboxed"]
        
        let unboxedFromInvalidDictionary: UnboxTestMock? = try? unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxedFromInvalidDictionary, "Unbox did not return nil for an invalid dictionary")
    }
    
    func testWithInvalidOptionalValue() {
        var validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        validDictionary[UnboxTestMock.optionalBoolKey] = "Not a Bool"
        
        let unboxed: UnboxTestMock? = try? unbox(dictionary: validDictionary)
        XCTAssertNotNil(unboxed, "Invalid optional values should be ignored")
    }
    
    func testUnboxingFromValidData() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary as AnyObject, options: [])
            let unboxed: UnboxTestMock? = try? unbox(data: data)
            XCTAssertNotNil(unboxed, "Could not unbox from data")
        } catch {
            XCTFail("Could not decode data from dictionary: \(dictionary)")
        }
    }
    
    func testUnboxingFromArbitraryKeysDictionary() {
        struct Model: Unboxable {
            let required: String
            let optional: String?
            
            init(unboxer: Unboxer) throws {
                required = try unboxer.unbox(key: "required")
                optional = unboxer.unbox(key: "optional")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "random_unique_data_1" : [
                "required" : "Hello",
                "optional" : "World"
            ],
            "random_unique_data_2" : [
                "required" : "Unbox",
                "optional" : "Test"
            ]
        ]
        
        do {
            let unboxed: [String: Model] = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed["random_unique_data_1"]?.required, "Hello")
            XCTAssertEqual(unboxed["random_unique_data_1"]?.optional, "World")
            XCTAssertEqual(unboxed["random_unique_data_2"]?.required, "Unbox")
            XCTAssertEqual(unboxed["random_unique_data_2"]?.optional, "Test")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUnboxingFromArbitraryKeysData() {
        struct Model: Unboxable {
            let required: String
            let optional: String?
            
            init(unboxer: Unboxer) throws {
                required = try unboxer.unbox(key: "required")
                optional = unboxer.unbox(key: "optional")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "random_unique_data_1" : [
                "required" : "Hello",
                "optional" : "World"
            ],
            "random_unique_data_2" : [
                "required" : "Unbox",
                "optional" : "Test"
            ]
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            XCTFail("Failed to serialize dictionary to data")
            return
        }
        
        do {
            let unboxed: [String: Model] = try unbox(data: data)
            XCTAssertEqual(unboxed["random_unique_data_1"]?.required, "Hello")
            XCTAssertEqual(unboxed["random_unique_data_1"]?.optional, "World")
            XCTAssertEqual(unboxed["random_unique_data_2"]?.required, "Unbox")
            XCTAssertEqual(unboxed["random_unique_data_2"]?.optional, "Test")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
    }
    
    func testUnboxingValueFromArray() {
        struct Model: Unboxable {
            let required: String
            let optional: String?
            
            init(unboxer: Unboxer) throws {
                self.required = try unboxer.unbox(keyPath: "required.0")
                self.optional = unboxer.unbox(keyPath: "optional.1")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required" : ["Hello", "This"],
            "optional" : ["Is", "Unbox"]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.required, "Hello")
            XCTAssertEqual(unboxed.optional, "Unbox")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUnboxingValueFromOutOfArrayBoundsThrows() {
        struct Model: Unboxable {
            let int: Int
            
            init(unboxer: Unboxer) throws {
                self.int = try unboxer.unbox(keyPath: "values.3")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "values" : [7, 9, 22]
        ]
        
        do {
            _ = try unbox(dictionary: dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testUnboxingArrayOfDictionaries() {
        let dictionaries = [
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false),
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false),
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        ]
        
        guard let unboxedArray: [UnboxTestMock] = try? unbox(dictionaries: dictionaries) else {
            return XCTFail()
        }
        
        XCTAssertEqual(unboxedArray.count, 3)
        
        for unboxed in unboxedArray {
            unboxed.verifyAgainstDictionary(dictionary: UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false))
        }
    }
    
    func testUnboxingArrayOfDictionariesWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) throws {
                self.string = try unboxer.unbox(key: "string")
            }
        }
        
        let dictionaries: [UnboxableDictionary] = [
            ["string" : "one"],
            ["invalid" : "element"],
            ["string" : "two"]
        ]
        
        do {
            let unboxed: [Model] = try unbox(dictionaries: dictionaries, allowInvalidElements: true)
            XCTAssertEqual(unboxed.first?.string, "one")
            XCTAssertEqual(unboxed.last?.string, "two")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUnboxingNestedArrayOfDictionariesWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let nestedModels: [NestedModel]
            
            init(unboxer: Unboxer) throws {
                self.nestedModels = try unboxer.unbox(key: "nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) throws {
                self.string = try unboxer.unbox(key: "string")
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
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.nestedModels.first?.string, "one")
            XCTAssertEqual(unboxed.nestedModels.last?.string, "two")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testUnboxingNestedDictionaryWhileAllowingInvalidElements() {
        struct Model: Unboxable {
            let nestedModels: [String : NestedModel]
            
            init(unboxer: Unboxer) throws {
                self.nestedModels = try unboxer.unbox(key: "nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) throws {
                self.string = try unboxer.unbox(key: "string")
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
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.arrays = try unboxer.unbox(key: "arrays")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "arrays": [
                [1, 2],
                [3, 4]
            ]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.dictionaries = try unboxer.unbox(key: "dictionaries")
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
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.dictionaries = try unboxer.unbox(key: "dictionaries")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "dictionaries" : [
                "one" : [1, 2],
                "two" : [3, 4]
            ]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.dictionaries.count, 2)
            XCTAssertEqual(unboxed.dictionaries["one"]!, [1, 2])
            XCTAssertEqual(unboxed.dictionaries["two"]!, [3, 4])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testThrowingForMissingRequiredValue() {
        struct Model: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) throws {
                self.string = try unboxer.unbox(key: "string")
            }
        }
        
        do {
            _ = try unbox(dictionary: [:]) as Model
            XCTFail("Unbox should have thrown for a missing value")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"string\": The key \"string\" is missing.")
        }
    }
    
    func testThrowingForInvalidRequiredValue() {
        struct Model: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) throws {
                self.string = try unboxer.unbox(key: "string")
            }
        }
        
        do {
            _ = try unbox(dictionary: ["string" : []]) as Model
            XCTFail("Unbox should have thrown for an invalid value")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"string\": Invalid value ([]) for key \"string\".")
        }
    }
    
    func testThrowingForInvalidData() {
        if let data = "Not a dictionary".data(using: String.Encoding.utf8) {
            do {
                _ = try unbox(data: data) as UnboxTestMock
                XCTFail("Unbox should have thrown for invalid data")
            } catch {
                XCTAssertEqual("\(error)", "[UnboxError] Invalid data.")
            }
        } else {
            XCTFail("Could not create data from a string")
        }
    }
    
    func testThrowingForInvalidDataArray() {
        let notDictionaryArray = [12, 13, 9]
        
        guard let data = try? JSONSerialization.data(withJSONObject: notDictionaryArray as AnyObject, options: []) else {
            return XCTFail()
        }
        
        do {
            _ = try unbox(data: data) as UnboxTestMock
            XCTFail("Unbox should have thrown for invalid data")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] Invalid data.")
        }
    }
    
    func testThrowingForSingleInvalidDictionaryInArray() {
        let dictionaries = [
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false),
            ["invalid" : "dictionary"],
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        ]
        
        do {
            _ = try unbox(dictionaries: dictionaries) as [UnboxTestMock]
            XCTFail()
        } catch {
            // Test passed
        }
    }
    
    func testRequiredContext() {
        let dictionary: UnboxableDictionary = [
            "nested" : [:],
            "nestedArray": [[:]],
            "nestedDictionary": ["key" : [:]]
        ]
        
        if let model: UnboxTestContextMock = try? unbox(dictionary: dictionary, context: "context") {
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
            
            if let nestedDictionaryModel = model.nestedDictionary?.first?.value {
                XCTAssertEqual(nestedDictionaryModel.context, "nestedDictionaryContext")
            } else {
                XCTFail("Failed to unbox nested model dictionary")
            }
        } else {
            XCTFail("Failed to unbox")
        }
    }

    func testAccessingNestedDictionaryWithKeyPath() {
        struct KeyPathModel: Unboxable {
            let intValue: Int
            let dictionary: UnboxableDictionary

            init(unboxer: Unboxer) throws {
                let intKeyPathComponents = [UnboxTestMock.requiredUnboxableDictionaryKey, "test", UnboxTestMock.requiredIntKey]
                let keyPath = intKeyPathComponents.joined(separator: ".")
                self.intValue = try unboxer.unbox(keyPath: keyPath)

                let dictionaryKeyPath = [UnboxTestMock.requiredUnboxableDictionaryKey, "test"].joined(separator: ".")
                self.dictionary = try unboxer.unbox(keyPath: dictionaryKeyPath)
            }
        }


        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        do {
            let model: KeyPathModel = try unbox(dictionary: validDictionary)
            XCTAssertEqual(15, model.intValue)
            
            let result = model.dictionary[UnboxTestMock.requiredArrayKey] as! [String]
            XCTAssertEqual(["unbox", "is", "pretty", "cool", "right?"], result)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testAccessingNestedArrayWithKeyPath() {
        struct Model: Unboxable {
            let firstName: String
            let lastName: String
            
            init(unboxer: Unboxer) throws {
                self.firstName = try unboxer.unbox(keyPath: "names.0")
                self.lastName = try unboxer.unbox(keyPath: "names.1")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "names": ["John", "Appleseed"]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            
            init(unboxer: Unboxer) throws {
                self.int = try unboxer.unbox(key: "int.value")
                self.string = try unboxer.unbox(key: "string.value")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "int.value" : 15,
            "string.value" : "hello"
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
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
            let data = try JSONSerialization.data(withJSONObject: dictionary as AnyObject, options: [])
            
            let unboxingClosure: (Unboxer) -> Model? = {
                return try? Model(int: $0.unbox(key: "int"), double: 3.14, string: $0.unbox(key: "string"))
            }
            
            let unboxedFromDictionary: Model = try Unboxer.performCustomUnboxing(dictionary: dictionary, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromDictionary.int, 5)
            XCTAssertEqual(unboxedFromDictionary.double, 3.14)
            XCTAssertEqual(unboxedFromDictionary.string, "Hello")
            
            let unboxedFromData: Model = try Unboxer.performCustomUnboxing(data: data, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromData.int, 5)
            XCTAssertEqual(unboxedFromData.double, 3.14)
            XCTAssertEqual(unboxedFromData.string, "Hello")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCustomUnboxingFailedThrows() {
        do {
            _ = try Unboxer.performCustomUnboxing(dictionary: [:], closure: { _ in
                return nil
            }) as UnboxTestMock
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] Custom unboxing failed.")
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
            let unboxed: [Any] = try Unboxer.performCustomUnboxing(array: array, closure: {
                let unboxer = $0
                let type = try unboxer.unbox(key: "type") as String
                
                switch type {
                case "A":
                    return try ModelA(int: unboxer.unbox(key: "int"))
                case "B":
                    return try ModelB(string: unboxer.unbox(key: "string"))
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
            let unboxed: [Any] = try Unboxer.performCustomUnboxing(array: array, allowInvalidElements: true, closure: {
                let unboxer = $0
                let type = try unboxer.unbox(key: "type") as String
                
                switch type {
                case "A":
                    return try ModelA(int: unboxer.unbox(key: "int"))
                case "B":
                    return try ModelB(string: unboxer.unbox(key: "string"))
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
    
    func testBorderlineBooleansUnboxing() {
        struct Model {
            let bool1: Bool
            let bool2: Bool
            let bool3: Bool
            let bool4: Bool
            let bool5: Bool
            let bool6: Bool
            let bool7: Bool
            let bool8: Bool
        }
        
        do {
            let dictionary: UnboxableDictionary = [
                "bool1": "True",
                "bool2": "false",
                "bool3": "t",
                "bool4": "F",
                "bool5": "YES",
                "bool6": "n",
                "bool7": true,
                "bool8": false
            ]
            
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            
            let unboxingClosure: (Unboxer) throws -> Model = {
                return try Model(bool1: $0.unbox(key: "bool1"), bool2: $0.unbox(key: "bool2"), bool3: $0.unbox(key: "bool3"), bool4: $0.unbox(key: "bool4"), bool5: $0.unbox(key: "bool5"), bool6: $0.unbox(key: "bool6"), bool7: $0.unbox(key: "bool7"), bool8: $0.unbox(key: "bool8"))
            }
            
            let unboxedFromDictionary: Model = try Unboxer.performCustomUnboxing(dictionary: dictionary, closure: unboxingClosure)
            
            XCTAssertEqual(unboxedFromDictionary.bool1, true)
            XCTAssertEqual(unboxedFromDictionary.bool2, false)
            XCTAssertEqual(unboxedFromDictionary.bool3, true)
            XCTAssertEqual(unboxedFromDictionary.bool4, false)
            XCTAssertEqual(unboxedFromDictionary.bool5, true)
            XCTAssertEqual(unboxedFromDictionary.bool6, false)
            XCTAssertEqual(unboxedFromDictionary.bool7, true)
            XCTAssertEqual(unboxedFromDictionary.bool8, false)
            
            
            let unboxedFromData: Model = try Unboxer.performCustomUnboxing(data: data, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromData.bool1, true)
            XCTAssertEqual(unboxedFromData.bool2, false)
            XCTAssertEqual(unboxedFromData.bool3, true)
            XCTAssertEqual(unboxedFromData.bool4, false)
            XCTAssertEqual(unboxedFromData.bool5, true)
            XCTAssertEqual(unboxedFromData.bool6, false)
            XCTAssertEqual(unboxedFromData.bool7, true)
            XCTAssertEqual(unboxedFromData.bool8, false)
            
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
            let unboxed: UnboxTestSimpleMock = try unbox(dictionary: dictionary, atKey: "A")
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
            let _ : UnboxTestSimpleMock = try unbox(dictionary: dictionary, atKey: "B")
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
            let unboxed: UnboxTestSimpleMock = try unbox(dictionary: dictionary, atKeyPath: "A.B")
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
            let _: UnboxTestSimpleMock = try unbox(dictionary: dictionary, atKeyPath: "A.B")
            XCTFail()
        } catch {
            // Test Passed
        }
    }
    
    func testUnboxingArrayStartingAtCustomKeyPath() {
        struct Model: Unboxable {
            let int: Int
            
            init(unboxer: Unboxer) throws {
                int = try unboxer.unbox(key: "int")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "A": [
                "B": [
                    [
                        "int": 14
                    ],
                    [
                        "int": 15
                    ],
                    [
                        "int": 16
                    ]
                ]
            ]
        ]
        
        func verify(array: [Model]) {
            XCTAssertEqual(array.count, 3)
            XCTAssertEqual(array[0].int, 14)
            XCTAssertEqual(array[1].int, 15)
            XCTAssertEqual(array[2].int, 16)
        }
        
        do {
            let arrayA: [Model] = try unbox(dictionary: dictionary, atKeyPath: "A.B")
            verify(array: arrayA)
            
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let arrayB: [Model] = try unbox(data: data, atKeyPath: "A.B")
            verify(array: arrayB)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingArrayIndexStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary =
            ["A": ["B": [["int": 14], ["int": 14], ["int": 20]]]]
        
        do {
            let unboxed: UnboxTestSimpleMock = try unbox(dictionary: dictionary, atKeyPath: "A.B.2")
            XCTAssertEqual(unboxed.int, 20)
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUnboxingArrayInvalidIndexStartingAtCustomKeyPath() {
        let dictionary: UnboxableDictionary =
            ["A": ["B": [["int": 14], ["int": 14], ["int": 20]]]]
        
        do {
            _ = try unbox(dictionary: dictionary, atKeyPath: "A.B.3") as UnboxTestSimpleMock
            XCTFail("Should have thrown")
        } catch {
            // Test Passed
        }
    }
    
    func testUnboxingArrayOfStringsTransformedToInt() {
        let dictionary: UnboxableDictionary = ["intArray": ["123", "456", "789"]]
        
        struct ModelA: Unboxable {
            let intArray: [Int]
            init(unboxer: Unboxer) throws {
                self.intArray = try unboxer.unbox(key: "intArray")
            }
        }
        
        do {
            let modelA: ModelA = try unbox(dictionary: dictionary)
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
            init(unboxer: Unboxer) throws {
                self.intArray = try unboxer.unbox(key: "intArray")
            }
        }
        
        do {
            _ = try unbox(dictionary: dictionary) as ModelA
            XCTFail()
        } catch {
            // Test Passed
        }
    }
    
    func testThrowingForArrayWithInvalidElementType() {
        struct Model: Unboxable {
            let array: [ObjectIdentifier]
            
            init(unboxer: Unboxer) throws {
                self.array = try unboxer.unbox(key: "array")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "array" : ["value"]
        ]
        
        do {
            _ = try unbox(dictionary: dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"array\": Invalid collection element type: ObjectIdentifier. Must be UnboxCompatible or Unboxable.")
        }
    }
    
    func testThrowingForArrayWithInvalidElement() {
        struct Model: Unboxable {
            let array: [String]
            
            init(unboxer: Unboxer) throws {
                self.array = try unboxer.unbox(key: "array")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "array" : [[:]]
        ]
        
        do {
            _ = try unbox(dictionary: dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"array\": Invalid array element ([:]) at index 0.")
        }
    }
    
    func testThrowingForDictionaryWithInvalidKeyType() {
        struct Model: Unboxable {
            let dictionary: [ObjectIdentifier : String]
            
            init(unboxer: Unboxer) throws {
                self.dictionary = try unboxer.unbox(key: "dictionary")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "dictionary" : ["key" : "value"]
        ]
        
        do {
            _ = try unbox(dictionary: dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"dictionary\": Invalid dictionary key type: ObjectIdentifier. Must be either String or UnboxableKey.")
        }
    }
    
    func testThrowingForDictionaryWithInvalidValueType() {
        struct Model: Unboxable {
            let dictionary: [String : ObjectIdentifier]
            
            init(unboxer: Unboxer) throws {
                self.dictionary = try unboxer.unbox(key: "dictionary")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "dictionary" : ["key" : "value"]
        ]
        
        do {
            _ = try unbox(dictionary: dictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual("\(error)", "[UnboxError] An error occured while unboxing path \"dictionary\": Invalid collection element type: ObjectIdentifier. Must be UnboxCompatible or Unboxable.")
        }
    }
    
    func testComplexCollection() {
        struct NestedModel: Unboxable {
            let title: String
            
            init(unboxer: Unboxer) throws {
                self.title = try unboxer.unbox(key: "title")
            }
        }
        
        struct Model: Unboxable {
            let dictionary: [String : [String : [NestedModel]]]
            
            init(unboxer: Unboxer) throws {
                self.dictionary = try unboxer.unbox(key: "complex")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "complex" : [
                "nested" : [
                    "again": [
                        [
                            "title" : "Hello"
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            let model: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(model.dictionary["nested"]?["again"]?.first?.title, "Hello")
        } catch {
            XCTFail("\(error)")
        }
    }
  
    func testSets() {
        struct Model: Unboxable {
            let optional: Set<String>?
            let required: Set<String>
            
            init(unboxer: Unboxer) throws {
                self.optional = unboxer.unbox(key: "optional")
                self.required = try unboxer.unbox(key: "required")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "optional" : ["A", "A", "B"],
            "required" : ["A"]
        ]
        
        do {
            let unboxed: Model = try unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.optional?.count, 2)
            XCTAssertTrue(unboxed.optional?.contains("A") ?? false)
            XCTAssertTrue(unboxed.optional?.contains("B") ?? false)
            XCTAssertEqual(unboxed.required, ["A"])
        } catch {
            XCTFail("\(error)")
        }
    }
}

private func UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: Bool) -> UnboxableDictionary {
    var dictionary: UnboxableDictionary = [
        UnboxTestMock.requiredBoolKey : true,
        UnboxTestMock.requiredIntKey : 15,
        UnboxTestMock.requiredDoubleKey : Double(1.5) as AnyObject,
        UnboxTestMock.requiredFloatKey : Float(3.14) as AnyObject,
        UnboxTestMock.requiredCGFloatKey : 0.72,
        UnboxTestMock.requiredEnumKey : 1,
        UnboxTestMock.requiredStringKey :  "hello",
        UnboxTestMock.requiredURLKey : "http://www.google.com",
        UnboxTestMock.requiredDecimalKey: Decimal(13.95) as AnyObject,
        UnboxTestMock.requiredArrayKey : ["unbox", "is", "pretty", "cool", "right?"],
        UnboxTestMock.requiredEnumArrayKey : [0, 1],
    ]
    
    if !nested {
        dictionary[UnboxTestMock.requiredUnboxableKey] = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: true) as AnyObject
        dictionary[UnboxTestMock.requiredUnboxableArrayKey] = [UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: true)]  as AnyObject
        dictionary[UnboxTestMock.requiredUnboxableDictionaryKey] = ["test" : UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: true)]  as AnyObject
    }
    
    return dictionary
}

// MARK: - Mocks

private enum UnboxTestEnum: Int, UnboxableEnum {
    case First
    case Second
}

private struct UnboxTestDictionaryKey: UnboxableKey, Hashable {
    var hashValue: Int { return self.key.hashValue }
    
    let key: String
    
    static func transform(unboxedKey: String) -> UnboxTestDictionaryKey? {
        if unboxedKey == "FAIL" {
            return nil
        }
        
        return UnboxTestDictionaryKey(key: unboxedKey)
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
    static let requiredDecimalKey = "requiredDecimal"
    static let optionalDecimalKey = "optionalDecimal"
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
    let requiredURL: URL
    let optionalURL: URL?
    let requiredDecimal: Decimal
    let optionalDecimal: Decimal?
    let requiredArray: [String]
    let optionalArray: [String]?
    let requiredEnumArray: [UnboxTestEnum]
    let optionalEnumArray: [UnboxTestEnum]?
    
    required init(unboxer: Unboxer) throws {
        self.requiredBool = try unboxer.unbox(key: UnboxTestBaseMock.requiredBoolKey)
        self.optionalBool = unboxer.unbox(key: UnboxTestBaseMock.optionalBoolKey)
        self.requiredInt = try unboxer.unbox(key: UnboxTestBaseMock.requiredIntKey)
        self.optionalInt = unboxer.unbox(key: UnboxTestBaseMock.optionalIntKey)
        self.requiredDouble = try unboxer.unbox(key: UnboxTestBaseMock.requiredDoubleKey)
        self.optionalDouble = unboxer.unbox(key: UnboxTestBaseMock.optionalDoubleKey)
        self.requiredFloat = try unboxer.unbox(key: UnboxTestBaseMock.requiredFloatKey)
        self.optionalFloat = unboxer.unbox(key: UnboxTestBaseMock.optionalFloatKey)
        self.requiredCGFloat = try unboxer.unbox(key: UnboxTestBaseMock.requiredCGFloatKey)
        self.optionalCGFloat = unboxer.unbox(key: UnboxTestBaseMock.optionalCGFloatKey)
        self.requiredEnum = try unboxer.unbox(key: UnboxTestBaseMock.requiredEnumKey)
        self.optionalEnum = unboxer.unbox(key: UnboxTestBaseMock.optionalEnumKey)
        self.requiredString = try unboxer.unbox(key: UnboxTestBaseMock.requiredStringKey)
        self.optionalString = unboxer.unbox(key: UnboxTestBaseMock.optionalStringKey)
        self.requiredURL = try unboxer.unbox(key: UnboxTestBaseMock.requiredURLKey)
        self.optionalURL = unboxer.unbox(key: UnboxTestBaseMock.optionalURLKey)
        self.requiredDecimal = try unboxer.unbox(key: UnboxTestBaseMock.requiredDecimalKey)
        self.optionalDecimal = unboxer.unbox(key: UnboxTestBaseMock.optionalDecimalKey)
        self.requiredArray = try unboxer.unbox(key: UnboxTestBaseMock.requiredArrayKey)
        self.optionalArray = unboxer.unbox(key: UnboxTestBaseMock.optionalArrayKey)
        self.requiredEnumArray = try unboxer.unbox(key: UnboxTestBaseMock.requiredEnumArrayKey)
        self.optionalEnumArray = unboxer.unbox(key: UnboxTestBaseMock.optionalEnumArrayKey)
    }
    
    func verifyAgainstDictionary(dictionary: UnboxableDictionary) {
        for (key, value) in dictionary {
            let verificationOutcome: Bool
            
            switch key {
            case UnboxTestBaseMock.requiredBoolKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredBool, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalBoolKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalBool, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredIntKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredInt, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalIntKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalInt, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredDoubleKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredDouble, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalDoubleKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalDouble, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredFloatKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalFloatKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredDecimalKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredDecimal, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalDecimalKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalDecimal, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredCGFloatKey:
                verificationOutcome = self.verifyTransformableValue(value: self.requiredCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalCGFloatKey:
                verificationOutcome = self.verifyTransformableValue(value: self.optionalCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(value: self.requiredEnum, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(value: self.optionalEnum, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredStringKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredString, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalStringKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalString, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredURLKey:
                verificationOutcome = self.verifyTransformableValue(value: self.requiredURL, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalURLKey:
                verificationOutcome = self.verifyTransformableValue(value: self.optionalURL, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredArrayKey:
                verificationOutcome = self.verifyArrayPropertyValue(value: self.requiredArray, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalArrayKey:
                verificationOutcome = self.verifyArrayPropertyValue(value: self.optionalArray, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredEnumArrayKey:
                verificationOutcome = self.verifyEnumArrayPropertyValue(value: self.requiredEnumArray, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalEnumArrayKey:
                verificationOutcome = self.verifyEnumArrayPropertyValue(value: self.optionalEnumArray, againstDictionaryValue: value)
            default:
                verificationOutcome = true
            }
            
            XCTAssertTrue(verificationOutcome, "Verification failed for key: " + key)
        }
    }
    
    func verifyPropertyValue<T: Equatable>(value: T?, againstDictionaryValue dictionaryValue: Any?) -> Bool {
        if let propertyValue = value {
            if let typedDictionaryValue = dictionaryValue as? T {
                return propertyValue == typedDictionaryValue
            }
        }
        
        return false
    }
    
    func verifyEnumPropertyValue<T: UnboxableEnum>(value: T?, againstDictionaryValue dictionaryValue: Any?) -> Bool where T: Equatable {
        if let rawValue = dictionaryValue as? T.RawValue {
            if let enumValue = T(rawValue: rawValue) {
                return value == enumValue
            }
        }
        
        return false
    }
    
    func verifyTransformableValue<T: UnboxableByTransform>(value: T?, againstDictionaryValue dictionaryValue: Any?) -> Bool where T: Equatable {
        if let rawValue = dictionaryValue as? T.UnboxRawValue {
            return self.verifyPropertyValue(value: value, againstDictionaryValue: T.transform(unboxedValue: rawValue))
        }
        
        return false
    }
    
    func verifyArrayPropertyValue<T: Equatable>(value: [T]?, againstDictionaryValue dictionaryValue: Any?) -> Bool {
        if let propertyValue = value {
            if let dictionaryArrayValue = dictionaryValue as? [T] {
                return dictionaryArrayValue == propertyValue
            }
        }
        
        return false
    }
    
    func verifyEnumArrayPropertyValue<T: UnboxableEnum>(value: [T]?, againstDictionaryValue dictionaryValue: Any?) -> Bool where T: Equatable {
        if let propertyValue = value {
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
    
    required init(unboxer: Unboxer) throws {
        self.requiredUnboxable = try unboxer.unbox(key: UnboxTestMock.requiredUnboxableKey)
        self.optionalUnboxable = unboxer.unbox(key: UnboxTestMock.optionalUnboxableKey)
        self.requiredUnboxableArray = try unboxer.unbox(key: UnboxTestMock.requiredUnboxableArrayKey)
        self.optionalUnboxableArray = unboxer.unbox(key: UnboxTestMock.optionalUnboxableArrayKey)
        self.requiredUnboxableDictionary = try unboxer.unbox(key: UnboxTestMock.requiredUnboxableDictionaryKey)
        self.optionalUnboxableDictionary = unboxer.unbox(key: UnboxTestMock.optionalUnboxableDictionaryKey)
        
        try super.init(unboxer: unboxer)
    }
}

private final class UnboxTestContextMock: UnboxableWithContext {
    let context: String
    let nested: UnboxTestContextMock?
    let nestedArray: [UnboxTestContextMock]?
    let nestedDictionary: [String : UnboxTestContextMock]?
    
    init(unboxer: Unboxer, context: String) {
        self.context = context
        self.nested = unboxer.unbox(key: "nested", context: "nestedContext")
        self.nestedArray = unboxer.unbox(key: "nestedArray", context: "nestedArrayContext")
        self.nestedDictionary = unboxer.unbox(key: "nestedDictionary", context: "nestedDictionaryContext")
    }
}

private struct UnboxTestSimpleMock: Unboxable, Equatable {
    let int: Int
    
    init(int: Int) {
        self.int = int
    }
    
    init(unboxer: Unboxer) throws {
        self.int = try unboxer.unbox(key: "int")
    }
}

private func ==(lhs: UnboxTestSimpleMock, rhs: UnboxTestSimpleMock) -> Bool {
    return lhs.int == rhs.int
}
