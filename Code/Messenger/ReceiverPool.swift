 import SwiftyToolz
 
 class ReceiverPool<Message>
 {
    // MARK: - Forward Messages to Receivers
    
    func receive(_ message: Message, from author: AnyAuthor)
    {
        messagesFromAuthors.append((message, author))
        
        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            for (receiverKey, receiverReference) in receivers
            {
                guard receiverReference.receiver != nil else
                {
                    log(warning: "Tried so send message to dead receiver. Will remove receiver.")
                    receivers[receiverKey] = nil
                    continue
                }
                
                receiverReference.receive(message, author)
            }
            
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    
    // MARK: - Manage Receivers
    
    func contains(_ receiver: AnyReceiver) -> Bool
    {
        receivers[key(receiver)]?.receiver === receiver
    }
    
    func add(_ receiver: AnyReceiver, receive: @escaping (Message, AnyAuthor) -> Void)
    {
        receivers[key(receiver)] = ReceiverReference(receiver: receiver, receive: receive)
    }
    
    func remove(_ receiver: AnyReceiver)
    {
        receivers[key(receiver)] = nil
    }
    
    // MARK: - Receivers
    
    var isEmpty: Bool { receivers.isEmpty }
    var keys: Set<ReceiverKey> { Set(receivers.keys) }
    
    private var receivers = [ReceiverKey : ReceiverReference]()
    
    private class ReceiverReference
    {
        init(receiver: AnyReceiver, receive: @escaping (Message, AnyAuthor) -> Void)
        {
            self.receiver = receiver
            self.receive = receive
        }
        
        weak var receiver: AnyReceiver?
        let receive: (Message, _ from: AnyAuthor) -> Void
    }
}

func key(_ receiver: AnyReceiver) -> ReceiverKey { ReceiverKey(receiver) }
typealias ReceiverKey = ObjectIdentifier
public typealias AnyReceiver = AnyObject
 
public typealias AnyAuthor = AnyObject
