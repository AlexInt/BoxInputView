//
//  BoxTextView.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

class BoxTextView: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
