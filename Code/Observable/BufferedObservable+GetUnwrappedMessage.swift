public extension BufferedObservable
{
    func whenFulfilled<Unwrapped>(_ receive: @escaping (Unwrapped) -> Void)
        where Message == Unwrapped?
    {
        if let message = latestMessage
        {
            receive(message)
        }
        else
        {
            observeOnce().unwrap(receiveUnwrapped: receive)
        }
    }
    
    func whenFulfilled<Unwrapped>(_ receive: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Message == Unwrapped?
    {
        if let message = latestMessage
        {
            receive(message, latestAuthor)
        }
        else
        {
            observeOnce().unwrap(receiveUnwrapped: receive)
        }
    }
}
