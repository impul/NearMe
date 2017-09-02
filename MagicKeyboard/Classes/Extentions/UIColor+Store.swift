//
//  UIColor+Store.swift
//  MagicKeyboard
//
//  Created by Pavlo Boiko on 26.08.17.
//  Copyright © 2017 Pavlo Boiko. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    func color(forKey: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: forKey) {
            color = NSKeyedUnarchiver.unarchiveObject(with:colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
    
}

extension UInt32 {
    
    var RGBColor: UIColor {
        return UIColor(red: CGFloat((self >> 16) & 0xFF), green: CGFloat((self >> 8) & 0xFF), blue: CGFloat(self & 0xFF), alpha: 1.0)
    }
    
}

extension UIColor {
    
    var colorHEX:UInt32 {
        guard let components = self.cgColor.components else { return 0 }
        return UInt32(components[0] * 255.0) << 16 + UInt32(components[1] * 255.0) << 8 + UInt32(components[2] * 255.0)
    }
    
}
