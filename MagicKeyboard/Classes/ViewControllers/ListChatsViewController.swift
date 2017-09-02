//
//  MainViewController.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit
import MultipeerConnectivity

fileprivate struct Defaults {
    static var tableViewCell = "chatCell"
}

class ListChatsViewController: UITableViewController {
    
    fileprivate var сhatsManager = ChatsManager()
    
    //MARK: - Outlets
    
    @IBOutlet weak var colorButton: UIButton!
    
    //MARK: - Lifecicle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateColor()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Defaults.tableViewCell )
        сhatsManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        сhatsManager.closeConnections()
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
        return сhatsManager.chatProviders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return сhatsManager.chatProviders[section].chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = сhatsManager.chatProviders[indexPath.section].chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.tableViewCell, for: indexPath)
        cell.textLabel?.text = chat.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return сhatsManager.chatProviders[section].name
    }
}

//MARK: - UITableViewDelegate


extension ListChatsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentChatsProvider = сhatsManager.chatProviders[indexPath.section]
        currentChatsProvider.startConversation(currentChatsProvider.chats[indexPath.row].id)
//        let controller = ConversationViewController.instatiate()
//        controller.setup(messageProvider: currentChatsProvider, chat: currentChatsProvider.chats[indexPath.row])
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - ChatObservingProtocol

extension ListChatsViewController: ChatObservingProtocol {
    func chatProviderListUpdated() {
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
        }
    }
}
