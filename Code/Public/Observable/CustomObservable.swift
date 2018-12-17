public extension CustomObservable
{
    // MARK: - Convenience
    
    public var remembersLatestUpdate: Bool
    {
        get { return messenger.remembersLatestMessage }
        set { messenger.remembersLatestMessage = newValue }
    }
    
    // MARK: - Observable
    
    public var latestUpdate: UpdateType
    {
        return messenger.latestUpdate
    }
    
    func add(_ observer: AnyObject, receive: @escaping (UpdateType) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
    }

    func removeObservers()
    {
        messenger.removeObservers()
    }

    func removeDeadObservers()
    {
        messenger.removeDeadObservers()
    }

    func send(_ update: UpdateType)
    {
        messenger.send(update)
    }
}

public protocol CustomObservable: Observable
{
    var messenger: Messenger<UpdateType> { get }
}