extension Var: CustomStringConvertible
    where Value: CustomStringConvertible
{
    public var description: String
    {
        value.description
    }
}

extension Var: CustomDebugStringConvertible
    where Value: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        value.debugDescription
    }
}

extension Var:
    TextOutputStream,
    Sequence,
    Collection,
    BidirectionalCollection
    where Value: StringValue
{
    // BidirectionalCollection
    
    public func index(before i: String.Index) -> String.Index
    {
        string.index(before: i)
    }
    
    // Collection
    
    public func index(after i: String.Index) -> String.Index
    {
        string.index(after: i)
    }
    
    public subscript(position: String.Index) -> String.Element
    {
        string[position]
    }
    
    public var startIndex: String.Index
    {
        string.startIndex
    }
    
    public var endIndex: String.Index
    {
        string.endIndex
    }
    
    public var indices: String.Indices
    {
        string.indices
    }
    
    public typealias Index = String.Index
    public typealias SubSequence = String.SubSequence
    public typealias Indices = String.Indices
    
    // Sequence
    
    public func makeIterator() -> String.Iterator
    {
        string.makeIterator()
    }
    
    public typealias Element = String.Element
    public typealias Iterator = String.Iterator
    
    // TextOutputStream
    
    public func write(_ str: String)
    {
        string.write(str)
    }
}
