# Unbox

![Travis](https://img.shields.io/travis/JohnSundell/Unbox/master.svg)
![CocoaPods](https://img.shields.io/cocoapods/v/Unbox.svg)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Unbox is an easy to use Swift JSON decoder. Don't spend hours writing JSON decoding code - just unbox it instead!

Unbox is lightweight, non-magical and doesn't require you to subclass, make your JSON conform to a specific schema or completely change the way you write model code. It can be used on any model with ease.

### Basic example

Say you have your usual-suspect `User` model:

```swift
struct User {
    let name: String
    let age: Int
}
```

That can be initialized with the following JSON:

```json
{
    "name": "John",
    "age": 27
}
```

To decode this JSON into a `User` instance, all you have to do is make `User` conform to `Unboxable` and unbox its properties:

```swift
struct User: Unboxable {
    let name: String
    let age: Int

    init(unboxer: Unboxer) {
        self.name = unboxer.unbox("name")
        self.age = unboxer.unbox("age")
    }
}
```

Unbox automatically (or, actually, Swift does) figures out what types your properties are, and decodes them accordingly. Now, we can decode a `User` like this:

```swift
let user: User? = Unbox(dictionary)
```
or even:
```swift
let user: User? = Unbox(data)
```

or if you prefer Swift 2-style error handling instead of optionals:
```swift
do {
    let user: User = try UnboxOrThrow(dictionary)
} catch {
    // Error handling
}
```

### Advanced example

The first was a pretty simple example, but Unbox can decode even the most complicated JSON structures for you, with both required and optional values, all without any extra code on your part:

```swift
struct SpaceShip: Unboxable {
    let type: SpaceShipType
    let weight: Double
    let engine: Engine
    let passengers: [Astronaut]
    let launchLiveStreamURL: NSURL?
    let lastPilot: Astronaut?
    let lastLaunchDate: NSDate?

    init(unboxer: Unboxer) {
        self.type = unboxer.unbox("type")
        self.weight = unboxer.unbox("weight")
        self.engine = unboxer.unbox("engine")
        self.passengers = unboxer.unbox("passengers")
        self.launchLiveStreamURL = unboxer.unbox("liveStreamURL")
        self.lastPilot = unboxer.unbox("lastPilot")

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.lastLaunchDate = unboxer.unbox("lastLaunchDate", formatter: dateFormatter)
    }
}

enum SpaceShipType: Int, UnboxableEnum {
    case Apollo
    case Sputnik

    static func unboxFallbackValue() -> SpaceShipType {
        return .Apollo
    }
}

struct Engine: Unboxable {
    let manufacturer: String
    let fuelConsumption: Float

    init(unboxer: Unboxer) {
        self.manufacturer = unboxer.unbox("manufacturer")
        self.fuelConsumption = unboxer.unbox("fuelConsumption")
    }
}

struct Astronaut: Unboxable {
    let name: String

    init(unboxer: Unboxer) {
        self.name = unboxer.unbox("name")
    }
}


```

### Error handling

Decoding JSON is inherently a failable operation. The JSON might be in an unexpected format, or a required value might be missing. Thankfully, Unbox provides several ways to trigger and handle errors during the unboxing process.

What all these techniques share is that you never have to manually exit out of an initializer (which in Swift requires you to assign default values to all stored properites, generating a lot of unwanted boilerplate).

Instead, if an error occurs, the currently used `Unboxer` is marked as failed, which in turn will cause `nil` to be returned from the `Unbox()` function call that triggered the unboxing process. Optionally, you can also chose to call `UnboxOrThrow()` when starting the unboxing process to use Swift 2-style error handling in case of an error.

#### Missing or invalid required properties
If a non-optional property couldn’t be unboxed, this will automatically cause the current `Unboxer` to be marked as failed.

#### Manually failing an Unboxer
You can also perform custom validation inside of an initializer, and in case you want to abort the unboxing process, simply call `unboxer.failForKey()` or `unboxer.failForInvalidValue(forKey:)`.

### Supported types

Unbox supports decoding all standard JSON types, like:

- `Bool`
- `Int`, `Double`, `Float`
- `String`
- `Array`
- `Dictionary`

It also supports `Arrays` and `Dictionaries` that contain nested unboxable types, as you can see in the **Advanced example** above (where an array of the unboxable `Astronaut` struct is being unboxed).

Finally, it also supports `NSURL` through the use of a transformer, and `NSDate` by using any `NSDateFormatter`.

### Transformations

Unbox also supports transformations that let you treat any value or object as if it was a raw JSON type.

It ships with a default `String` -> `NSURL` transformation, which lets you unbox any `NSURL` property from a string describing an URL without writing any transformation code.

To enable your own types to be unboxable using a transformation, all you have to do is make your type conform to `UnboxableByTransform` and implement its protocol methods.

Here’s an example that makes a native Swift `UniqueIdentifier` type unboxable using a transformation:

```swift
struct UniqueIdentifier: UnboxableByTransform {
    typealias UnboxRawValueType = String

    let identifierString: String

    init?(identifierString: String) {
        if let UUID = NSUUID(UUIDString: identifierString) {
            self.identifierString = UUID.UUIDString
        } else {
            return nil
        }
    }

    init() {
        self.identifierString = NSUUID().UUIDString
    }

    static func transformUnboxedValue(unboxedValue: String) -> UniqueIdentifier? {
        return UniqueIdentifier(identifierString: unboxedValue)
    }

    static func unboxFallbackValue() -> UniqueIdentifier {
        return UniqueIdentifier()
    }
}
```

### Supports JSON with both Array and Dictionary root objects

No matter if the root object of the JSON that you want to unbox is an `Array` or `Dictionary` - you can use the same `Unbox()` or `UnboxOrThrow()` functions and Unbox will return either a single model or an array of models (based on type inference).

### Built-in enum support

You can also unbox `enums` directly, without having to handle the case if they failed to initialize. All you have to do is make any `enum` type you wish to unbox conform to `UnboxableEnum`, like this:

```swift
enum Profession: Int, UnboxableEnum {
    case Developer
    case Astronaut

    static func unboxFallbackValue() {
        return .Developer
    }
}
```

Now `Profession` can be unboxed directly in any model

```swift
struct Passenger: Unboxable {
    let profession: Profession

    init(unboxer: Unboxer) {
        self.profession = unboxer.unbox("profession")
    }
}
```

### Contextual objects

Sometimes you need to use data other than what's contained in a dictionary during the decoding process. For this, Unbox has support for contextual objects that can be made available on the `Unboxer` that is being used.

To pass a contextual object, use the `Unbox(dictionary:context:)` overload when you start the unboxing process.

The `Unboxer` passed to your `Unboxable`'s init method will then make your contextual object available through its `context` property.

You can also **require** that a contextual object is present during the unboxing process by using the `UnboxableWithContext` protocol. Types that conform to this protocol can then be unboxed using `Unbox(dictionary:context:)`, where `context` must be of the type’s defined `ContextType`.

### Key path support

You can also use key paths to unbox values from nested JSON structures. Let's expand our User model:

```json
{
    "name": "John",
    "age": 27,
    "activities": {
        "running": {
            "distance": 300
        }
    }
}
```

```swift
struct User: Unboxable {
    let name: String
    let age: Int
    let runningDistance: Int

    init(unboxer: Unboxer) {
        self.name = unboxer.unbox("name")
        self.age = unboxer.unbox("age")
        self.runningDistance = unboxer.unbox("activities.running.distance")
    }
}
```

### Custom unboxing

Sometimes you need more fine grained control over the decoding process, and even though Unbox was designed for simplicity, it also features a powerful custom unboxing API that enables you to take control of how an object gets unboxed. This comes very much in handy when using Unbox together with Core Data, when using dependency injection, or when aggregating data from multiple sources. Here's an example:

```swift
let dependency = DependencyManager.loadDependency()

let model: Model = try Unboxer.performCustomUnboxingWithDictionary(dictionary, closure: {
    let unboxer = $0

    var model = Model(dependency: dependency)
    model.name = unboxer.unbox("name")
    model.count = unboxer.unbox("count")

    return model
})
```

### Installation

**CocoaPods:**

Add the line `pod "Unbox"` to your `Podfile`

**Carthage:**

Add the line `github "johnsundell/unbox"` to your `Cartfile`

**Manual:**

Clone the repo and drag the file `Unbox.swift` into your Xcode project.

### Debugging tips

In case your unboxing code isn’t working like you expect it to, here are some tips on how to debug it:

**Compile time error: `Ambiguous reference to member 'unbox'`**

Swift cannot find the appropriate overload of the `unbox` method to call. Make sure you have conformed to any required protocol (such as `Unboxable`, `UnboxableEnum`, etc). Note that you can only conform to one Unbox protocol for each type (that is, a type cannot be both an `UnboxableEnum` and `UnboxableByTransform`). Also remember that you can only reference concrete types (not `Protocol` types) in order for Swift to be able to select what overload to use.

**`Unbox()` returns nil**

Either set a breakpoint in `Unboxer.failForInvalidValue(forKey:)` to see what key/value combination that caused the unboxing process to fail, or use the `do, try, catch` pattern and `UnboxOrThrow` function, which will enable you to access any `UnboxError` thrown in the `catch` block.

If you need any help in resolving any problems that you might encounter while using Unbox, feel free to open an Issue.

### Hope you enjoy unboxing your JSON!

For more updates on Unbox, and my other open source projects, follow me on Twitter: [@johnsundell](http://www.twitter.com/johnsundell)
