public extension Observable
{
    public func new<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<Self, UpdateType>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return map(prefilter: { $0 != nil }) { $0 ?? defaultUpdate }
    }
    
    public func map<MappedUpdate>(prefilter: @escaping UpdateFilter = { _ in true },
                                  mapping: @escaping (UpdateType) -> MappedUpdate)
        -> Mapping<Self, MappedUpdate>
    {
        return Mapping(self, prefilter: prefilter, mapping: mapping)
    }
}

public class Mapping<SourceObservable: Observable, MappedUpdate>: Observable
{
    fileprivate init(_ observable: SourceObservable,
                     prefilter: @escaping SourceObservable.UpdateFilter = { _ in true },
                     mapping: @escaping Mapping)
    {
        self.observable = observable
        self.prefilter = prefilter
        self.map = mapping
        
        latestMappedUpdate = map(observable.latestUpdate)
        
        startObserving(observable)
    }
    
    private func startObserving(_ observable: SourceObservable)
    {
        observable.add(self, filter: prefilter)
        {
            [weak self] update in
            
            self?.receivedPrefiltered(update)
        }
    }
    
    private func receivedPrefiltered(_ update: SourceObservable.UpdateType)
    {
        latestMappedUpdate = map(update)
        send(latestMappedUpdate)
    }
    
    deinit
    {
        if let observable = observable
        {
            ObservationService.remove(self, from: observable)
        }
    }
    
    public var latestUpdate: MappedUpdate
    {
        if let latestOriginalUpdate = observable?.latestUpdate,
            prefilter(latestOriginalUpdate)
        {
            latestMappedUpdate = map(latestOriginalUpdate)
        }
        
        return latestMappedUpdate
    }
    
    private var latestMappedUpdate: MappedUpdate
    
    private let prefilter: SourceObservable.UpdateFilter

    public var hasObservable: Bool { return observable != nil }
    private weak var observable: SourceObservable?
    
    private let map: Mapping
    typealias Mapping = (SourceObservable.UpdateType) -> MappedUpdate
}
