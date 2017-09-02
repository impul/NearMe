//
//  UIViewContoller+Instantiate.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 27.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit

public protocol UIInitializationProtocol:class {}
extension UIViewController: UIInitializationProtocol {}

public extension UIInitializationProtocol where Self: UIViewController {
    
    fileprivate static var defaultStoryboard: UIStoryboard {
        return UIStoryboard(name: Configuratons.StoryboardName, bundle: .main)
    }
    
    fileprivate static func identifire() -> String {
        let identifire = String(describing: self)
        return identifire
    }
    
    static func instatiate() -> Self {
         return defaultStoryboard.instantiateViewController(withIdentifier: identifire()) as! Self
    }

}

