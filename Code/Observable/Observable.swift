public extension BufferedObservable
{
    func send() { send(latestMessage) }
}

public protocol BufferedObservable: Observable
{
    var latestMessage: Message { get }
}

public extension Observable
{
    func send(_ message: Message, author: AnyAuthor? = nil)
    {
        messenger.send(message, author: author ?? self)
    }
    
    internal func add(_ observer: AnyReceiver, receive: @escaping (Message, AnyAuthor) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    internal func add(_ observer: AnyReceiver, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer) { message, _ in receive(message) }
    }
    
    internal func remove(_ observer: AnyReceiver)
    {
        messenger.remove(observer)
    }
}

// TODO: unit test that this lil trick works as expected, without any weird infinite self-referential recursion
extension Messenger: Observable
{
    public var messenger: Messenger<Message> { self }
}

public protocol Observable: AnyAuthor
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
