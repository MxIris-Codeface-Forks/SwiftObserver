public extension Observable
{
    func unwrap<Wrapped>(_ defaultMessage: Wrapped) -> Mapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Mapper(self) { $0 ?? defaultMessage }
    }
}
