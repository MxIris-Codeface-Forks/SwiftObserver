import SwiftyToolz

class Connection: ConnectionInterface
{
    init(messenger: MessengerInterface, receiver: ReceiverInterface)
    {
        self.receiver = receiver
        self.receiverKey = receiver.key
        self.messenger = messenger
        self.messengerKey = messenger.key
    }
    
    deinit { close() }
    
    func close()
    {
        receiver?.remove(self)
        messenger?.remove(self)
    }
    
    let receiverKey: ReceiverKey
    weak var receiver: ReceiverInterface?
    
    let messengerKey: MessengerKey
    private weak var messenger: MessengerInterface?
}

// MARK: - Receiver Interface

extension ReceiverInterface
{
    var key: ReceiverKey { ReceiverKey(self) }
}

protocol ReceiverInterface: class
{
    func remove(_ connection: ConnectionInterface)
}

// MARK: - Messenger Interface

extension MessengerInterface
{
    var key: MessengerKey { MessengerKey(self) }
}

protocol MessengerInterface: class
{
    func remove(_ connection: ConnectionInterface)
}

// MARK: - Connection Interface

protocol ConnectionInterface: class
{
    var receiverKey: ReceiverKey { get }
    var messengerKey: MessengerKey { get }
}

typealias ReceiverKey = ObjectIdentifier
typealias MessengerKey = ObjectIdentifier
