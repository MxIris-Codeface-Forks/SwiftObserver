![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)

# SwiftObserver

![badge-swift-versions] ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight package for reactive Swift. Its design goals make it easy to learn and a joy to use:

1. [**Meaningful Code**](https://github.com/codeface-io/SwiftObserver/blob/master/Documentation/philosophy.md#meaningful-code) 💡<br>SwiftObserver promotes meaningful metaphors, names and syntax, producing highly readable code.
2. [**Non-intrusive Design**](https://github.com/codeface-io/SwiftObserver/blob/master/Documentation/philosophy.md#non-intrusive-design) ✊🏻<br>SwiftObserver doesn't limit or modulate your design. It just makes it easy to do the right thing.
3. [**Simplicity**](https://github.com/codeface-io/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility) 🕹<br>SwiftObserver employs few radically simple concepts and applies them consistently without exceptions.
4. [**Flexibility**](https://github.com/codeface-io/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility) 🤸🏻‍♀️<br>SwiftObserver's types are simple but universal and composable, making them applicable in many situations.
5. [**Safety**](https://github.com/codeface-io/SwiftObserver/blob/master/Documentation/philosophy.md#safety) ⛑<br>SwiftObserver eradicates those memory leaks that typically come with observer- and reactive patterns.

SwiftObserver is only 1400 lines of production code, but it's well beyond a 1000 hours of work, re-imagining and reworking it many times, [letting go of fancy features](https://github.com/codeface-io/SwiftObserver/releases), documenting, [unit-testing](https://github.com/codeface-io/SwiftObserver/tree/master/Tests/SwiftObserverTests), and battle-testing it in practice.

## Why the Hell Another Reactive Swift Framework?

[*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing effective architectures: controlling dependency direction, in particular making [specific concerns depend on abstract ones](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks reactive programming down to its essence, which is the [*Observer Pattern*](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver diverges from convention as it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. It's not as fancy as Rx and Combine and not as restrictive as Redux. Instead, it offers a powerful simplicity you might actually **love** to work with.

## Contents

* [Get Involved](#get-involved)
* [Get Started](#get-started)
    * [Install](#install)
    * [Introduction](#introduction)
* [Messengers](#messengers)
    * [Understand Observable Objects](#understand-observables)
* [Variables](#variables)
    * [Observe Variables](#observe-variables)
    * [Enjoy the Property Wrapper](#enjoy-the-property-wrapper)
    * [Encode and Decode Variables](#encode-and-decode-variables)
* [Transforms](#transforms)
    * [Make Transforms Observable](#make-transforms-observable)
    * [Use Prebuilt Transforms](#use-prebuilt-transforms)
    * [Chain Transforms](#chain-transforms)
* [Advanced](#advanced)
    * [Interoperate With Combine](#interoperate-with-combine)
    * [Message Authors](#message-authors)
    * [Cached Messages](#cached-messages)
    * [Weak Observable Objects](#weak-observables)
* [More](#more)

# Get Involved

* Found a **bug**? Create a [github issue](https://github.com/codeface-io/SwiftObserver/issues/new/choose).
* Need a **feature**? Create a [github issue](https://github.com/codeface-io/SwiftObserver/issues/new/choose).
* Want to **improve** stuff? Create a [pull request](https://github.com/codeface-io/SwiftObserver/pulls).
* Need **support** and troubleshooting? Write at <hello@codeface.io>.
* Want to **contact** us? Write at <hello@codeface.io>.

# Get Started

## Install

With the [**Swift Package Manager**](https://github.com/apple/swift-package-manager/tree/master/Documentation#swift-package-manager), you add the SwiftObserver package [via Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) (11+).

Or you manually adjust the [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#create-a-package) file of your project:

~~~swift
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/codeface-io/SwiftObserver.git",
                 .upToNextMajor(from: "6.2.0"))
    ],
    targets: [
        .target(name: "MyAppTarget",
                dependencies: ["SwiftObserver"])
    ]
)
~~~

Then run `$ swift build` or `$ swift run`.

Finally, in your **Swift** files:

```swift
import SwiftObserver
```

## Introduction

No need to learn a bunch of arbitrary metaphors, terms or types.

SwiftObserver is simple: **Objects *observe* other objects**.

Or a tad more technically: ***Observable objects* send *messages* to their *observers***.

That's it. Just readable code:

~~~swift
dog.observe(Sky.shared) { color in
    // marvel at the sky changing its color
}
~~~

### Observers

Any object can be an `Observer` if it has a `Receiver` for receiving messages:

```swift
class Dog: Observer {
    let receiver = Receiver()
}
```

The receiver keeps the observer's observations alive. The observer just holds on to it strongly.

#### Notes on Observers

* For a message receiving closure to be called, the `Observer`/`Receiver` must still be alive. There's no awareness after death in memory.
* An `Observer` can do multiple simultaneous observations of the same `ObservableObject`, for example by calling `observe(...)` multiple times.
* You can check wether an observer is observing an "observable" via `observer.isObserving(observable)`.

### Observable Objects

Any object can be an `ObservableObject` if it has a `Messenger<Message>` for sending messages:

```swift
class Sky: ObservableObject {
    let messenger = Messenger<Color>()  // Message == Color
}
```

#### Notes on Observable Objects

* An `ObservableObject` sends messages via `send(_ message: Message)`. The object's clients, even its observers, are also free to call that function. 
* An `ObservableObject` delivers messages in exactly the order in which `send` is called, which helps when observers, from their message handling closures, somehow trigger further calls of `send`.
* Just starting to observe an `ObservableObject` does **not** trigger it to send a message. This keeps everything simple, predictable and consistent.

#### Ways to Create an Observable Object

1. Create a [`Messenger<Message>`](#messengers). It's a mediator through which other entities communicate.
2. Create an object of a [custom `ObservableObject`](#understand-observables) class that utilizes `Messenger<Message>`.
3. Create a [`Variable<Value>`](#variables) (a.k.a. `Var<Value>`). It holds a value and sends value updates.
5. Create a [*transform*](#make-transforms-observable) object. It wraps and transforms another `ObservableObject`.

### Memory Management

When an `Observer` or `ObservableObject` dies, SwiftObserver cleans up all related observations automatically, making those memory leaks impossible that typically come with observer- and reactive patterns. So there's no specific memory management to worry about – and no "Cancellables", "Tokens", "DisposeBags" or any such weirdness.

However, observing- and observed objects can stop particular- or all their ongoing observations:

```swift
dog.stopObserving(Sky.shared)          // no more messages from the sky
dog.stopObserving()                    // no more messages from anywhere
Sky.shared.stopBeingObserved(by: dog)  // no more messages to dog
Sky.shared.stopBeingObserved()         // no more messages to anywhere
```

### Architecture

Have a look at the internal codebase (compositions and essential dependencies) of the "SwiftObserver" target:

![](Documentation/Architecture/SwiftObserver.png)

Diagrams of all top-level source folders [are over here](Documentation/Architecture/architecture.md). The images were generated with [Codeface](https://codeface.io). 

# Messengers

`Messenger` is the simplest `ObservableObject` and the basis of every other `ObservableObject`. It doesn't send messages by itself, but anyone can send messages through it and use it for any type of message:

```swift
let textMessenger = Messenger<String>()

observer.observe(textMessenger) { textMessage in
    // respond to textMessage
}

textMessenger.send("my message")
```

`Messenger` embodies the common [messenger / notifier pattern](Documentation/specific-patterns.md#the-messenger-pattern) and can be used for that out of the box. 

## Understand Observable Objects

Having a `Messenger` is actually what defines `ObservableObject`:

```swift
public protocol ObservableObject: class {
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
```

`Messenger` is itself an `ObservableObject` because it points to itself as the required `Messenger`:

```swift
extension Messenger: ObservableObject {
    public var messenger: Messenger<Message> { self }
}
```

Every other `ObservableObject` class is either a subclass of `Messenger` or a custom `ObservableObject` class that provides a `Messenger`. Custom observables often employ some `enum` as their message type:

```swift
class Model: SuperModel, ObservableObject {
    func foo() { send(.willUpdate) }
    func bar() { send(.didUpdate) }
    deinit { send(.willDie) }
    let messenger = Messenger<Event>()  // Message == Event
    enum Event { case willUpdate, didUpdate, willDie }
}
```

# Variables

 `Var<Value>` is an `ObservableObject` that has a property `value: Value`. 

## Observe Variables

Whenever its `value` changes, `Var<Value>` sends a message of type `Update<Value>`, informing about the `old` and `new` value:

~~~swift
let number = Var(42)

observer.observe(number) { update in
    let whatsTheBigDifference = update.new - update.old
}

number <- 123
~~~

In addition, you can always manually call `variable.send()` (without argument) to send an update in which `old` and `new` both hold the current `value` (see [`Cached Messages`](#cached-messages)).

## Enjoy the Property Wrapper

Using the property wrapper `Observable`, the above example would look like this:

~~~swift
@Observable var number = 42

observer.observe($number) { update in
    let whatsTheBigDifference = update.new - update.old
}

number = 123
~~~

The wrapper's projected value provides the underlying `Var<Value>`, which you access via the `$` sign like in the above example. This is analogous to how you access publishers in Combine.

## Encode and Decode Variables

A `Var<Value>` is automatically `Codable` if its `Value` is. So when one of your types has `Var` properties, you can make that type `Codable` by simply adopting the `Codable` protocol:

~~~swift
class Model: Codable {
    private(set) var text = Var("String Variable")
}
~~~

Note that `text` is a `var` instead of a `let`. It cannot be constant because Swift's implicit decoder must mutate it. However, clients of `Model` would be supposed to set only `text.value` and not `text` itself, so the setter is private.

# Transforms

Transforms make common steps of message processing more succinct and readable. They allow to map, filter and unwrap messages in many ways. You may freely chain these transforms together and also define new ones with them.

This example transforms messages of type `Update<String?>` into ones of type `Int`:

```swift
let title = Var<String?>()

observer.observe(title).new().unwrap("Untitled").map({ $0.count }) { titleLength in
    // do something with the new title length
}
```

## Make Transforms Observable

You may transform a particular observation directly on the fly, like in the above example. Such ad hoc transforms give the observer lots of flexibility.

Or you may instantiate a new `ObservableObject` that has the transform chain baked into it. The above example could then look like this:

```swift
let title = Var<String?>()
let titleLength = title.new().unwrap("Untitled").map { $0.count }

observer.observe(titleLength) { titleLength in
    // do something with the new title length
}
```

Every transform object exposes its underlying `ObservableObject` as `origin`. You may even replace `origin`:

```swift
let titleLength = Var("Dummy Title").new().map { $0.count }
let title = Var("Real Title")
titleLength.origin.origin = title
```

Such stand-alone transforms can offer the same preprocessing to multiple observers. But since these transforms are distinct `ObservableObject`s, you must hold them strongly somewhere. Holding transform chains as dedicated observable objects suits entities like view models that represent transformations of other data.

## Use Prebuilt Transforms

Whether you apply transforms ad hoc or as stand-alone objects, they work the same way. The following list illustrates prebuilt transforms as observable objects.

### Map

First, there is your regular familiar `map` function. It transforms messages and often also their type:

```swift
let messenger = Messenger<String>()          // sends String
let stringToInt = messenger.map { Int($0) }  // sends Int?
```

### New

When an `ObservableObject` like a `Var<Value>` sends *messages* of type `Update<Value>`, we often only care about  the `new` value, so we map the update with `new()`:

~~~swift
let errorCode = Var<Int>()          // sends Update<Int>
let newErrorCode = errorCode.new()  // sends Int
~~~

### Filter

When you want to receive only certain messages, use `filter`:

```swift
let messenger = Messenger<String>()                     // sends String
let shortMessages = messenger.filter { $0.count < 10 }  // sends String if length < 10
```

### Select

Use `select` to receive only one specific message. `select` works with all `Equatable` message types. `select` maps the message type onto `Void`, so a receiving closure after a selection takes no message argument:

```swift
let messenger = Messenger<String>()                   // sends String
let myNotifier = messenger.select("my notification")  // sends Void (no messages)

observer.observe(myNotifier) {                        // no argument
    // someone sent "my notification"
}
```

### Unwrap

Sometimes, we make message types optional, for example when there is no meaningful initial value for a `Var`. But we often don't want to deal with optionals down the line. So we can use `unwrap()`, suppressing `nil` messages entirely:

~~~swift
let errorCodes = Messenger<Int?>()     // sends Int?       
let errorAlert = errorCodes.unwrap()   // sends Int if the message is not nil
~~~

### Unwrap with Default

You may also unwrap optional messages by replacing `nil` values with a default:

~~~swift
let points = Messenger<Int?>()         // sends Int?       
let pointsToShow = points.unwrap(0)    // sends Int with 0 for nil
~~~

## Chain Transforms

You may chain transforms together:

```swift
let numbers = Messenger<Int>()

observer.observe(numbers).map {
    "\($0)"                      // Int -> String
}.filter {
    $0.count > 1                 // suppress single digit integers
}.map {
    Int.init($0)                 // String -> Int?
}.unwrap {                       // Int? -> Int
    print($0)                    // receive and process resulting Int
}
```

Of course, ad hoc transforms like the above end on the actual message handling closure. Now, when the last transform in the chain also takes a closure argument for its processing, like `map` and `filter` do, we use `receive` to stick with the nice syntax of [trailing closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html#ID102):

~~~swift
dog.observe(Sky.shared).map {
    $0 == .blue     
}.receive {
    print("Will we go outside? \($0 ? "Yes" : "No")!")
} 
~~~

# Advanced

## Interoperate With Combine

**CombineObserver** is a library contained in the SwiftObserver package. It depends on SwiftObserver and adds a simple way to transform any SwiftObserver- `ObservableObject` into a Combine-`Publisher`:

```swift
import CombineObserver

@Observable var number = 7                  // SwiftObserver
let numberPublisher = $number.publisher()   // Combine

let cancellable = numberPublisher.dropFirst().sink { numberUpdate in
    print("\(numberUpdate.new)")
}

number = 42 // prints "42"
```

Some reasoning behind this: SwiftObserver is for pure Swift-/model code without external dependencies – not even on Combine. When combined with Combine (🙊), SwiftObserver would be employed in the model core of an application, while Combine would be used more with I/O periphery like SwiftUI and other system-specific APIs that already rely on Combine. That means, the "Combine layer" might want to observe (react to-) the "SwiftObserver layer" – but hardly the other way around.

## Message Authors

Every message has an author associated with it. This feature is only noticable in code if you use it.

An observable object can send an author together with a message via `object.send(message, from: author)`. If noone specifies an author as in `object.send(message)`, the observable object itself becomes the author.

### Mutate Variables

Variables have a special value setter that allows to identify change authors:

```swift
let number = Var(0)
number.set(42, as: controller) // controller becomes author of the update message
```

### Receive Authors

The observer can receive the author, by adding it as an argument to the message handling closure:

```swift
observer.observe(observableObject) { message, author in
    // process message from author
}
```

Through the author, observers can determine a message's origin. In the plain messenger pattern, the origin would simply be the message sender.

### Share Observable Objects

Identifying message authors can become essential whenever multiple observers observe the same object while their actions can cause it so send messages.

Mutable data is a common type of such shared observable objects. For example, when multiple entities observe and modify a storage abstraction or caching hierarchy, they often want to avoid reacting to their own actions. Such overreaction might lead to redundant work or inifnite response cycles. So they identify as change authors when modifying the data and ignore messages from `self` when observing it:

```swift
class Collaborator: Observer {
    func observeText() {
        observe(sharedText).notFrom(self) { update, author in  // see author filters below
            // someone else edited the text
        }
    }
  
    func editText() {
        sharedText.set("my new text", as: self)                // identify as change author
    }
  
    let receiver = Receiver()
}

let sharedText = Var<String>()
```

### Filter by Author

There are three transforms related to message authors. As with other transforms, we can apply them directly in observations or create them as standalone observable objects.

#### Filter Author

We filter authors just like messages:

```swift
let messenger = Messenger<String>()             // sends String

let friendMessages = messenger.filterAuthor {   // sends String if message is from friend
    friends.contains($0)
} 
```

#### From

If only one specific author is of interest, filter authors with `from`. It captures the selected author weakly:

```swift
let messenger = Messenger<String>()             // sends String
let joesMessages = messenger.from(joe)          // sends String if message is from joe
```

#### Not From

If **all but one** specific author are of interest, use `notFrom`. It also captures the excluded author weakly:

```swift
let messenger = Messenger<String>()             // sends String
let humanMessages = messenger.notFrom(hal9000)  // sends String, but not from an evil AI
```

## Cached Messages 

An `ObservableCache` is an `ObservableObject` that has a property `latestMessage: Message` which typically returns the last sent message or one that indicates that nothing has changed. `ObservableCache` has a function `send()` that takes no argument and sends `latestMessage`.

### Four Kinds of Caches

1. Any `Var` is an `ObservableCache`. Its `latestMessage` is an `Update` in which `old` and `new` both hold the current `value`.

2. Calling `cache()` on an `ObservableObject` creates a [transform](#make-transforms-observable) that is an `ObservableCache`. That cache's `Message` will be optional but never an *optional optional*, even when the origin's `Message` is already optional.

   Of course, `cache()` wouldn't make sense as an adhoc transform of an observation, so it can only create a distinct observable object.

3. Any transform whose origin is an `ObservableCache` is itself implicitly an `ObservableCache` **if** it never suppresses (filters) messages. These compatible transforms are: `map`, `new` and `unwrap(default)`.

   Note that the `latestMessage` of a transform that is an implicit `ObservableCache` returns the transformed `latestMessage` of its underlying `ObservableCache` origin. Calling `send(transformedMessage)` on that transform itself will not "update" its `latestMessage`.

4. Custom observable objects can easily conform to `ObservableCache`. Even if their message type isn't based on some state, `latestMessage` can still return a meaningful default value - or even `nil` where `Message` is optional.

### State-Based Messages 

An `ObservableObject` like `Var`, that derives its messages from its state, can generate a "latest message" on demand and therefore act as an `ObservableCache`:

```swift
class Model: Messenger<String>, ObservableCache {  // informs about the latest state
    var latestMessage: String { state }            // ... either on demand
  
    var state = "initial state" {
        didSet {
            if state != oldValue {
                send(state)                        // ... or when the state changes
            }
        }
    }
}
```

## Weak Observable Objects

When you want to put an `ObservableObject` into some data structure or as the *origin* into a *transform* object but hold it there as a `weak` reference, transform it via `observableObject.weak()`:

~~~swift
let number = Var(12)
let weakNumber = number.weak()

observer.observe(weakNumber) { update in
    // process update of type Update<Int>
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

Of course, `weak()` wouldn't make sense as an adhoc transform, so it can only create a distinct observable object.

# More

## Further Reading

* **Patterns:** Read more about some [patterns that emerged from using SwiftObserver](Documentation/specific-patterns.md#specific-patterns).
* **Philosophy:** Read more about the [philosophy and features of SwiftObserver](Documentation/philosophy.md#the-philosophy-of-swiftobserver).
* **License:** SwiftObserver is released under the MIT license. [See LICENSE](LICENSE) for details.

## Open Tasks

* Update and rework (or simply delete) texts about philosophy and patterns
* Engage feedback and contribution

[badge-swift-versions]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcodeface-io%2FSwiftObserver%2Fbadge%3Ftype%3Dswift-versions&style=flat-square

[badge-platforms]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcodeface-io%2FSwiftObserver%2Fbadge%3Ftype%3Dplatforms&style=flat-square

[badge-mit]: https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square
