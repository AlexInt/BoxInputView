//
//  BoxInputCell.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

let BoxCursoryAnimationKey = "BoxCursoryAnimationKey"

class BoxInputCell: UICollectionViewCell {
    static let BoxInputCellID = "BoxInputCellID"
    public lazy var cursorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public var ifNeedCursor = true
    
    public lazy var boxInputCellProperty = BoxInputCellProperty() {
        didSet{
            cursorView.backgroundColor = boxInputCellProperty.cellCursorColor
            NSLayoutConstraint.activate([
                cursorView.widthAnchor.constraint(equalToConstant: boxInputCellProperty.cellCursorWidth),
                cursorView.heightAnchor.constraint(equalToConstant: boxInputCellProperty.cellCursorHeight)
            ])
            layer.cornerRadius = boxInputCellProperty.cornerRadius;
            layer.borderWidth = boxInputCellProperty.borderWidth;
            valueLabelLoadData()
        }
    }
    
    private lazy var valueLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 38)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private lazy var opacityAnimation: CABasicAnimation = {
        let ani = CABasicAnimation(keyPath: "opacity")
        ani.fromValue = 1.0
        ani.toValue = 0.0
        ani.duration = 0.9
        ani.repeatCount = .greatestFiniteMagnitude
        ani.isRemovedOnCompletion = true
        ani.fillMode = .forwards
        ani.timingFunction = CAMediaTimingFunction(name: .easeIn)
        return ani
    }()
    private var customSecurityView: UIView?
    private var lineView: LineView?
    
    override var isSelected: Bool {
        didSet {
            observeCellSelected(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUIBase()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createUIBase()
    }
    
    
}

extension BoxInputCell {
    override func layoutSubviews() {
        if boxInputCellProperty.showline, lineView == nil {
            lineView = boxInputCellProperty.customLineViewBlock()
            contentView.addSubview(lineView!)
            lineView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lineView!.topAnchor.constraint(equalTo: contentView.topAnchor),
                lineView!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                lineView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                lineView!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }
        if let cb = boxInputCellProperty.configCellShadowBlock {
            cb(layer)
        }
        super.layoutSubviews()
    }
}


extension BoxInputCell {
    private func createUIBase() {
        isUserInteractionEnabled = true
        
        contentView.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(cursorView)
        NSLayoutConstraint.activate([
            cursorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cursorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    private func valueLabelLoadData() {
        valueLabel.isHidden = false
        hideCustomSecurityView()
        
        if !boxInputCellProperty.originValue.isEmpty {
            if boxInputCellProperty.ifShowSecurity {
                switch boxInputCellProperty.securityType {
                case .symbol:
                    valueLabel.text = boxInputCellProperty.securitySymbol
                case .customView:
                    valueLabel.isHidden = true
                    showCustomSecurityView()
                default:
                    break
                }
            } else {
                valueLabel.text = boxInputCellProperty.originValue
            }
            defaultTextConfig()
        } else {
            if let isEmpty = boxInputCellProperty.cellPlaceholderText?.isEmpty, !isEmpty {
                valueLabel.text = boxInputCellProperty.cellPlaceholderText
                placeholderTextConfig()
            } else {
                valueLabel.text = ""
                defaultTextConfig()
            }
        }
    }
    
    private func defaultTextConfig() {
        valueLabel.font = boxInputCellProperty.cellFont
        valueLabel.textColor = boxInputCellProperty.cellTextColor
    }
    private func placeholderTextConfig() {
        valueLabel.font = boxInputCellProperty.cellPlaceholderFont
        valueLabel.textColor = boxInputCellProperty.cellPlaceholderTextColor
    }
    
    private func hideCustomSecurityView() {
        self.customSecurityView?.alpha = 0
    }
    private func showCustomSecurityView() {
        if let customV = customSecurityView, customV.superview != nil {
            contentView.addSubview(customV)
            customV.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customV.topAnchor.constraint(equalTo: contentView.topAnchor),
                customV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                customV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                customV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            customV.alpha = 1.0
        }
    }
    private func observeCellSelected(_ selected: Bool) {
        cursorView.isHidden = !ifNeedCursor
        if selected {
            cursorView.isHidden = false
            cursorView.layer.add(opacityAnimation, forKey: BoxCursoryAnimationKey)
            
            layer.borderColor = boxInputCellProperty.cellBorderColorSelected.cgColor
            backgroundColor = boxInputCellProperty.cellBgColorSelected
        } else {
            if let isEmpty = valueLabel.text?.isEmpty, !isEmpty {
                if let color = boxInputCellProperty.cellBorderColorFilled {
                    boxInputCellProperty.cellBorderColorNormal = color
                }
                if let bgColor = boxInputCellProperty.cellBgColorFilled {
                    boxInputCellProperty.cellBgColorNormal = bgColor
                }
            }
            cursorView.isHidden = true
            cursorView.layer.removeAnimation(forKey: BoxCursoryAnimationKey)
            
            layer.borderColor = boxInputCellProperty.cellBorderColorNormal.cgColor
            backgroundColor = boxInputCellProperty.cellBgColorNormal
        }
        
        guard let lineV = lineView else { return }
        if !selected {
            if !boxInputCellProperty.originValue.isEmpty {
                lineV.lineView.backgroundColor = lineV.underlineColorFilled
            } else {
                lineV.lineView.backgroundColor = lineV.underlineColorNormal
            }
        } else {
            lineV.lineView.backgroundColor = lineV.underlineColorSelected
        }
        lineV.selected = selected
    }
}
