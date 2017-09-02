//
//  Message.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 27.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct Message:Codable {
    
    var userName:String
    var message:String
    var color:UInt32
    var messageId:Int
    
    static let firstMessage = Message(userName: "", message: "", color: 0, messageId: -1)
}
