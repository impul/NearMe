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
        ChatsManager.sharedManager.messageDelegate = self
    }
    
    
    //MARK: - Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.inputTextField.becomeFirstResponder()
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
        if string == "\n" { textField.text = "" }
        return true
    }
}

extension ConversationViewController: ConversationDelegate {
    
    func didReceiveMessage(_ newMessage:Message) {
        lastMessage = newMessage
        guard newMessage.message != "" else {
            dropLast()
            return
        }
        let color = newMessage.color.RGBColor
        let attributes = [NSForegroundColorAttributeName:color,
                          NSFontAttributeName:Defaults.textFont] as [String : Any]
        let attributedText = NSAttributedString(string: newMessage.message, attributes: attributes)
        guard let oldText = outputTextView.attributedText else {
            updateTextView(attributedText)
            return
        }
        let newString = NSMutableAttributedString(attributedString: oldText)
        newString.append(attributedText)
        updateTextView(newString)
    }
    
    func updateTextView(_ text:NSAttributedString) {
        OperationQueue.main.addOperation {
            self.outputTextView.attributedText = text
        }
    }
    
    func dropLast() {
        OperationQueue.main.addOperation {
            _ = self.outputTextView.text.removeLast()
        }
    }
}
