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
            let fulfillmentObserver = AdhocObserver()
            
            fulfillmentObserver.observe(self).unwrap
            {
                unwrapped in
                
                fulfillmentObserver.stopObserving()
                
                receive(unwrapped)
            }
        }
    }
}
