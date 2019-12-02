![SwiftObserver](https://raw.githubusercontent.com/flowtoolz/SwiftObserver/master/Documentation/swift.jpg)



# [v6.0.0-beta]

This is the branch for the next major update. Overall, SwiftObserver becomes more powerful and yet simpler, safer, more consistent and more flexible. The number of lines has actually decreased, in code and in documentation.

The documentation here does **not** yet cover all commited changes and their implications. But here are two checklists for the release notes and documentation of v6.0.0.

Improved:

* Observable transforms (formerly "mappings") and observation transforms now also have a default-less `unwrap()`.
* No more message duplication in messengers since the `latestMessage` requirement is limited to `BufferedObservable`s. And so, switching buffering on or off there is also no more concern.
* Change is Equatable when its Value is Equatable, so messages of variables can be selected via `select(Change(specificOldValue, specificNewValue))`.
* Message buffering now happens exactly whenever it is fully possible, that is whenever the observable is backed by an actual value (like variables are) and there is no filter involved in the observable. Filters annihilate random access pulling. The weirdness of a mapping having to ignore its filter in its implementation of `latestMessage` is gone.
* Message order is maintained for all observables not just for variables. All observables use a message queue now.
* An observer can now check whether it already observes an observable via `observer.isObserving(observable)`.
* The `Observable` protocol has become even simpler. It just requires one `Messenger`. All observables are now implemented that way and are thereby on equal footing. You could now easily reimplement `Var` and benefit from the order maintaining message queue of `Messenger`.
* Custom observables are even simpler to implement:
  * The protocol is the same old familiar `Observable`.
  * The `typealias Message = MyMessageType` can now be omitted.
  * The need for using optional message types to be able to implement `latestMessage` is gone.
* Observers can optionally receive the author of a message via an alternative receive closure (so it breaks no code and the additional argument is only present when spelled out). Also, observables can optionally identify an author other than themselves, if they want to (also not a breaking change).
  * This is hugely beneficial when working with observed shared mutable states like the repository / store pattern, really any storage abstraction, classic messengers (notifiers) and more.
  * Basically, an observer can ignore messages that he himself triggered, even when the trigger was indirect.
* The internals are much better implemented and much more readable. No forced unwraps for the unwrap transforms, No weird function and filter compositions. "Mappings" are now separated into the three simple transforms: map, filter and unwrap. Also, SwiftObserver even has less code overall.
* The issue that certain Apple classes (like NSTextView) cannot directly be `Observable` because they can't be referenced weakly is gone. SwiftObserver now only references an `Observable`'s `messenger: Messenger` weakly.

Removed / Simplified:

* A few memory management functions were removed since they were overkill and not actually needed.
* The `ObservableObject` class was removed. The Messenger roughly plays that role now.
* The source of transforms cannot be reset as it was the case for mappings. As a nice side effect, the question whether a mapping fires when its source is reset is no concern anymore.

# SwiftObserver

[![badge-pod]](http://cocoapods.org/pods/SwiftObserver) ![badge-pms] ![badge-languages] [![badge-gitter]](https://gitter.im/flowtoolz/SwiftObserver?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) ![badge-platforms] ![badge-mit]

SwiftObserver is a lightweight framework for reactive Swift. Its design goals make it easy to learn and a joy to use:

1. [**Meaningful Code**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#meaningful-code):<br>SwiftObserver promotes meaningful metaphors, names and syntax, producing highly readable code.
2. [**Non-intrusive Design**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#non-intrusive-design):<br>SwiftObserver doesn't limit or modulate your design. It just makes it easy to do the right thing.
3. [**Simplicity**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility):<br>SwiftObserver employs very few simple concepts and applies them consistently without exceptions.
4. [**Flexibility**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#simplicity-and-flexibility):<br>SwiftObserver's types are simple but universal and composable, making them applicable in many situations.
5. [**Safety**](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#safety):<br>SwiftObserver makes memory management meaningful and easy. Oh yeah, real memory leaks are impossible.

[*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming) adresses the central challenge of implementing a clean architecture: [*Dependency Inversion*](https://en.wikipedia.org/wiki/Dependency_inversion_principle). SwiftObserver breaks *Reactive Programming* down to its essence, which is the [*Observer Pattern*](https://en.wikipedia.org/wiki/Observer_pattern).

SwiftObserver is just about 1200 lines of production code, but it's also beyond a 1000 hours of work, thinking it through, letting go of fancy features, documenting it, [unit-testing it](https://github.com/flowtoolz/SwiftObserver/blob/master/Tests/SwiftObserverTests/SwiftObserverTests.swift), and battle-testing it [in practice](http://flowlistapp.com).

* [Get Involved](#get-involved)
* [Get Started](#get-started)
    * [Install](#install)
    * [Introduction](#introduction)
* [Memory Management](#memory-management)
* [Variables](#variables)
    * [Use Variable Values](#use-variable-values)
    * [Observe Variables](#observe-variables) 
    * [Variables are Codable](#variables-are-codable)
* [Transforms](#transforms)
    * [Create Transforms](#create-transforms)
    * [Chain Transforms](#chain-transforms)
    * [Use Prebuilt Transforms](#use-prebuilt-transforms)
* [Ad Hoc Transformation](#ad-hoc-transformation)
* [Messengers](#messengers)
    * [The Messenger Pattern](#the-messenger-pattern)
    * [The Messenger Class](#the-messenger-class)
* [Custom Observables](#custom-observables)
    * [Declare Custom Observables](#declare-custom-observables)
    * [Send Custom Messages](#send-custom-messages)
* [Advanced Observables](#advanced-observables)
    * [Message Buffering](#message-buffering)
    * [State Changes](#state-changes)
    * [Weak Reference](#weak-reference)
* [Specific Patterns](#specific-patterns)
* [Why the Hell Another Reactive Library?](#why)

# Get Involved

Found a **bug**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).

Need a **feature**? Create a [github issue](https://github.com/flowtoolz/SwiftObserver/issues/new/choose).

Want to **improve** stuff? Create a [pull request](https://github.com/flowtoolz/SwiftObserver/pulls).

Want to start a **discussion**? Visit [Gitter](https://gitter.im/flowtoolz/SwiftObserver/).

Need **support** and troubleshooting? Write at <swiftobserver@flowtoolz.com>.

Want to **contact** us? Write at <swiftobserver@flowtoolz.com>.

# Get Started

## Install

With [**Carthage**](https://github.com/Carthage/Carthage), add this line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "flowtoolz/SwiftObserver" ~> 6.0
```

Then follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) and run `$ carthage update --platform ios`.

With [**Cocoapods**](https://cocoapods.org), adjust your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```ruby
use_frameworks!

target "MyAppTarget" do
  pod "SwiftObserver", "~> 6.0"
end
```

Then run `$ pod install`.

With the [**Swift Package Manager**](https://github.com/apple/swift-package-manager/tree/master/Documentation#swift-package-manager), adjust your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#create-a-package) file:

~~~swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SPMExample",
    dependencies: [
        .package(url: "https://github.com/flowtoolz/SwiftObserver.git",
                 .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(name: "SPMExample",
                dependencies: ["SwiftObserver"])
    ],
    swiftLanguageVersions: [.v5]
)
~~~

Then run `$ swift build` or `$ swift run`.

Finally, in your **Swift** files:

```swift
import SwiftObserver
```

## Introduction

> No need to learn a bunch of arbitrary metaphors, terms or types.<br>SwiftObserver is simple: **Objects observe other objects**.

Or a tad more technically: Observed objects send *messages* to their *observers*. 

That's it. Just readable code:

~~~swift
dog.observe(Sky.shared) { color in
    // marvel at the sky changing its color
}

class Dog: Observer {
    deinit {
        stopObserving() // stops ALL observations this Dog is doing
    } 
}
~~~

### Observers

By conforming to `Observer`, the *observer* adopts functions for starting and ending observations. Each observation involves one *observer* and one observed object. <a id="combined-observations"></a> An  `Observer` may start up to three observations with one combined call:

~~~swift
dog.observe(tv, bowl, doorbell) { image, food, sound in
    // either the tv's going, I got some food, or the bell rang
}
~~~

To process *messages* from an observed object, the *observer* must be alive. There's no awareness after death in memory:

```swift
class Dog: Observer {
    init {
        observe(Sky.shared) { color in
            // for this closure to be called, this Dog must live
        }
    }
}
```

### Observables

For objects to be observable, they must conform to `Observable`. There are four ways to make these *observables*:

1. Create a [*variable*](#variables). It's an `Observable` that holds a value and sends value changes.
2. Create a [*transform*](#transforms). It's an `Observable` that transforms *messages* from a *source observable*.
3. Create a [*messenger*](#messengers). It's a minimal `Observable` through which other objects communicate.
4. Implement a [custom](#custom-observables) `Observable` by conforming to `Observable`.

You use every `Observable` the same way. There are only three things to note:

1. Observing an `Observable` does not have the side effect of keeping it alive. Someone must own it via a strong reference. Note that you can still [observe with a chain of ad hoc transformations](#ad-hoc-mapping) all in a single line.
2. An `Observable` appends the messages it sends to a queue, so all its *observers* get to process messages exactly in the order in which they were sent. This is for situations when the `Observable` has multiple *observers* and at least one of them, in response to receiving a message, causes the *observable* to send another message.
3. Typically, an `Observable` sends its *messages* by itself. But anyone can make it send any *message* via `send(_:)`.

# Memory Management

To avoid abandoned observations piling up in memory, *observers* should at some point stop the observations they started. One way to do that is to stop each observation when it's no longer needed:

```swift
dog.stopObserving(Sky.shared)
```

An even simpler and safer way is to let *observers*, right before they die, stop all their observations:

```swift
class Dog: Observer {
    deinit {
        stopObserving()  // stops ALL observations this Dog is doing
    }
}
```

`Observables` are even easier to handle. When an *observable* dies, it automatically stops all observations in which it is being observed.

Forgetting some observations wouldn't waste significant memory. But you should understand, control and express the mechanics of your code to a degree that prevents systemic leaks.

The two above mentioned functions are all you need for safe memory management. If you still forget to write some cleanup code, SwiftObserver handles that gracefully. When you send messages to dead observers, SwiftObserver will detect that and flush out the respective observations.

> Memory management with SwiftObserver is meaningful and safe. There are no contrived constructs like "Disposable" or "DisposeBag". And since SwiftObserver notices abandoned observations, real memory leaks are impossible.

# Variables

A `Var<Value>` has a property `value: Value`. If `Value` is `Equatable` or `Comparable`, the whole `Var<Value>` will also conform to the respective protocol.

## Use Variable Values

You can set `value` directly, via initializer and via the `<-` operator:

~~~swift
let text = Var<String?>()    // text.value == nil
text.value = "a text"
let number = Var(23)         // number.value == 23
number <- 42                 // number.value == 42
~~~

### Number Values

If you use some number type `Number` that is either an `Int`, `Float` or `Double`:

1. Every `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?` has either a `var int: Int`, `var float: Float` or `var double: Double`. That property is non-optional and interprets `nil` values as zero.

2. You can apply numeric operators `+`, `-`, `*` and `/` to all pairs of `Number`, `Number?`, `Var<Number>`, `Var<Number?>`, `Var<Number>?` and `Var<Number?>?`.

3. ```swift
    let numVar = Var<Int?>()     // numVar.value == nil
    print(numVar.int)            // 0
    numVar.int += 5              // numVar.value == 5
    numVar <- Var(1) + 2         // numVar.value == 3
    ```

### String Values

1. Every `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?` has a `var string: String`. That property is non-optional and interprets `nil` values as `""`.
2. Representing its `string` property, every `Var<String>` and `Var<String?>` conforms to `BidirectionalCollection`, `Collection` and `Sequence`.
3. You can apply concatenation operator `+` to all pairs of `String`, `String?`, `Var<String>`, `Var<String?>`, `Var<String>?` and `Var<String?>?`.

## Observe Variables

A `Var<Value>` sends *messages* of type `Change<Value>`, providing the `old` and `new` value.

~~~swift
observer.observe(variable) { change in
    let whatsTheBigDifference = change.new - change.old
}
~~~

A `Var` sends a `Change<Value>` whenever its `value` actually changes. Just starting to observe the `Var` does **not** trigger a *message*. This keeps it simple, predictable and consistent, in particular in combination with [*mappings*](#mappings). However, you can always manually send  the `latestMessage` via `send()` (see [`BufferedObservable`](#message-buffering)).

## Variables are Codable

`Var` is `Codable`, so when you declare a type with `Var` properties, you can make it `Codable` by simply adopting the `Codable` protocol. To this end, `Var.Value` must be `Codable`:

~~~swift
class Model: Codable {
    private(set) var text = Var("String Variable")
}

let model = Model()

if let modelJSON = try? JSONEncoder().encode(model) {
    print(String(data: modelJSON, encoding: .utf8) ?? "error")
    // ^^ {"text":{"storedValue":"String Variable"}}
            
    if let decodedModel = try? JSONDecoder().decode(Model.self, from: modelJSON) {
        print(decodedModel.text.value)
        // ^^ String Variable
    }
}
~~~

Note that `text` is a `var` instead of a `let`. It cannot be constant because the implicit decoder must mutate it. However, clients of `Model` would be supposed to set only `text.value` and not `text` itself, so the setter is private.

# Transforms

## Create Transforms

Create a new `Observable` that transforms the *messages* of a given *source observable*:

~~~swift
let text = Var<String?>()
let textLength = text.map { $0.new?.count ?? 0 }
// ^^ an Observable mapper that sends Int messages
~~~

A *transform* holds its transformed observable strongly, just like arrays and other data structures would hold an `Observable`. You could rewrite the above example like so:

```swift
let textLength = Var<String?>().map { $0.new?.count ?? 0 }
```

When you want to hold a *transform* weakly, wrap it in [`Weak`](#weak-observables). For instance, you can let a transform hold its *source*  weakly:

```swift
let toString = Weak(Var<Int?>()).new().unwrap(0).map { "\($0)" }
// ^^ no one holds Var<Int?>(), so it dies
```

As [mentioned earlier](#observables), you use a transform like any other `Observable`: You hold a strong reference to it somewhere, you stop observing it (not the transformed observable) at some point, and you can call `send(_:)` on it.

## Chain Transforms

You may chain transforms together:

```swift
let mapping = Var<Int?>().map {
    $0.new ?? 0                   // Change<Int?> -> Int
}.filter {
    $0 > 9                        // only forward integers > 9
}.map {
    "\($0)"                       // Int -> String
}
// ^^ mapping sends messages of type String
```

## Use Prebuilt Transforms

### New

When an `Observable` sends *messages* of type `Change<Value>`, you often only care about  the `new` value of that change. If so, use `new()`:

~~~swift
let text = Var<String?>().new()
// ^^ sends messages of type String?
~~~

### Unwrap

Sometimes, we make *message* types optional, for example when there is no meaningful initial value for a `Var`. But we often don't want to deal with optionals down the line. You can apply the *mappings* `unwrap(_:)` and `unwrap()` to **any** `Observable` that sends optional *messages*. `unwrap(_:)` replaces `nil` messages with a default.  `unwrap()`  supresses them entirely:

~~~swift
let title = Var<String?>().new().unwrap("untitled")
// ^^ sends messages of type String, replacing nil with "untitled"

let errorCode = Var<Int?>().new().unwrap()
// ^^ sends messages of type Int, not sending at all for nil source values
~~~

### Filter

When you just want to filter- and not actually convert *messages* into different types, use `filter`:

```swift
let shortText = Var("").new().filter { $0.count < 5 }
// ^^ sends messages of type String, suppressing long strings
```

### Select

Use the `select` filter to receive only one specific *message*. `select` is available on all *observables* that send `Equatable` *messages*. When observing a transform produced by `select`, the closure takes no arguments:

```swift
let notifier = Var("").new().select("my notification")

observer.observe(notifier) {  // nothing going in
    // someone sent "my notification"
}
```

# Ad Hoc Transformation

The moment we start a particular observation, we often want to apply common transformations to it. Of course, **we cannot observe an ad hoc created [*transform*](#transforms)**:

```swift
dog.observe(bowl.map({ $0 == .wasFilled })) { bowlWasFilled in
    // FAIL: This closure will never run since no one holds the observed mapper!
    // .map({ $0 == .wasFilled }) creates a mapper which immediately dies                       
}   
```

Instead of holding a dedicated [*transform*](#transforms) somewhere, you can map the observation itself:

```swift
dog.observe(bowl).map({ $0 == .wasFilled }) { bowlWasFilled in
    if bowlWasFilled {
        // clear bowl in under a minute
    }
}   
```

You do this *ad hoc transforming* in the same terms in which you create stand-alone [*transforms*](#transforms): With `map`, `new`, `unwrap`, `filter` and `select`. And you also chain these transformations together:

```swift
let number = Var(42)
        
observer.observe(number).new().map {
    "\($0)"         // Int -> String
}.filter {
    $0.count > 1    // filter out single digit integers
}.map {
    Int.init($0)    // String -> Int?
}.filter {
    $0 != nil       // filter out nil values
}.unwrap {          // Int? -> Int, and pass final message receiver
    print($0)       // process Int
}
```

Consequently, each transform function comes in 2 variants:

1. The chaining variant returns a result on which you call the next transform function.
2. The terminating variant takes your actual *message* receiver in an additional closure argument.


When the chain is supposed to end on a transform that take two closures, let `receive` terminate it to stick with [trailing closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html#ID102):

~~~swift
dog.observe(bowl).map {
    $0 == .wasFilled    // Bowl.Message -> Bool
}.receive {
    if $0 {             // if bowl was filled
        // clear bowl in under a minute
    }
} 
~~~

Remember that a `select` closure takes no arguments because it runs only for the selected *message*:

```swift
dog.observe(Sky.shared).select(.blue) {  // no argument in
    // the sky became blue, let's go for a walk!
}
```

# Messengers

## The Messenger Pattern

When *observer* and *observable* need to be more decoupled, it is common to use a mediating *observable* through which any object can anonymously send *messages*. An example of this mediator is [`NotificationCenter`](https://developer.apple.com/documentation/foundation/notificationcenter).

This use of the *Observer Pattern* is sometimes called *Messenger*, *Notifier*, *Dispatcher*, *Event Emitter* or *Decoupler*. Its main differences to direct observation are:

- The actual *observable*, which is the messenger, sends no *messages* by itself.
- Every object can trigger *messages*, without adopting any protocol.
- Multiple sending objects trigger the same type of *messages*.
- An *observer* may indirectly observe multiple other objects through one observation.
- *Observers* don't care as much who triggered a *message*.
- *Observer* types don't need to depend on the types that trigger *messages*.

## The Messenger Class

The `Messenger` class embodies the messenger pattern. It is the simplest `Observable` and the core of any other `Observable`:

```swift
let textMessenger = Messenger<String>()

observer.observe(textMessenger) { textMessage in
    // respond to text message
}
        
textMessenger.send("my text message")
```

`Messenger` makes the indended pattern explicit and can be used with any type of message. You may use `select` to observe or "subscribe to-" one specific *message*:

```swift
observer.observe(textMessenger).select("my notification") {
    // respond to "my notification"
}
```

# Custom Observables

## Declare Custom Observables

Implement your own `Observable` by conforming to `Observable`. An *observable* just needs to provide some `messenger: Messenger<Message>`. Here's a minimal example:

~~~swift
class Minimal: Observable {
    let messenger = Messenger<String>()
}
~~~

A typical `Message` would be some `enum`:

~~~swift
class Model: Observable {
    let messenger = Messenger<Event>()
    enum Event { case willUpdate, didUpdate, willDeinit }
}
~~~

## Send Custom Messages

Messages are custom and yet fully typed. An `Observable` sends whatever it likes whenever it wants via `send(_ message: Message)`. This `Observable` sends optional strings:

~~~swift
class Model: Observable {
    init { send("did init") }
    func foo() { send(nil) }
    deinit { send("will deinit") }
    
    let messenger = Messenger<String?>()
}
~~~

# Advanced Observables

## Message Buffering

Combined observation like `observer.observe(o1, o2, o3) { m1, m2, m3 in /* ... */ }` only works with `BufferedObservable`s, because when one of the combined observables sends a message, the combined observation must **pull** messages from the other observables.

A `BufferedObservable` is an `Observable` that also has a property `latestMessage: Message` which typically returns the last sent *message* or one that indicates that nothing has changed. There are three kinds of buffered observables:

1. Every *variable* is a `BufferedObservable`. Its `latestMessage` holds the current variable `value` in both `Change` properties: `old` and `new`.
2. Every mapper whose mapped source observable is a `BufferedObservable` is itself a `BufferedObservable`. A buffered mapper just maps the `latestMessage` of its source. The ability of a chain of transformations to provide its `latestMessage` is only taken away by filters and the default-less unwrapper.
3. Custom implementations of `BufferedObservable`.

All `BufferedObservable`s can call `send()` without argument and, thereby, send the `latestMessage`.

## State Changes

To implement an `Observable` like `Var<Value>` that sends value changes, you would use the message type  `Change<Value>`. If you also want the observable to be suitable for combined observations, you make it a `BufferedObservable` and let `latestMessage` return a message based on the latest (current) value:

~~~swift
class Model: BufferedObservable {
    var latestMessage: Change<String> {
        Change(state, state)
    }
       
    var state: String = "" {
        didSet {
            if state != oldValue {
                send(Change(oldValue, state))
            }
        }
    }
        
    let messenger = Messenger(Change<String>())
}
~~~

## Weak Reference

When you want to put an `Observable` into some data structure or as the *source* into a *transform* and hold it there as a `weak` reference, you may want to wrap it in `Weak<O: Observable>`:

~~~swift
let number = Var(12)
let weakNumber = Weak(number)

controller.observe(weakNumber) { message in
    // process message of type Change<Int>
}

var weakNumbers = [Weak<Var<Int>>]()
weakNumbers.append(weakNumber)
~~~

`Weak<O: Observable>` is itself an `Observable` and functions as a complete substitute for its wrapped `weak` `Observable`, which you can access via the `observable` property:

~~~swift
let numberIsAlive = weakNumber.observable != nil
let numberValue = weakNumber.observable?.value
~~~

`Weak` isn't buffered and doesn't duplicate any messages. It would be easy to implement a class `BufferedWeak` that wraps a `BufferedObservable` weakly. If you like to see that, maybe even just for consistency/completeness, let me know.

# Specific Patterns

Patterns that emerged from using SwiftObserver [are documented over here](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/specific-patterns.md#specific-patterns).

# <a id="why"></a>Why the Hell Another Reactive Library?

SwiftObserver diverges from convention. It follows the reactive idea in generalizing the *Observer Pattern*. But it doesn't inherit the metaphors, terms, types, or function- and operator arsenals of common reactive libraries. This freed us to create something different, something we **love** to work with.

Leaving out the right kind of fancyness leaves us with the right kind of simplicity, a simplicity which is powerful. 

Read more about the [philosophy and features of SwiftObserver](https://github.com/flowtoolz/SwiftObserver/blob/master/Documentation/philosophy.md#the-philosophy-of-swiftobserver).

# License

SwiftObserver is released under the MIT license. [See LICENSE](https://github.com/flowtoolz/SwiftObserver/blob/master/LICENSE) for details.

[badge-gitter]: https://img.shields.io/badge/chat-Gitter-red.svg?style=flat-square

[badge-pod]: https://img.shields.io/cocoapods/v/SwiftObserver.svg?label=version&style=flat-square

[badge-pms]: https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SPM-green.svg?style=flat-square
[badge-languages]: https://img.shields.io/badge/language-Swift-orange.svg?style=flat-square
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg?style=flat-square
[badge-mit]: https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square
