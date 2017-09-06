//
//  NearChatProvider.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import Foundation
import MultipeerConnectivity

fileprivate struct Defaults {
    static var nameKey = "name"
    static var idKey = "id"
    static var deviceInfo = [Defaults.nameKey:UIDevice.current.name,Defaults.idKey:UIDevice.current.identifierForVendor?.uuidString ?? ""]
    static var providerName = "Devices near"
}

class NearChatProvider:NSObject {
    
    var foundedPears:[ProviderAdvertiser] = [] {
        didSet{
            complition?()
        }
    }
    var complition:Update?
    var connectingStatus:((_ newStatus:ConversationStatus) -> Void)?
    
    private let advertiser : MCNearbyServiceAdvertiser
    private let browser : MCNearbyServiceBrowser
    
    private let myPearId = MCPeerID(displayName: UIDevice.current.name)
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPearId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPearId, discoveryInfo: Defaults.deviceInfo, serviceType: Configuratons.AppIdentifire)
        browser = MCNearbyServiceBrowser(peer: myPearId, serviceType: Configuratons.AppIdentifire)
        super.init()
        
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
}

extension NearChatProvider : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        complition?()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void){
        print("Invite from pear")
        guard advertiser.serviceType == Configuratons.AppIdentifire else {
            invitationHandler(false,nil)
            return
        }
        guard context != nil,
            let info = NSKeyedUnarchiver.unarchiveObject(with: context!) as? [String : String],
            let name = info[Defaults.nameKey],
            let id = info[Defaults.idKey] else{
            complition?()
            return
        }
        let exist = foundedPears.contains { $0.chat.title == name }
        if !exist {
            let chat = Chat(title: name,pearId:id)
            foundedPears.append(ProviderAdvertiser(chat:chat,invitation:invitationHandler))
        }
    }
    
}

extension NearChatProvider : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        complition?()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let context = NSKeyedArchiver.archivedData(withRootObject: Defaults.deviceInfo)
        browser.invitePeer(peerID, to: self.session, withContext: context, timeout: TimeInterval(Int32.max))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost pear")
        let pear = foundedPears.index { $0.chat.title == peerID.displayName }
        guard pear != nil else { return }
        foundedPears.remove(at: pear!)
        complition?()
    }
    
}

extension NearChatProvider : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        complition?()
        guard let newStatus = ConversationStatus(rawValue: state.rawValue) else {
            connectingStatus?(.notConnected)
            return
        }
        connectingStatus?(newStatus)
        var current = self.foundedPears.first { $0.chat.title == peerID.displayName }
        guard current != nil else { return }
        current?.chat.users = session.connectedPeers.map { return User(name:$0.displayName)}
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(Message.self, from: data) else { return }
        ChatsManager.sharedManager.messageDelegate?.didReceiveMessage(message)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
    
}

extension NearChatProvider: ChatProviderProtocol {
    

    var name: String { return Defaults.providerName }
    var chats: [Chat] { return foundedPears.map { $0.chat } }
    func request(_ updated: @escaping Update) {
        complition = updated
    }
    
    func closeConnection() {
        foundedPears.forEach { $0.invitation(false,session) }
    }
    
    func startConversation(_ withChatId:String, status:@escaping (_ newStatus:ConversationStatus) -> Void) {
        connectingStatus = status
        let chat = foundedPears.first { $0.chat.id == withChatId }
        chat?.invitation(true,session)
    }
    
    func sendMessage(_ text: String, id: Int) {
        let color =  UserDefaults.standard.color(forKey: Store.defaultColor.rawValue) ?? .random
        let message = Message(userName: UIDevice.current.name, message: text, color:color.colorHEX, messageId: id)
        guard let archived = try? JSONEncoder().encode(message) else { return }
        
        if session.connectedPeers.count > 0 {
            do {
                try session.send(archived, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
}

