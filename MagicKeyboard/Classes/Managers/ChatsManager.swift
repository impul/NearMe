//
//  ChatsManager.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import MultipeerConnectivity
import Foundation

protocol ConversationDelegate {
    func didReceiveMessage(_ newMessage:Message)
}

protocol ChatObservingProtocol {
    func chatProviderListUpdated()
}

typealias Update = (_ status:Bool) -> Void

protocol ChatProviderProtocol {
    var name: String { get }
    var chats: [Chat] { get }
    var conversationDelegate:ConversationDelegate? { set get }
    func request(_ updated: @escaping Update)
    func startConversation(_ withChatId:Int)
    func closeConnection()
    func sendMessage(_ text:String,id:Int)
}

class ChatsManager {
    
    var chatProviders: [ChatProviderProtocol] = [NearChatProvider()]
    
    var delegate: ChatObservingProtocol? {
        didSet{
            requestChats()
        }
    }
    
    func closeConnections() {
        chatProviders.forEach { $0.closeConnection() }
    }
    
    func requestChats() {
        chatProviders.forEach { (provider) in
            provider.request({ [weak self] (success) in
                if !success { return }
                guard let strongSelf = self else { return }
                strongSelf.delegate?.chatProviderListUpdated()
            })
        }
    }
    
}
