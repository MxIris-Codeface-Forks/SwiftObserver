import XCTest
import SwiftObserver
import Foundation

class SwiftObserverTests: XCTestCase
{
    func testWeakObservable()
    {
        var strongObservable: Var<Int>? = Var(10)
        
        let weakObservable = Weak(strongObservable!)
        
        XCTAssert(strongObservable === weakObservable.observable)
        
        strongObservable = nil
        
        XCTAssertNil(weakObservable.observable)
        XCTAssertEqual(weakObservable.latestUpdate.new, 10)
    }
    
    func testSettingObservableOfMapping()
    {
        let mapping = Var<String>().new().unwrap("")
        
        var observedStrings = [String]()
        
        controller.observe(mapping)
        {
            newString in
            
            observedStrings.append(newString)
        }
        
        XCTAssertEqual(observedStrings, [])
        
        let initialText = "initial text"
        
        let text = Var(initialText)
        mapping.source = text
        
        XCTAssertEqual(mapping.latestUpdate, initialText)
        XCTAssertEqual(observedStrings, [initialText])
        
        let newText = "new text"
        text <- newText
        
        XCTAssertEqual(mapping.latestUpdate, newText)
        XCTAssertEqual(observedStrings, [initialText, newText])
    }
    
    func testSingleObservationFilter()
    {
        let number = Var(99)
        let latestUnwrappedNumber = number.new().unwrap(0)
        
        var observedNumbers = [Int]()
        
        controller.observe(latestUnwrappedNumber, filter: { $0 > 9 })
        {
            observedNumbers.append($0)
        }
        
        number <- 10
        number <- nil
        number <- 11
        number <- 1
        number <- 12
        number <- 2
        
        XCTAssertEqual(observedNumbers, [10, 11, 12])
    }
    
    func testMappingsIncludingFilter()
    {
        let number = Var(99)
        let doubleDigits = number.new().unwrap(0).filter { $0 > 9 }
        
        var observedNumbers = [Int]()
        
        controller.observe(doubleDigits)
        {
            observedNumbers.append($0)
        }
        
        number <- 10
        number <- nil
        number <- 11
        number <- 1
        number <- 12
        number <- 2
        
        XCTAssertEqual(observedNumbers, [10, 11, 12])
    }
    
    func testCombineMappingsByChainingThem()
    {
        let number = Var<Int>()
        
        var strongNewNumber: Mapping<Variable<Int>, Int?>? = number.new()
        weak var weakNewNumber = strongNewNumber
        
        guard let strongUnwrappedNewNumber = weakNewNumber?.filter({ $0 != nil }).unwrap(-1) else
        {
            XCTAssert(false)
            return
        }
        
        var observedNumbers = [Int]()
        
        controller.observe(strongUnwrappedNewNumber)
        {
            observedNumbers.append($0)
        }
        
        XCTAssertNotNil(strongNewNumber)
        XCTAssertNotNil(weakNewNumber)
        
        strongNewNumber = nil
        XCTAssertNil(weakNewNumber)

        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, -1)
        
        number <- 9
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, 9)
        
        number <- nil
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, -1)
        
        number <- 10
        XCTAssertEqual(strongUnwrappedNewNumber.latestUpdate, 10)
        
        XCTAssertEqual(observedNumbers, [9, 10])
    }
    
    func testSimpleMessenger()
    {
        let textMessenger = Var<String>().new()
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        textMessenger.send(expectedMessage)

        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testSimpleMessengerWithSpecificMessage()
    {
        let textMessenger = Var<String>().new()
        var receivedMessage: String?
        let expectedMessage = "message"
        
        controller.observe(textMessenger, select: expectedMessage)
        {
            receivedMessage = expectedMessage
        }
        
        textMessenger.send(expectedMessage)
        
        XCTAssertEqual(receivedMessage, expectedMessage)
    }
    
    func testMessengerBackedByVariable()
    {
        let textMessage = Var<String>("initial message")
        let textMessenger = textMessage.new()
        
        XCTAssertEqual(textMessenger.latestUpdate, "initial message")
        
        var receivedMessage: String?
        
        controller.observe(textMessenger)
        {
            receivedMessage = $0
        }
        
        XCTAssertNil(receivedMessage)
        
        textMessage <- "user error"
        
        XCTAssertEqual(textMessenger.latestUpdate, "user error")
        XCTAssertEqual(receivedMessage, "user error")
    }
    
    func testObservingWrongMessage()
    {
        let textMessenger = Var<String>().new()
        var receivedMessage: String?
        
        controller.observe(textMessenger, select: "wrong message")
        {
            receivedMessage = "wrong message"
        }
        
        textMessenger.send("right message")
        
        XCTAssertNil(receivedMessage)
    }

    func testHowToUseOptionalVariables()
    {
        let text = Var("initial value")
        
        text <- nil
        
        XCTAssertNil(text.value)
        
        var didUpdate = false
        
        controller.observe(text)
        {
            XCTAssertEqual($0.new, "text")
            
            didUpdate = true
        }
        
        text <- "text"
        
        XCTAssertEqual(text.value, "text")
        XCTAssert(didUpdate)
    }
    
    func testHowToMapVariablesToNonOptionalValues()
    {
        let text = Var<String>()
        
        let nonOptionalText = text.map { $0.new ?? "" }
        
        var didUpdate = false
        
        controller.observe(nonOptionalText)
        {
            XCTAssertEqual($0, "")
            
            didUpdate = true
        }
        
        text.send()
        
        XCTAssert(didUpdate)
    }
    
    func testHowToUseUnwrapMapping()
    {
        let text = Var<String>()
        let unwrappedText = text.new().unwrap("")
        
        var didUpdate = false
        
        controller.observe(unwrappedText)
        {
            XCTAssertEqual($0, "")
            didUpdate = true
        }
        
        text.send()
        
        XCTAssert(didUpdate)
    }
    
    func testHowToUseNewMappingOnObservablesThatAreNotVariables()
    {
        let newState = customObservable.new()
        
        customObservable.state = "state1"
        
        var didUpdate = false
        
        controller.observe(newState)
        {
            XCTAssert($0 == "state1" || $0 == "state2")
            
            didUpdate = $0 == "state2"
        }
        
        customObservable.state = "state2"
        
        XCTAssert(didUpdate)
    }
    
    func testObservingTheModel()
    {
        var didUpdate = false
        
        controller.observe(model)
        {
            XCTAssertEqual($0, .didUpdate)
            didUpdate = true
        }
        
        model.send(.didUpdate)
        
        XCTAssert(didUpdate)
    }
    
    func testObservingVariableDoesNotTriggerUpdate()
    {
        let text = Var("initial text")
        
        var didTriggerUpdate = false
        
        controller.observe(text)
        {
            _ in
            
            didTriggerUpdate = true
        }
        
        XCTAssertFalse(didTriggerUpdate)
    }
    
    func testObservingVariableValueChange()
    {
        var observedNewValue: String?
        var observedOldValue: String?
        
        controller.observe(model.text)
        {
            observedOldValue = $0.old
            observedNewValue = $0.new
        }
        
        model.text <- "new text"
        
        XCTAssertEqual(observedOldValue, nil)
        XCTAssertEqual(observedNewValue, "new text")
    }
    
    
    func testObservableMapping()
    {
        controller.observe(model.map { $0.rawValue })
        {
            XCTAssertEqual($0, "didUpdate")
        }
        
        model.send(.didUpdate)
    }
    
    
    func testObservingTwoObservables()
    {
        let testModel = Model()
        let number = Var<Int>()
        
        var didFire = false
        var lastObservedEvent: Model.Event?
        var lastObservedNumber: Int?
        
        controller.observe(testModel, number)
        {
            event, numberUpdate in
            
            didFire = true
            
            lastObservedEvent = event
            lastObservedNumber = numberUpdate.new
        }
        
        testModel.send(.didUpdate)
        
        XCTAssert(didFire)
        XCTAssertEqual(lastObservedEvent, .didUpdate)
        
        didFire = false
        number <- 7
        
        XCTAssert(didFire)
        XCTAssertEqual(lastObservedNumber, 7)
    }
    
    func testVariableIsCodable()
    {
        var didEncode = false
        var didDecode = false
        
        let variable = Var(123)
        
        if let variableData = try? JSONEncoder().encode(variable)
        {
            let actual = String(data: variableData, encoding: .utf8) ?? "fail"
            let expected = "{\"storedValue\":123}"
            XCTAssertEqual(actual, expected)
            
            didEncode = true
            
            if let decodedVariable = try? JSONDecoder().decode(Var<Int>.self,
                                                               from: variableData)
            {
                XCTAssertEqual(decodedVariable.value, 123)
                didDecode = true
            }
        }
        
        XCTAssert(didEncode)
        XCTAssert(didDecode)
    }
    
    func testCodingTheModel()
    {
        var didEncode = false
        var didDecode = false
        
        model.text <- "123"
        model.number <- 123
        
        if let modelJson = try? JSONEncoder().encode(model)
        {
            let actual = String(data: modelJson, encoding: .utf8) ?? "fail"
            let expected = "{\"number\":{\"storedValue\":123},\"text\":{\"storedValue\":\"123\"}}"
            XCTAssertEqual(actual, expected)
            
            didEncode = true
            
            if let decodedModel = try? JSONDecoder().decode(Model.self, from: modelJson)
            {
                XCTAssertEqual(decodedModel.text.value, "123")
                XCTAssertEqual(decodedModel.number.value, 123)
                didDecode = true
            }
        }
        
        XCTAssert(didEncode)
        XCTAssert(didDecode)
    }
    
    func testObservingThreeVariables()
    {
        let var1 = Var<Bool>()
        let var2 = Var<Int>()
        let var3 = Var<String>()
        
        let observer = Controller()
        
        var observedString: String?
        var didFire = false
        
        observer.observe(var1, var2, var3)
        {
            truth, number, string in
            
            didFire = true
            observedString = string.new
        }
        
        var3 <- "test"
        
        XCTAssert(didFire)
        XCTAssertEqual(observedString, "test")
    }

    let model = Model()
    
    let controller = Controller()
    
    class Model: Observable, Codable
    {
        var latestUpdate: Event { return .didNothing }
        
        enum Event: String { case didUpdate, didReset, didNothing }
        
        private(set) var text = Var<String>()
        private(set) var number = Var<Int>()
    }
    
    let customObservable = ModelWithState()
    
    class ModelWithState: Observable
    {
        var latestUpdate: Update<String>
        {
            return Update(state, state)
        }
        
        var state = "initial state"
        {
            didSet
            {
                if oldValue != state
                {
                    send(Update(oldValue, state))
                }
            }
        }
    }
 
    class Controller: Observer
    {
        deinit
        {
            stopObserving()
        }
    }
}

