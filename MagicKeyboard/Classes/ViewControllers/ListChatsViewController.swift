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
    
    private var сhatsManager = ChatsManager()
    var chatProviders:[ChatProviderProtocol] = [] {
        didSet{
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var colorButton: UIButton!
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateColor()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Defaults.tableViewCell )
        сhatsManager.delegate = self
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
        return chatProviders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatProviders[section].chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chatProviders[indexPath.section].chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.tableViewCell, for: indexPath)
        cell.textLabel?.text = chat.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return chatProviders[section].name
    }
    
}

extension ListChatsViewController: ChatObservingProtocol {
    func chatProviderListUpdated(_ chatsProviders:[ChatProviderProtocol]) {
        self.chatProviders = chatsProviders
    }
}
