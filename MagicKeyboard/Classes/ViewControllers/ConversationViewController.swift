//
//  ConversationViewController.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 27.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit

fileprivate struct Defaults {
    static let fontSize:CGFloat = 15
    static let textFont = UIFont(name: Configuratons.DefaultFontName, size: Defaults.fontSize) ??
                          UIFont.systemFont(ofSize: Defaults.fontSize)
}


class ConversationViewController: UIViewController {
    
    var lastMessage = Message.firstMessage
    var messageProvider:ChatProviderProtocol?
    var currentChat:Chat?
    
    //MARK: - Outlets
    
    @IBOutlet weak var keyboardHeaightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var inputTextField: UITextField!
    
    //MARK: - Initialization
    
    func setup(messageProvider:ChatProviderProtocol,chat:Chat) {
        self.messageProvider = messageProvider
        self.currentChat = chat
    }
    
    
    //MARK: - Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.inputTextField.becomeFirstResponder()
        guard let id = currentChat?.id else { return }
        messageProvider?.startConversation(id)
    }
    
    //MARK: - Privte
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeaightConstraint.constant = keyboardRectangle.height
        }
    }
    
}

extension ConversationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        messageProvider?.sendMessage(string,id: 0)
        return true
    }
    
}

extension ConversationViewController: ConversationDelegate {
    
    func didReceiveMessage(_ newMessage:Message) {
        if newMessage.messageId == lastMessage.messageId {
            self.outputTextView.text.append(newMessage.message)
        }
        lastMessage = newMessage
        let attributes = [NSForegroundColorAttributeName:newMessage.color,
                          NSFontAttributeName:Defaults.textFont] as? [String : Any]
        let attributedText = NSAttributedString(string: newMessage.message, attributes: attributes)
        guard let oldText = outputTextView.attributedText as? NSMutableAttributedString else {
            return
        }
        oldText.append(attributedText)
        outputTextView.attributedText = oldText
    }
}
