import SwiftyToolz

extension Messenger: MessengerInterface {}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    // MARK: - Send Messages to Receivers
    
    internal func _send(_ message: Message, from author: AnyAuthor)
    {
        messagesFromAuthors.append((message, author))

        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            receivers.receive(message, from: author)
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    
    // MARK: - Manage Receivers
    
    internal func isConnected(to receiver: ReceiverInterface) -> Bool
    {
        receivers.contains(receiver)
    }
    
    internal func connect(_ receiver: ReceiverInterface,
                           receive: @escaping (Message) -> Void) -> Connection
    {
        connect(receiver) { message, _ in receive(message) }
    }
    
    internal func connect(_ receiver: ReceiverInterface,
                          receive: @escaping (Message, AnyAuthor) -> Void) -> Connection
    {
        receivers.add(receiver, receive: receive)
    }
    
    
    // MARK: - MessengerInterface
    
    internal func unregisterConnection(with receiverKey: ReceiverKey)
    {
        receivers.removeReceiver(with: receiverKey)
    }
    
    // MARK: - Receivers
    
    private lazy var receivers = ReceiverPool<Message>(messenger: self)
}
