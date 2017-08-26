//
//  MainViewController.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var colorButton: UIButton!
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        guard let color = userDefaults.color(forKey: Store.defaultColor.rawValue) else {
            colorButton.backgroundColor = .random
            return
        }
        colorButton.backgroundColor = color
    }
    
    //MARK: - Actions
    
    @IBAction func changeColorAction(_ sender: UIButton) {
        sender.backgroundColor = .random
        let userDefaults = UserDefaults.standard
        userDefaults.setColor(color: sender.backgroundColor, forKey: Store.defaultColor.rawValue)
        userDefaults.synchronize()
    }
    
}
