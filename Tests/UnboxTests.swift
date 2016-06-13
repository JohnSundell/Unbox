import Foundation
import XCTest
import Unbox

// MARK: - Tests

class UnboxTests: XCTestCase {
    func testWithOnlyValidRequiredValues() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        let unboxed: UnboxTestMock? = try? Unbox(dictionary: dictionary)
        XCTAssertNotNil(unboxed, "Failed to unbox valid dictionary")
        unboxed?.verifyAgainstDictionary(dictionary: dictionary)
    }
    
    func testWithMissingRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary.removeValue(forKey: key)
            
            let unboxed: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredValues() {
        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        for key in validDictionary.keys {
            var invalidDictionary = validDictionary
            invalidDictionary[key] = NSObject()
            
            let unboxed: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testWithInvalidRequiredURL() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        invalidDictionary[UnboxTestMock.requiredURLKey] = "Clearly not a URL!"
        
        let unboxed: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxed, "Unbox did not return nil for a dictionary with an invalid required URL value")
    }
    
    func testAutomaticTransformationOfStringsToRawTypes() {
        struct Model: Unboxable {
            let requiredInt: Int
            let optionalInt: Int?
            let requiredDouble: Double
            let optionalDouble: Double?
            
            init(unboxer: Unboxer) {
                self.requiredInt = unboxer.unbox(key: "requiredInt")
                self.optionalInt = unboxer.unbox(key: "optionalInt")
                self.requiredDouble = unboxer.unbox(key: "requiredDouble")
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
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.required = unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.required = unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.required = unboxer.unbox(key: "required")
                self.optional1 = unboxer.unbox(key: "optional1")
                self.optional2 = unboxer.unbox(key: "optional2")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required": 27,
            "optional1": 10
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.bool1 = unboxer.unbox(key: "bool1")
                self.bool2 = unboxer.unbox(key: "bool2")
                self.bool3 = unboxer.unbox(key: "bool3")
                self.double = unboxer.unbox(key: "double")
                self.float = unboxer.unbox(key: "float")
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
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
            let date: Date
            
            init(unboxer: Unboxer) {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox(key: "date", formatter: formatter)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "date" : "2015-12-15"
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
            
            let calendar = Calendar.current()
            XCTAssertEqual(calendar.component(.year, from: unboxed.date), 2015)
            XCTAssertEqual(calendar.component(.month, from: unboxed.date), 12)
            XCTAssertEqual(calendar.component(.day, from: unboxed.date), 15)
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            let invalidDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday"
            ]
            
            _ = try Unbox(dictionary: invalidDictionary) as Model
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testOptionalDateFormattingFailureNotThrowing() {
        struct Model: Unboxable {
            let date: NSDate?
            
            init(unboxer: Unboxer) {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                self.date = unboxer.unbox(key: "date", formatter: formatter)
            }
        }
        
        do {
            let invalidDictionary: UnboxableDictionary = [
                "date" : "2015-12-tuesday"
            ]
            
            let unboxed: Model = try Unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed.date)
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
                self.requiredIntDictionary = unboxer.unbox(key: "requiredIntDictionary")
                self.optionalIntDictionary = unboxer.unbox(key: "optionalIntDictionary")
                self.requiredModelDictionary = unboxer.unbox(key: "requiredModelDictionary")
                self.optionalModelDictionary = unboxer.unbox(key: "optionalModelDictionary")
            }
        }
        
        do {
            let unboxed: Model = try Unbox(dictionary: [
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
            
            let unboxedWithoutOptionals: Model = try Unbox(dictionary: [
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
            let unboxed: Model = try Unbox(dictionary: [
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
                self.dictionary = unboxer.unbox(key: "dictionary")
            }
        }
        
        do {
            _ = try Unbox(dictionary: [
                "dictionary" : [
                    "FAIL" : 59
                ]
            ]) as Model
            
            XCTFail("Should have thrown")
        } catch {
            // Test passed
        }
    }
    
    func testWithInvalidRequiredUnboxable() {
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = "Totally not unboxable"
        
        let unboxedFromString: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxedFromString, "Unbox did not return nil for a string")
        
        invalidDictionary[UnboxTestMock.requiredUnboxableKey] = ["cannotBe" : "unboxed"]
        
        let unboxedFromInvalidDictionary: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
        XCTAssertNil(unboxedFromInvalidDictionary, "Unbox did not return nil for an invalid dictionary")
    }
    
    func testWithInvalidOptionalValue() {
        var validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        validDictionary[UnboxTestMock.optionalBoolKey] = "Not a Bool"
        
        let unboxed: UnboxTestMock? = try? Unbox(dictionary: validDictionary)
        XCTAssertNotNil(unboxed, "Invalid optional values should be ignored")
    }
    
    func testUnboxingFromValidData() {
        let dictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary as AnyObject, options: [])
            let unboxed: UnboxTestMock? = try? Unbox(data: data)
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
                self.required = unboxer.unbox(key: "required", index: 0)
                self.optional = unboxer.unbox(key: "optional", index: 1)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "required" : ["Hello", "This"],
            "optional" : ["Is", "Unbox"]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.int = unboxer.unbox(key: "values", index: 3)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "values" : [7, 9, 22]
        ]
        
        do {
            _ = try Unbox(dictionary: dictionary) as Model
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
        
        guard let unboxedArray: [UnboxTestMock] = try? Unbox(dictionaries: dictionaries) else {
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
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox(key: "string")
            }
        }
        
        let dictionaries: [UnboxableDictionary] = [
            ["string" : "one"],
            ["invalid" : "element"],
            ["string" : "two"]
        ]
        
        do {
            let unboxed: [Model] = try Unbox(dictionaries: dictionaries, allowInvalidElements: true)
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
                self.nestedModels = unboxer.unbox(key: "nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox(key: "string")
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
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.nestedModels = unboxer.unbox(key: "nested", allowInvalidElements: true)
            }
        }
        
        struct NestedModel: Unboxable {
            let string: String
            
            init(unboxer: Unboxer) {
                self.string = unboxer.unbox(key: "string")
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
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.arrays = unboxer.unbox(key: "arrays")
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "arrays": [
                [1, 2],
                [3, 4]
            ]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.dictionaries = unboxer.unbox(key: "dictionaries")
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
            let unboxed: Model = try Unbox(dictionary: dictionary)
            XCTAssertEqual(unboxed.dictionaries.count, 2)
            XCTAssertEqual(unboxed.dictionaries["one"]!, ["a" : 1, "b" : 2])
            XCTAssertEqual(unboxed.dictionaries["two"]!, ["c" : 3, "d" : 4])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testThrowingForMissingRequiredValues() {
        let invalidDictionary: UnboxableDictionary = [:]
        
        do {
            _ = try Unbox(dictionary: invalidDictionary) as UnboxTestMock
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
        var invalidDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        
        for key in invalidDictionary.keys {
            let invalidValue = NSObject()
            invalidDictionary[key] = invalidValue
            break
        }
        
        do {
            _ = try Unbox(dictionary: invalidDictionary) as UnboxTestMock
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
            let unboxed: UnboxTestMock? = try? Unbox(dictionary: invalidDictionary)
            XCTAssertNil(unboxed, "Unbox did not return nil for an invalid dictionary")
        }
    }
    
    func testThrowingForInvalidData() {
        if let data = "Not a dictionary".data(using: String.Encoding.utf8) {
            do {
                _ = try Unbox(data: data) as UnboxTestMock
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
        
        guard let data = try? JSONSerialization.data(withJSONObject: notDictionaryArray as AnyObject, options: []) else {
            return XCTFail()
        }
        
        do {
            _ = try Unbox(data: data) as UnboxTestMock
            XCTFail()
        } catch UnboxError.InvalidData {
            // Test passed
        } catch {
            XCTFail("Unbox did not return the correct error type")
        }
    }
    
    func testThrowingForSingleInvalidDictionaryInArray() {
        let dictionaries = [
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false),
            ["invalid" : "dictionary"],
            UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        ]
        
        do {
            _ = try Unbox(dictionaries: dictionaries) as [UnboxTestMock]
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
                
                self.nestedUnboxable = unboxer.unbox(key: "nested")
            }
        }
        
        let dictionary: UnboxableDictionary = ["nested" : UnboxableDictionary() as AnyObject]
        let unboxed: Model? = try? Unbox(dictionary: dictionary, context: "context")
        
        XCTAssertFalse(unboxed == nil, "Could not unbox with a context")
    }
    
    func testRequiredContext() {
        let dictionary = [
            "nested" : [:],
            "nestedArray": [[:]]
        ]
        
        if let model: UnboxTestContextMock = try? Unbox(dictionary: dictionary, context: "context") {
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

    func testAccessingNestedDictionaryWithKeyPath() {
        struct KeyPathModel: Unboxable {
            let intValue: Int
            let dictionary: UnboxableDictionary

            init(unboxer: Unboxer) {
                let intKeyPathComponents = [UnboxTestMock.requiredUnboxableDictionaryKey, "test", UnboxTestMock.requiredIntKey]
                let keyPath = intKeyPathComponents.joined(separator: ".")
                self.intValue = unboxer.unbox(key: keyPath, isKeyPath: true)

                let dictionaryKeyPath = [UnboxTestMock.requiredUnboxableDictionaryKey, "test"].joined(separator: ".")
                self.dictionary = unboxer.unbox(key: dictionaryKeyPath, isKeyPath: true)
            }
        }


        let validDictionary = UnboxTestDictionaryWithAllRequiredKeysWithValidValues(nested: false)
        let model: KeyPathModel? = try? Unbox(dictionary: validDictionary)
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
                self.firstName = unboxer.unbox(key: "names.0")
                self.lastName = unboxer.unbox(key: "names.1", isKeyPath: true)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "names": ["John", "Appleseed"]
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
                self.int = unboxer.unbox(key: "int.value", isKeyPath: false)
                self.string = unboxer.unbox(key: "string.value", isKeyPath: false)
            }
        }
        
        let dictionary: UnboxableDictionary = [
            "int.value" : 15,
            "string.value" : "hello"
        ]
        
        do {
            let unboxed: Model = try Unbox(dictionary: dictionary)
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
            let context = "Context"
            
            let unboxingClosure: (Unboxer) -> Model? = {
                XCTAssertEqual($0.context as? String, context)
                return Model(int: $0.unbox(key: "int"), double: 3.14, string: $0.unbox(key: "string"))
            }
            
            let unboxedFromDictionary: Model = try Unboxer.performCustomUnboxing(dictionary: dictionary, context: context, closure: unboxingClosure)
            XCTAssertEqual(unboxedFromDictionary.int, 5)
            XCTAssertEqual(unboxedFromDictionary.double, 3.14)
            XCTAssertEqual(unboxedFromDictionary.string, "Hello")
            
            let unboxedFromData: Model = try Unboxer.performCustomUnboxing(data: data, context: context, closure: unboxingClosure)
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
            let unboxed: [Any] = try Unboxer.performCustomUnboxing(array: array, closure: {
                let unboxer = $0
                let type = unboxer.unbox(key: "type") as String
                
                switch type {
                case "A":
                    return ModelA(int: unboxer.unbox(key: "int"))
                case "B":
                    return ModelB(string: unboxer.unbox(key: "string"))
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
    
    private static func unboxFallbackValue() -> UnboxTestEnum {
        return .First
    }
}

private struct UnboxTestDictionaryKey: UnboxableKey {
    var hashValue: Int { return self.key.hashValue }
    
    let key: String
    
    static func transform(unboxedKey: String) -> UnboxTestDictionaryKey? {
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
        self.requiredBool = unboxer.unbox(key: UnboxTestBaseMock.requiredBoolKey)
        self.optionalBool = unboxer.unbox(key: UnboxTestBaseMock.optionalBoolKey)
        self.requiredInt = unboxer.unbox(key: UnboxTestBaseMock.requiredIntKey)
        self.optionalInt = unboxer.unbox(key: UnboxTestBaseMock.optionalIntKey)
        self.requiredDouble = unboxer.unbox(key: UnboxTestBaseMock.requiredDoubleKey)
        self.optionalDouble = unboxer.unbox(key: UnboxTestBaseMock.optionalDoubleKey)
        self.requiredFloat = unboxer.unbox(key: UnboxTestBaseMock.requiredFloatKey)
        self.optionalFloat = unboxer.unbox(key: UnboxTestBaseMock.optionalFloatKey)
        self.requiredCGFloat = unboxer.unbox(key: UnboxTestBaseMock.requiredCGFloatKey)
        self.optionalCGFloat = unboxer.unbox(key: UnboxTestBaseMock.optionalCGFloatKey)
        self.requiredEnum = unboxer.unbox(key: UnboxTestBaseMock.requiredEnumKey)
        self.optionalEnum = unboxer.unbox(key: UnboxTestBaseMock.optionalEnumKey)
        self.requiredString = unboxer.unbox(key: UnboxTestBaseMock.requiredStringKey)
        self.optionalString = unboxer.unbox(key: UnboxTestBaseMock.optionalStringKey)
        self.requiredURL = unboxer.unbox(key: UnboxTestBaseMock.requiredURLKey)
        self.optionalURL = unboxer.unbox(key: UnboxTestBaseMock.optionalURLKey)
        self.requiredArray = unboxer.unbox(key: UnboxTestBaseMock.requiredArrayKey)
        self.optionalArray = unboxer.unbox(key: UnboxTestBaseMock.optionalArrayKey)
        self.requiredEnumArray = unboxer.unbox(key: UnboxTestBaseMock.requiredEnumArrayKey)
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
            case UnboxTestBaseMock.requiredCGFloatKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalCGFloatKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalCGFloat, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(value: self.requiredEnum, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalEnumKey:
                verificationOutcome = self.verifyEnumPropertyValue(value: self.optionalEnum, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredStringKey:
                verificationOutcome = self.verifyPropertyValue(value: self.requiredString, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalStringKey:
                verificationOutcome = self.verifyPropertyValue(value: self.optionalString, againstDictionaryValue: value)
            case UnboxTestBaseMock.requiredURLKey:
                verificationOutcome = self.verifyURLPropertyValue(value: self.requiredURL, againstDictionaryValue: value)
            case UnboxTestBaseMock.optionalURLKey:
                verificationOutcome = self.verifyURLPropertyValue(value: self.optionalURL, againstDictionaryValue: value)
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
    
    func verifyPropertyValue<T: Equatable>(value: T?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let propertyValue = value {
            if let typedDictionaryValue = dictionaryValue as? T {
                return propertyValue == typedDictionaryValue
            }
        }
        
        return false
    }
    
    func verifyEnumPropertyValue<T: UnboxableEnum where T: Equatable>(value: T?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let rawValue = dictionaryValue as? T.RawValue {
            if let enumValue = T(rawValue: rawValue) {
                return value == enumValue
            }
        }
        
        return false
    }
    
    func verifyURLPropertyValue(value: NSURL?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let string = dictionaryValue as? String {
            return self.verifyPropertyValue(value: self.requiredURL, againstDictionaryValue: NSURL(string: string))
        }
        
        return false
    }
    
    func verifyArrayPropertyValue<T: Equatable>(value: [T]?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
        if let propertyValue = value {
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
    
    func verifyEnumArrayPropertyValue<T: UnboxableEnum where T: Equatable>(value: [T]?, againstDictionaryValue dictionaryValue: AnyObject?) -> Bool {
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
    
    required init(unboxer: Unboxer) {
        self.requiredUnboxable = unboxer.unbox(key: UnboxTestMock.requiredUnboxableKey)
        self.optionalUnboxable = unboxer.unbox(key: UnboxTestMock.optionalUnboxableKey)
        self.requiredUnboxableArray = unboxer.unbox(key: UnboxTestMock.requiredUnboxableArrayKey)
        self.optionalUnboxableArray = unboxer.unbox(key: UnboxTestMock.optionalUnboxableArrayKey)
        self.requiredUnboxableDictionary = unboxer.unbox(key: UnboxTestMock.requiredUnboxableDictionaryKey)
        self.optionalUnboxableDictionary = unboxer.unbox(key: UnboxTestMock.optionalUnboxableDictionaryKey)
        
        super.init(unboxer: unboxer)
    }
}

private final class UnboxTestContextMock: UnboxableWithContext {
    let context: String
    let nested: UnboxTestContextMock?
    let nestedArray: [UnboxTestContextMock]?
    
    init(unboxer: Unboxer, context: String) {
        self.context = context
        self.nested = unboxer.unbox(key: "nested", context: "nestedContext")
        self.nestedArray = unboxer.unbox(key: "nestedArray", context: "nestedArrayContext")
    }
}

private struct UnboxTestSimpleMock: Unboxable, Equatable {
    let int: Int
    
    init(int: Int) {
        self.int = int
    }
    
    init(unboxer: Unboxer) {
        self.int = unboxer.unbox(key: "int")
    }
}

private func ==(lhs: UnboxTestSimpleMock, rhs: UnboxTestSimpleMock) -> Bool {
    return lhs.int == rhs.int
}
