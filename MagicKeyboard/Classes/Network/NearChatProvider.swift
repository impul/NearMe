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
    static var deviceInfo = [Defaults.nameKey:UIDevice.current.name]
}

class NearChatProvider:NSObject {
    
    var foundedChats:[Chat] = []
    var complition:Update?
    
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
        complition?(false)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void){
        guard advertiser.serviceType == Configuratons.AppIdentifire else {
            invitationHandler(false,nil)
            return
        }
        guard context != nil,
            let info = NSKeyedUnarchiver.unarchiveObject(with: context!) as? [String : String],
            let name = info[Defaults.nameKey] else{
            complition?(false)
            return
        }
        foundedChats = [Chat(title: name)]
        complition?(true)
    }
    
}

extension NearChatProvider : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        complition?(false)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let context = NSKeyedArchiver.archivedData(withRootObject: Defaults.deviceInfo)
        browser.invitePeer(peerID, to: self.session, withContext: context, timeout: TimeInterval(Int32.max))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        complition?(true)
    }
    
}

extension NearChatProvider : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.foundedChats[0].users = session.connectedPeers.map { return User(name:$0.displayName)}
        complition?(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
    
}

extension NearChatProvider: ChatProviderProtocol {
    var name: String { return "Devices near" }
    var chats: [Chat] { return foundedChats }
    
    func request(_ updated: @escaping Update) {
        complition = updated
    }
}
