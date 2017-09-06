//
//  MainViewController.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SVProgressHUD

fileprivate struct Defaults {
    static var tableViewCell = "chatCell"
}

class ListChatsViewController: UITableViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var colorButton: UIButton!
    
    //MARK: - Lifecicle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateColor()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Defaults.tableViewCell )
        ChatsManager.sharedManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ChatsManager.sharedManager.closeConnections()
    }
    
    //MARK: - Actions
    
    @IBAction func changeColorAction(_ sender: UIButton) {
        sender.backgroundColor = .random
        let userDefaults = UserDefaults.standard
        userDefaults.setColor(color: sender.backgroundColor, forKey: Store.defaultColor.rawValue)
        userDefaults.synchronize()
    }
    
    //MARK: - Private 
    
    func updateColor() {
        let userDefaults = UserDefaults.standard
        guard let color = userDefaults.color(forKey: Store.defaultColor.rawValue) else {
            colorButton.backgroundColor = .random
            return
        }
        colorButton.backgroundColor = color
    }
}

//MARK: - UITableViewDataSource

extension ListChatsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ChatsManager.sharedManager.chatProviders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatsManager.sharedManager.chatProviders[section].chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = ChatsManager.sharedManager.chatProviders[indexPath.section].chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.tableViewCell, for: indexPath)
        cell.textLabel?.text = chat.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ChatsManager.sharedManager.chatProviders[section].name
    }
}

//MARK: - UITableViewDelegate


extension ListChatsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentChatsProvider = ChatsManager.sharedManager.chatProviders[indexPath.section]
        let currentChat = currentChatsProvider.chats[indexPath.row]
        if currentChat.id == ChatsManager.sharedManager.currentChatId {
            conversationStarted(onMessageProvider: currentChatsProvider, chat: currentChat)
            return
        }
        ChatsManager.sharedManager.startChat(inChatProvider: currentChatsProvider, at: currentChat)
    }

}

//MARK: - ChatObservingProtocol

extension ListChatsViewController: ChatObservingProtocol {
    
    func chatProviderListUpdated() {
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
        }
    }
    
    func conversationStarted(onMessageProvider: ChatProviderProtocol,chat: Chat) {
        OperationQueue.main.addOperation {
            let controller = ConversationViewController.instatiate()
            controller.setup(messageProvider: onMessageProvider, chat: chat)
            self.navigationController?.pushViewController(controller, animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
    func conversationConnecting() {
        SVProgressHUD.show(withStatus: "Connecting...")
    }
    
    func conversetionFailed(withInfo: String) {
        SVProgressHUD.showError(withStatus: withInfo)
    }
    
}
