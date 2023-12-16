//
//  UIView+Extension.swift
//  FinalProject
//
//  Created by Nikethana N N on 12/15/23.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}
