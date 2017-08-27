//
//  ProviderAdvertiser.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 27.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias Invitation = (Bool, MCSession?) -> Void

struct ProviderAdvertiser {
    var chat:Chat
    var invitation:Invitation
}
