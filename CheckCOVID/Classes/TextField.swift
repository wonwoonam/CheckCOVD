//
//  TextField.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/23.
//

import Foundation
import UIKit

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 30)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    
    
}
