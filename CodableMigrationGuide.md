# Unbox → Codable migration guide

After four years of active development and maintenance, Unbox is now deprecated, and all current users are highly encouraged to migrate to Swift’s built-in `Codable` API as soon as possible.

This document aims to make that migration easier, using [the Codextended project](https://github.com/JohnSundell/Codextended) — which is the “spiritual successor” to both Unbox and [Wrap](https://github.com/JohnSundell/Wrap).

## Basic decoding

If the property names of a type matches the keys within the JSON that it’ll be decoded from, then most often no custom code is required when using Codable:

```swift
struct User {
    var name: String
    var age: Int
}

// Unbox

extension User: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.age = try unboxer.unbox(key: "age")
    }
}

// Codable

extension User: Codable {}
```

## Providing default values

When a default value should be used for a given property, and we don’t want to make that property an optional, both Unbox and Codable require us to write custom code. Per default, that custom code would be quite verbose using Codable, so here we use [Codextended](https://github.com/JohnSundell/Codextended) to give us a very *“Unbox-like”* API even when using Codable:

```swift
struct Article {
    var title: String
    var body: String
    var tags: [String]
}

// Unbox

extension Article: Unboxable {
    init(unboxer: Unboxer) throws {
        title = try unboxer.unbox("title")
        body = try unboxer.unbox("body")
        tags = (try? unboxer.unbox("tags")) ?? []
    }
}

// Codable + Codextended

extension Article: Codable {
    init(from decoder: Decoder) throws {
        title = try decoder.decode("title")
        body = try decoder.decode("body")
        tags = (try? decoder.decode("tags")) ?? []
    }
}
```

## Custom decoding

For more custom use cases, a bit more manual code might be required when using Codable, even with the Codextended extensions added.

For example, here we need to decode an `Array<String>` into an `Array<Int>`, and we want to skip all invalid elements. This is something that Unbox has a convenience API for, while Codable requires custom logic:

```swift
struct NumberContainer {
    var values: [Int]
}

// Unbox

extension NumberContainer: Unboxable {
    init(unboxer: Unboxer) throws {
        values = try unboxer.unbox(
            key: "values",
            allowInvalidElements: true
        )
    }
}

// Codable + Codextended

extension NumberContainer: Decodable {
    init(from decoder: Decoder) throws {
        let strings = try decoder.decode("values") as [String]
        values = strings.compactMap(Int.init)
    }
}
```

## Nested data

Another task that Codable requires a bit more code to accomplish is when we want to read data located further into a JSON structure. For example, here we’re decoding a `Book` and want to read the author’s name, which is wrapped inside of a nested `author` dictionary:

```swift
struct Book {
    let title: String
    let authorName: String
}

// Unbox

extension Book: Unboxable {
    init(unboxer: Unboxer) throws {
        title = try unboxer.unbox(key: "title")
        authorName = try unboxer.unbox(keyPath: "author.name")
    }
}

// Codable + Codextended

extension Book: Decodable {
    // While Codable also supports nested containers, an easy
    // way to read nested data is to simply declare private
    // Swift types that match the containers we wish to
    // decode. That way the compiler will synthesize the code
    // needed to decode those containers for us.
    private struct Author: Decodable {
        let name: String
    }

    init(from decoder: Decoder) throws {
        title = try decoder.decode("title")

        let author = try decoder.decode("author") as Author
        authorName = author.name
    }
}
```

## Conclusion

While there’s a lot of other use cases that this guide didn’t explicitly cover, I hope that it will be able to act as a solid starting point when migrating from Unbox to Codable.

Unbox will of course remain online for as long as possible, and since it’s licensed under the very liberal [MIT license](https://github.com/JohnSundell/Unbox/blob/master/LICENSE), you can also choose to fork it and keep using/maintaining it that way — if you’d prefer that over using Codable, or another JSON framework.

Note that as of this point no further changes will be made to Unbox, and it won’t be updated to support any new Swift versions past 5.0.

Finally, I want to thank all of the thousands of developers who have used Unbox throughout the years, and the 35 people who have contributed to it since it first was open sourced. Originally written in Swift 1, it has been quite a journey to maintain it over these past four years, and I sincerely thank all of you for your support.