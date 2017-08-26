//
//  ChatsManager.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import MultipeerConnectivity
import Foundation

protocol ChatObservingProtocol {
    func chatProviderListUpdated(_ chatsProviders:[ChatProviderProtocol])
}

protocol ChatProviderProtocol {
    var name:String { get }
    var chats:[Chat] { get }
    func updated(_:(_ status:Bool) -> Void)
}

class ChatsManager {
    
    private var chatProviders:[ChatProviderProtocol] = []
    
    
    var delegate:ChatObservingProtocol? {
        didSet{
            requestChats()
        }
    }
    
    func requestChats() {
        chatProviders.forEach { (provider) in
            provider.updated({ (success) in
                if !success { return }
                delegate?.chatProviderListUpdated(chatProviders)
            })
        }
    }
    
}
