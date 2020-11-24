public extension Promise
{
    func onSuccess<Success, NextSuccess>(
        _ nextPromise: @escaping (Success) throws -> ResultPromise<NextSuccess>
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Error>
    {
        then
        {
            switch $0
            {
            case .success(let successValue):
                do { return try nextPromise(successValue) }
                catch { return .fulfilling(.failure(error)) }
            case .failure(let error):
                return .fulfilling(.failure(error))
            }
        }
    }
    
    func mapSuccess<Success, NextSuccess>(
        _ handleSuccess: @escaping (Success) throws -> NextSuccess
    )
        -> ResultPromise<NextSuccess>
        where Value == Result<Success, Error>
    {
        map
        {
            switch $0
            {
            case .success(let successValue):
                do { return .success(try handleSuccess(successValue)) }
                catch { return .failure(error) }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    @discardableResult
    func observedSuccess<Success>(
        _ handleSuccess: @escaping (Success) throws -> Void,
        failure handleFailure: @escaping (Error) -> Void
    )
        -> FreeObserver
        where Value == Result<Success, Error>
    {
        observedOnce
        {
            switch $0
            {
            case .success(let successValue):
                do { try handleSuccess(successValue) }
                catch { handleFailure(error) }
            case .failure(let error):
                handleFailure(error)
            }
        }
    }
    
    @discardableResult
    func observedFailure<Success>(
        _ handleFailure: @escaping (Error) -> Void
    )
        -> FreeObserver
        where Value == Result<Success, Error>
    {
        observedOnce
        {
            if case .failure(let error) = $0
            {
                handleFailure(error)
            }
        }
    }
    
    func fulfill<Success>(_ error: Error)
        where Value == Result<Success, Error>
    {
        fulfill(.failure(error))
    }
    
    func fulfill<Success>(_ resultValue: Success)
        where Value == Result<Success, Error>
    {
        fulfill(.success(resultValue))
    }
    
    static func fulfilling<Success>(_ error: Error) -> Promise
        where Value == Result<Success, Error>
    {
        fulfilling(.failure(error))
    }
    
    static func fulfilling<Success>(_ resultValue: Success) -> Promise
        where Value == Result<Success, Error>
    {
        fulfilling(.success(resultValue))
    }
}

public typealias ResultPromise<Value> = Promise<Result<Value, Error>>
