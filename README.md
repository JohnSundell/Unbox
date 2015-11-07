# Unbox

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

### Advanced example

The first was a pretty simple example, but Unbox can decode even the most complicated JSON structures for you, with both required and optional values, all without any extra code on your part:

```swift
struct SpaceShip: Unboxable {
    let weight: Double
    let engine: Engine
    let passengers: [Astronaut]
    let launchLiveStreamURL: NSURL?
    let lastPilot: Astronaut?
    
    init(unboxer: Unboxer) {
        self.weight = unboxer.unbox("weight")
        self.engine = unboxer.unbox("engine")
        self.passengers = unboxer.unbox("passengers")
        self.launchLiveStreamURL = unboxer.unbox("liveStreamURL")
        self.lastPilot = unboxer.unbox("lastPilot")
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

### Transformers

Unbox also supports transformers that let you treat any value or object as if it was a raw JSON type.

It ships with a default `String` -> `NSURL` transformer, which lets you unbox any `NSURL` property from a string describing an URL without writing any transformation code.

To enable your own types to be unboxable using a transformer, all you have to do is make your type conform to `UnboxableByTransform` and implement an `UnboxTransformer` for it, like this:

```swift
enum Profession {
    case Developer
    case Astronaut
}

extension Profession: UnboxableByTransform {
    typealias UnboxTransformerType = ProfessionUnboxTransformer
}

class ProfessionUnboxTransformer: UnboxTransformer {
   static func transformUnboxedValue(unboxedValue: String) -> Profession? {
        switch unboxedValue {
            case "DEVELOPER":
                return .Developer
            case "ASTRONAUT":
                return .Astronaut
            default:
                return nil
        }
    }
    
   static func fallbackValue() -> Profession {
        return .Developer
    }
}
```

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

### Installation

**CocoaPods:**
Add the line `pod "Unbox"` to your `Podfile`

**Manual:**
Clone the repo and drag the file `Unbox.swift` into your Xcode project.

### Hope you enjoy unboxing your JSON!

For more updates on Unbox, and my other open source projects, follow me on Twitter: [@johnsundell](http://www.twitter.com/johnsundell)