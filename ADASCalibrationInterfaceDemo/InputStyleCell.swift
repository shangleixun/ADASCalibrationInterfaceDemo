//
//  InputStyleCell.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/15.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

typealias UIInputViewInputEventHandler = (UIView?, Bool?) -> Void
typealias MoveToNextField = (UIView?) -> Void

extension Notification.Name {
    static let UITextFieldsResignResponder = Notification.Name(rawValue: "UITextFieldsResignResponder")
}

class InputStyleModel: NSObject {
    
    public var key: String!
    public var title: String?
    public var value: String?
    public var unit: String!
    public var canInput: Bool!
    
    init(key: String, title: String) {
        super.init()
        self.key = key
        self.title = title
    }
    
    override class func description() -> String {
        return ""
    }
}

class InputStyleCell: UITableViewCell, UITextFieldDelegate {
    
    var inputTitle: UILabel!
    var inputField: UITextField!
    var inputText: String?
    public var indexPath: IndexPath?
    private var model: InputStyleModel?
    var inputHandler: UIInputViewInputEventHandler?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addCustomViews()
        NotificationCenter.default.addObserver(self, selector: #selector(self.resignResponder), name: .UITextFieldsResignResponder, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setModel(_ model: InputStyleModel!) {
        
        self.model = model
        inputTitle.text = model.title
        inputField.text = model.value
        inputText = model.value
        inputField.isUserInteractionEnabled = model.canInput
        
        let rightView = inputField.rightView as? UILabel
        rightView?.text = model.unit
    }
    
    func addCustomViews() {
        inputTitle = UILabel()
        inputTitle.font = UIFont(name: "ArialRoundedMTBold", size: 13)
        inputTitle.numberOfLines = 0
        inputTitle.layer.cornerRadius = 6.0
        
        inputField = UITextField()
        inputField.borderStyle = .roundedRect
        inputField.font = UIFont(name: "ArialRoundedMTBold", size: 16)
        inputField.keyboardType = .decimalPad
        inputField.delegate = self
        
        let rightView = UILabel()
        rightView.frame = CGRect(x: 0, y: 0, width: 10, height: 40)
        rightView.font = UIFont(name: "ArialRoundedMTBold", size: 17)
        
        inputField.rightView = rightView
        inputField.rightViewMode = .always
        
        inputField.addTarget(self, action: #selector(self.textFieldTextDidChange(_:)), for: .editingChanged)
        
        self.contentView.addSubview(inputTitle)
        self.contentView.addSubview(inputField)
        
        let padding = 8.0
        inputTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(padding)
            make.left.equalToSuperview().offset(2 * padding)
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-padding)
        }
        
        inputField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(padding)
            make.left.equalTo(inputTitle.snp.right).offset(padding/2.0)
            make.right.equalToSuperview().offset(-2*padding)
            make.bottom.equalToSuperview().offset(-padding)
        }
        
    }
    
    @objc func textFieldTextDidChange(_ sender: UITextField) {
        inputText = sender.text
        self.inputHandler?(self, false)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.inputHandler?(self, true)
        return true
    }
    
    @objc func resignResponder() {
        inputField.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

}
