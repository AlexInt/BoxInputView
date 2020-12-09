//
//  BoxInputView.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/7.
//

import UIKit

enum TextEditStatus {
    case idle
    case beginEdit
    case endEdit
}

enum InputType {
    case number  //数字
    case normal  //普通（不作任何处理）
    case regex   //自定义正则（此时需要设置customInputRegex）
}


typealias TextDidChangeblock = (String,Bool)->Void
typealias TextEditStatusChangeblock = (TextEditStatus)->Void

class BoxInputView: UIView {
    enum BoxTextChangeType {
        case noChange
        case insert
        case delete
    }
    
    /// 是否需要光标
    var ifNeedCursor = true
    
    /// 验证码长度
    public private(set) var codeLength: Int {
        didSet {
            boxFlowLayout.itemNum = codeLength
        }
    }
    
    ///  是否开启密文模式
    /// 描述：你可以在任何时候修改该属性，并且已经存在的文字会自动刷新。
    public var ifNeedSecurity = false {
        didSet {
            if ifNeedSecurity {
                allSecurityOpen()
            } else {
                allSecurityClose()
            }
            DispatchQueue.main.async {
                self.reloadAllCell()
            }
        }
    }
    
    /// 显示密文的延时时间
    public var securityDelay = 0.3
    
    /// 键盘类型
    public var keyBoardType: UIKeyboardType = .numberPad {
        didSet {
            textView.keyboardType = keyBoardType
        }
    }
    
    /// 输入样式
    public var inputType: InputType = .number
    
    /// 自定义正则匹配输入内容
    public var customInputRegex = ""
    
    ///  textContentType
    /// 描述: 你可以设置为 'nil' 或者 'UITextContentTypeOneTimeCode' 来自动获取短信验证码
    public var textContentType: UITextContentType? {
        didSet {
            textView.textContentType = textContentType
        }
    }
    
    /// 占位字符填充值
    /// 说明：在对应的输入框没有内容时，会显示该值。
    public var placeholderText: String?
    
    ///  弹出键盘时，是否清空所有输入
    ///  只有在输入的字数等于codeLength时，生效
    public var ifClearAllInBeginEditing = false
    
    public var textDidChangeblock: TextDidChangeblock?
    public var textEditStatusChangeblock: TextEditStatusChangeblock?
    public lazy var boxFlowLayout: BoxFlowLayout = {
        let layout = BoxFlowLayout()
        layout.itemSize = CGSize(width: 42, height: 47)
        return layout
    }()
    
    private var customCellProperty: BoxInputCellProperty
    public var textValue: String {
        return textView.text ?? ""
    }

    public var inputAccessory: UIView? {
        didSet {
            textView.inputAccessoryView = inputAccessory
        }
    }
    
    public lazy var mainCollectionView: UICollectionView = {
        let list  = UICollectionView(frame: .zero, collectionViewLayout: boxFlowLayout)
        list.showsHorizontalScrollIndicator = false
        list.isScrollEnabled = false
        list.backgroundColor = .clear
        list.delegate = self
        list.dataSource = self
        list.layer.masksToBounds = true
        list.clipsToBounds = true
        list.register(BoxInputCell.self, forCellWithReuseIdentifier: BoxInputCell.BoxInputCellID)
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }()
    
    
    private var tapGR: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(beginEdit))
        return tap
    }()
    
    private lazy var textView: BoxTextView = {
        let tv = BoxTextView()
        tv.delegate = self;
        tv.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    private var cellPropertyArr: [BoxInputCellProperty] = []
    private var valueArr: [String] = []
    private var oldLength = 0
    private var ifNeedBeginEdit = false
    
    init(frame: CGRect = .zero, customCellProperty:BoxInputCellProperty, codeLength: Int = 4) {
        self.customCellProperty = customCellProperty
        self.codeLength = codeLength
        super.init(frame:.zero)
        initDefaultValue()
        addNotificationObserver()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        self.customCellProperty = BoxInputCellProperty()
        self.codeLength = 4
        super.init(coder: aDecoder)
        initDefaultValue()
        addNotificationObserver()
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame:frame, customCellProperty: BoxInputCellProperty(), codeLength: 4)
    }
    
    convenience init() {
        self.init(frame:.zero, customCellProperty: BoxInputCellProperty(), codeLength: 4)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: public methods
extension BoxInputView {
    /// 装载数据和准备界面
    /// - Parameter shoulBeginEdit: 自动开启编辑模式
    public func loadAndPrepareView(with shoulBeginEdit: Bool = true) {
        guard codeLength > 0 else {
            fatalError("请输入大于0的验证码位数")
        }
        generateCellPropertyArr()
        if !subviews.contains(mainCollectionView) {
            addSubview(mainCollectionView)
            NSLayoutConstraint.activate([
                mainCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
                mainCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                mainCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                mainCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        }
        
        if !subviews.contains(textView) {
            addSubview(textView)
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: self.topAnchor),
                textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                textView.widthAnchor.constraint(equalToConstant: 0),
                textView.heightAnchor.constraint(equalToConstant: 0)
            ])
        }
        
        if tapGR.view != self {
            self.addGestureRecognizer(tapGR)
        }
        if textView.text != customCellProperty.originValue {
            textView.text = customCellProperty.originValue
            textDidChange(textField: textView)
        }
        if shoulBeginEdit {
            self.beginEdit()
        }
        
    }
    
    /// 重载输入的数据（用来设置预设数据)
    /// - Parameter value: deault value
    public func reloadInputString(_ value: String) {
        if textView.text != value {
            textView.text = value
            baseTextDidChange(textView, manualInvoke: true)
        }
    }
    
    ///  清空输入
    /// - Parameter shouldBeginEdit: 自动开启编辑模式
    public func clearAll(with shouldBeginEdit: Bool = true) {
        oldLength = 0
        valueArr.removeAll()
        textView.text = ""
        allSecurityClose()
        reloadAllCell()
        triggerBlock()
        if shouldBeginEdit {
            beginEdit()
        }
    }
    
    /// 快速设置
    /// - Parameter securitySymbol: securitySymbol
    public func quickSet(securitySymbol: String) {
        var text = securitySymbol
        if securitySymbol.count != 1 {
            text = "*"
        }
        customCellProperty.securitySymbol = text
    }
    
    /// 你可以在继承的子类中调用父类方法
    public func initDefaultValue() {
        backgroundColor = .clear
    }
    
    /// 你可以在继承的子类中调用父类方法
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - IndexPath: IndexPath
    public func customCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: BoxInputCell.BoxInputCellID, for: indexPath) as! BoxInputCell
    }
    
    /// code Length 调整
    /// - Parameters:
    ///   - codeLength: codeLength
    ///   - beginEdit: beginEdit
    public func reset(codeLength: Int, beginEdit: Bool) {
        guard codeLength > 0 else {
            fatalError("请输入大于0的验证码位数")
        }
        self.codeLength = codeLength
        generateCellPropertyArr()
        clearAll(with: beginEdit)
    }
}

//MARK: private methods
extension BoxInputView {
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @objc private func applicationWillResignActive(_ notification: Notification) {
        
    }
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        reloadAllCell()
    }
    
    private func reloadAllCell() {
        mainCollectionView.reloadData()
        let focusIndx = valueArr.count
        if focusIndx == codeLength {
            mainCollectionView.scrollToItem(at: IndexPath(row: focusIndx - 1, section: 0), at: .right, animated: true)
        } else {
            mainCollectionView.scrollToItem(at: IndexPath(row: focusIndx, section: 0), at: .right, animated: true)
        }
    }
    
    @objc private func beginEdit() {
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }
    private func endEdit() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    @objc private func textDidChange(textField: UITextField) {
        baseTextDidChange(textField, manualInvoke: false)
    }
    
    private func generateCellPropertyArr() {
        cellPropertyArr.removeAll()
        let arr = (0...codeLength).compactMap{_ in self.customCellProperty }
        cellPropertyArr += arr
    }
    
    private func allSecurityClose() {
        let arr = cellPropertyArr
        cellPropertyArr.removeAll()
        for item in arr {
            if !item.ifShowSecurity {
                var mutItem = item
                mutItem .ifShowSecurity = true
                cellPropertyArr.append(mutItem)
            } else {
                cellPropertyArr.append(item)
            }
        }
    }
    
    private func allSecurityOpen() {
        let arr = cellPropertyArr
        cellPropertyArr.removeAll()
        for item in arr {
            if item.ifShowSecurity {
                var mutItem = item
                mutItem .ifShowSecurity = false
                cellPropertyArr.append(mutItem)
            } else {
                cellPropertyArr.append(item)
            }
        }
    }
    
    private func triggerBlock() {
        let isFinished = valueArr.count == codeLength ? true : false
        textDidChangeblock?(textView.text ?? "", isFinished)
    }
    
    /// textDidChange基操作
    /// - Parameters:
    ///   - textField: UITextField
    ///   - manualInvoke: 是否为手动调用
    private func baseTextDidChange(_ textField: UITextField, manualInvoke: Bool) {
        var verStr = textField.text ?? ""
        //有空格去掉空格
        verStr = verStr.replacingOccurrences(of: " ", with: "")
        verStr = filterInput(content: verStr)
        if verStr.count >= codeLength {
            verStr = (verStr as NSString).substring(to: codeLength)
            endEdit()
        }
        textField.text = verStr
        // 判断删除/增加
        var boxTextChangeType = BoxTextChangeType.noChange
        if verStr.count > oldLength {
            boxTextChangeType = .insert
        } else if (verStr.count < oldLength) {
            boxTextChangeType = .delete
        }
        // _valueArr
        switch boxTextChangeType {
        case .delete:
            setSecurityShow(false, index: valueArr.count - 1)
            valueArr.removeLast()
        case .insert:
            guard !verStr.isEmpty else {
                return
            }
            if valueArr.count > 0 {
                replaceValueArrToAsterisk(with: valueArr.count - 1, needEqualToCount: false)
            }
            valueArr.removeAll()
            valueArr.append(contentsOf: verStr.map{ String($0) })
            if ifNeedSecurity {
                if manualInvoke {
                    delaySecurityProcessAll()
                } else {
                    delaySecurityProcessLastOne()
                }
            }
        default:
            break
        }
        reloadAllCell()
        oldLength = verStr.count
        if case .noChange = boxTextChangeType {
            
        } else {
            triggerBlock()
        }
    }
    
    /// 过滤输入内容
    /// - Parameter inputStr: 输入内容
    /// - Returns: String
    private func filterInput(content inputStr: String) -> String {
        let mutableStr = NSMutableString(string: inputStr)
        switch inputType {
        case .number:
            if let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) {
                regex.replaceMatches(in: mutableStr, options: .reportProgress, range: NSRange(location: 0, length: mutableStr.length), withTemplate: "")
            }
        case .normal:
            break
        case .regex:
            
            if !customInputRegex.isEmpty {
                if let regex = try? NSRegularExpression(pattern: customInputRegex, options: .caseInsensitive) {
                    regex.replaceMatches(in: mutableStr, options: .reportProgress, range: NSRange(location: 0, length: mutableStr.length), withTemplate: "")
                }
            }
        }
        return mutableStr as String
    }
    
    private func setSecurityShow(_ isShow: Bool, index: Int) {
        guard index >= 0 else {
            fatalError("index必须大于等于0")
        }
        var cellProperty = cellPropertyArr[index]
        cellPropertyArr.remove(at: index)
        cellProperty.ifShowSecurity = isShow
        cellPropertyArr.insert(cellProperty, at: index)
    }
    
    ///  替换密文
    /// - Parameters:
    ///   - index: 索引
    ///   - needEqualToCount: 是否只替换最后一个
    private func replaceValueArrToAsterisk(with index: Int, needEqualToCount: Bool) {
        guard ifNeedSecurity else {
            return
        }
        guard !needEqualToCount || index == valueArr.count - 1 else {
            return
        }
        setSecurityShow(true, index: index)
    }
    
    /// 延时替换所有一个密文
    private func delaySecurityProcessAll() {
        for (index,_) in valueArr.enumerated() {
            replaceValueArrToAsterisk(with: index, needEqualToCount: false)
        }
        reloadAllCell()
    }
    
    /// 延时替换最后一个密文
    private func delaySecurityProcessLastOne() {
        delay(seconds: securityDelay) {
            if !self.valueArr.isEmpty {
                self.replaceValueArrToAsterisk(with: self.valueArr.count - 1, needEqualToCount: true)
                self.reloadAllCell()
            }
        }
    }
}


extension BoxInputView: UICollectionViewDelegate {
    
}
//MARK: UICollectionViewDataSource
extension BoxInputView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        codeLength
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customCollectionView(collectionView, cellForItemAt: indexPath)
        if let boxCell = cell as? BoxInputCell {
            boxCell.ifNeedCursor = ifNeedCursor
            var cellProperty = cellPropertyArr[indexPath.row]
            cellProperty.index = indexPath.row
            var currentPlaceholderStr = ""
            if let text = placeholderText, text.count > indexPath.row {
                currentPlaceholderStr = (text as NSString).substring(with: NSRange(location: indexPath.row, length: 1))
                cellProperty.cellPlaceholderText = currentPlaceholderStr
            }
            let focusIndex = valueArr.count
            if valueArr.count > 0, indexPath.row <= focusIndex - 1 {
                cellProperty.originValue = valueArr[indexPath.row]
            } else {
                cellProperty.originValue = ""
            }
            
            boxCell.boxInputCellProperty = cellProperty
            if ifNeedBeginEdit {
                cell.isSelected = indexPath.row == focusIndex ? true : false
            } else {
                cell.isSelected = false
            }
        }
        
        return cell
    }
}

//MARK: UITextFieldDelegate
extension BoxInputView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ifNeedBeginEdit = true
        if ifClearAllInBeginEditing && textValue.count == codeLength{
            clearAll()
        }
        textEditStatusChangeblock?(.beginEdit)
        reloadAllCell()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        ifNeedBeginEdit = false
        textEditStatusChangeblock?(.endEdit)
        reloadAllCell()
    }
}
