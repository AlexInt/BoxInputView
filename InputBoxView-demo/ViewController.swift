//
//  ViewController.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

class ViewController: UIViewController {

    lazy var cellProperty: BoxInputCellProperty = {
        var cellProperty = BoxInputCellProperty()
        cellProperty.showline = true
        cellProperty.cornerRadius = 0;
        cellProperty.borderWidth = 0;
        cellProperty.cellCursorColor = UIColor.red;
        cellProperty.cellCursorWidth = 1;
        cellProperty.cellCursorHeight = 20;
        cellProperty.cellBorderColorNormal = UIColor.red;
        cellProperty.cellFont = UIFont.systemFont(ofSize: 20, weight: .regular)
        cellProperty.cellTextColor = UIColor.black;
        cellProperty.cellBgColorNormal = .white
        cellProperty.cellBgColorSelected = .white
//        cellProperty.ifShowSecurity =  true
        cellProperty.customLineViewBlock = {
            let line = LineView()
            line.underlineColorNormal = UIColor.red
            line.underlineColorSelected = UIColor.red
            line.underlineColorFilled = UIColor.red
            line.lineView.backgroundColor = UIColor.red
            line.lineView.layer.shadowOpacity = 0
            line.customConstraint = true
            if let superView = line.lineView.superview {
                NSLayoutConstraint.activate([
                    line.lineView.heightAnchor.constraint(equalToConstant: 1),
                    line.lineView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                    line.lineView.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
                    line.lineView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
                ])
            }
            
            return line
        }
        return cellProperty
    }()
    
    lazy var boxView: BoxInputView = {
        let boxView = BoxInputView(customCellProperty: cellProperty, codeLength: 6)
        boxView.loadAndPrepareView(with: true)
        boxView.inputType = .regex
        boxView.keyBoardType = .numberPad
        boxView.customInputRegex = "[^0-9]"
        boxView.textContentType = .oneTimeCode
        return boxView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        view.addSubview(boxView)
        boxView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            boxView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            boxView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boxView.heightAnchor.constraint(equalToConstant: 60),
            boxView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-80)
        ])
        boxView.textDidChangeblock = {(text,_) in

            print(text)
        }
    }


}

