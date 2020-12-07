//
//  BoxInputCellProperty.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

enum BoxSecurityType {
    case symbol       //符号类型，根据securitySymbol，originValue的内容来显示
    case customView  // 自定义View类型，可以自定义密文状态下的图片，View
}

typealias CustomSecurityViewBlock = ()->UIView
typealias CustomLineViewBlock = ()->LineView
typealias ConfigCellShadowBlock = (CALayer)->Void

struct BoxInputCellProperty {
    
    /// cell边框宽度
    public var borderWidth: CGFloat = 0.5
    
    /// cell边框颜色 状态：未选中状态时
    public var cellBorderColorNormal = UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
    
    /// cell边框颜色 状态：选中状态时
    public var cellBorderColorSelected = UIColor(red: 255/255.0, green: 70/255.0, blue: 62/255.0, alpha: 1.0)
    
    ///  cell边框颜色 状态：无填充文字，未选中状态时
    public var cellBorderColorFilled: UIColor?
    
    ///  cell背景颜色 状态：无填充文字，未选中状态时
    public var cellBgColorNormal = UIColor.white
    
    /// cell背景颜色 状态：选中状态时
    public var cellBgColorSelected = UIColor.white
    
    ///  cell背景颜  状态：填充文字后，未选中状态时
    public var cellBgColorFilled: UIColor?
    
    /// 光标颜色
    public var cellCursorColor = UIColor(red: 255/255.0, green: 70/255.0, blue: 62/255.0, alpha: 1.0)
    
    /// 光标宽度
    public var cellCursorWidth: CGFloat = 2.0
    
    /// 光标高度
    public var cellCursorHeight: CGFloat = 32.0
    
    /// 圆角
    public var cornerRadius: CGFloat = 4.0
    
    /// 显示下划线
    public var showline = false
    
    /// 字体/字号
    public var cellFont = UIFont.systemFont(ofSize: 20)
    
    /// 字体颜色
    public var cellTextColor = UIColor.black
    
    /// 是否密文显示
    public var ifShowSecurity = false
    
    /// 密文符号 说明：只有ifShowSecurity==true时，有效
    public var securitySymbol = "*"
    
    /*
     保存当前显示的字符
     若想一次性修改所有输入值，请使用 CRBoxInputView中的'reloadInputString'方法
     禁止修改该值！！！（除非你知道该怎么使用它。）
     */
    public var originValue = ""
    
    /// 密文类型
    public var securityType: BoxSecurityType?
    
    ///  占位符默认填充值 禁止修改该值！！！（除非你知道该怎么使用它。）
    public var cellPlaceholderText: String?
    
    /// 占位符字体颜色
    public var cellPlaceholderTextColor = UIColor(red: 114/255.0, green: 126/255.0, blue: 124/255.0, alpha: 0.3)
    
    /// 占位符字体/字号
    public var cellPlaceholderFont = UIFont.systemFont(ofSize: 20)
    
    /// 自定义密文View回调
    public var customSecurityViewBlock: CustomSecurityViewBlock = {
        let v = UIView()
        v.backgroundColor = .clear
        let circleView = UIView()
        circleView.backgroundColor = .black
        circleView.layer.cornerRadius = 4
        circleView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(circleView)
        let circleViewWidth: CGFloat = 20
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: circleViewWidth),
            circleView.heightAnchor.constraint(equalToConstant: circleViewWidth),
            circleView.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }
    
    /// 自定义下划线回调
    public var customLineViewBlock: CustomLineViewBlock = { LineView() }
    
    /// 自定义阴影回调
    public var configCellShadowBlock: ConfigCellShadowBlock?
    
    /// for test
    public var index = 0
}
