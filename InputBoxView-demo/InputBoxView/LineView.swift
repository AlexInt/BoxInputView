//
//  LineView.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

typealias LineViewSelectChangeBlock = (LineView, Bool)->Void
let sepLineViewHeight: CGFloat = 4

class LineView: UIView {
    ///  下划线颜色 状态：未选中状态，且没有填充文字时
    public var underlineColorNormal = UIColor(red: 49/255.0, green: 51/255.0, blue: 64/255.0, alpha: 1.0)
    
    /// 下划线颜色 状态：选中状态时
    public var underlineColorSelected = UIColor(red: 49/255.0, green: 51/255.0, blue: 64/255.0, alpha: 1.0)
    
    ///  下划线颜色 状态：未选中状态，且有填充文字时
    public var underlineColorFilled = UIColor(red: 49/255.0, green: 51/255.0, blue: 64/255.0, alpha: 1.0)
    
    public var lineView: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.cornerRadius = sepLineViewHeight / 2.0;
        return line
    }()
    
    public var selected: Bool = false  {
        didSet {
            selectChangeBlock?(self,selected)
        }
    }

    /// 选择状态改变时回调
    public var selectChangeBlock: LineViewSelectChangeBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        createUI()
    }
    
    private func createUI() {
        lineView.backgroundColor = underlineColorNormal
        addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: sepLineViewHeight),
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        lineView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor;
        lineView.layer.shadowOpacity = 1;
        lineView.layer.shadowOffset = CGSize(width: 0, height: 2);
        lineView.layer.shadowRadius = 4;
    }
    
}
