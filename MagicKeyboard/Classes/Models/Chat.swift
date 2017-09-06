//
//  Chat.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import Foundation

struct Chat {
    var title:String
    var users:[User]
    var id:String
    
    init(title:String,pearId:String) {
        self.title = title
        self.users = []
        self.id = pearId
    }
}
