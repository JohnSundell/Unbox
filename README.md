# Unbox

Unbox is an easy to use Swift JSON decoder. Don't spend hours writing JSON decoding code - just unbox it instead!

Unbox is lightweight, non-magical and doesn't require you to subclass, make your JSON conform to a specific schema or completely change the way you write model code. It can be used on any model with ease.

Say you have your usual-suspect `User` model:

```
struct User {
    let name: String
    let age: Int
}
```

That can be initialized with the following JSON:

```
{
    "name": "John",
    "age": 27
}
```

To decode this JSON into a `User` instance, all you have to do is make `User` conform to `Unboxable` and unbox its properties:

```
struct User: Unboxable {
    let name: String
    let age: Int
    
    init(unboxer: Unboxer) {
        self.name = unboxer.unbox("name")
        self.age = unboxer.unbox("age")
    }
}
```

Unboxed automatically (or, actually Swift does this) figures out what types your properties are, and decodes them accordingly. Now, we can decode a `User` like this:

```
let user: User? = Unbox(dictionary)
```
or even:
```
let user: User? = Unbox(data)
```

#### Pretty nice and easy, right?

Now - that was a pretty simple example, but Unbox can decode even the most complicated JSON structures for you, with both required and optional values, all without any extra code on your part:

```
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

#### Hope you enjoy unboxing your JSON!

For more updates on Unbox, and my other open source projects, follow me on Twitter: [@johnsundell](http://www.twitter.com/johnsundell)