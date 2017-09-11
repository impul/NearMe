//
//  ChatsManager.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import MultipeerConnectivity
import Foundation

protocol ConversationDelegate:class {
    func didReceiveMessage(_ newMessage:Message)
}

protocol ChatObservingProtocol:class {
    func chatProviderListUpdated()
    func conversationStarted(onMessageProvider:ChatProviderProtocol,chat:Chat)
    func conversetionFailed(withInfo:String)
    func conversationConnecting()
}

enum ConversationStatus:Int {
    case notConnected
    case connecting
    case connected
}

typealias Update = () -> Void

protocol ChatProviderProtocol {
    var name: String { get }
    var chats: [Chat] { get }
    func request(_ updated: @escaping Update)
    func startConversation(_ withChatId:String
        , status:@escaping(_ newStatus:ConversationStatus) -> Void)
    func closeConnection()
    func sendMessage(_ text:String,id:Int)
}

class ChatsManager {
    
    static var sharedManager = ChatsManager()
    
    var chatProviders: [ChatProviderProtocol] = [NearChatProvider()]
    
    var currentChatId:String?
    weak var messageDelegate:ConversationDelegate?
    weak var delegate: ChatObservingProtocol? {
        didSet{
            requestChats()
        }
    }
    
    func closeConnections() {
        chatProviders.forEach { $0.closeConnection() }
    }
    
    func requestChats() {
        chatProviders.forEach { (provider) in
            provider.request({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.chatProviderListUpdated()
            })
        }
    }
    
    func startChat(inChatProvider chatProvider:ChatProviderProtocol, at chat:Chat) {
        chatProvider.startConversation(chat.id) { (status) in
            switch status {
            case .notConnected:
                self.delegate?.conversetionFailed(withInfo: "Not connected")
            case .connecting:
                self.delegate?.conversationConnecting()
            case .connected:
                self.currentChatId = chat.id
                self.delegate?.conversationStarted(onMessageProvider: chatProvider, chat: chat)
            }
        }
    }
    
}
