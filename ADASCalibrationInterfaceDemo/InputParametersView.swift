//
//  InputParametersView.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/15.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

public
enum IPVState: Int {
    case null
    case allEmpty
    case halfFilled
    case canSend
}

typealias UIFrameChanged = (CGRect) -> Void
typealias IPVTotalStateChanged = (IPVState) -> Void

class InputParametersView: UIView {
    
    var frameChangedBlock: UIFrameChanged?
    var stateChangedBlock: IPVTotalStateChanged?
    
    var dataSource = [InputStyleModel]()
    var tableView: UITableView!
    var selectedField: UITextField?
    var selectedIndexPath: IndexPath?
    var isSelectedFieldVisible: Bool?
    
    var sendButton: UIButton!
    
    let kInputCellIdentifier = "kInputCellIdentifier"
    
    // MARK:- Public methods
    
    public
    func updateModelBy(key: String, value: String) {
        
        var tIdx: Int?
        for (idx, model) in dataSource.enumerated() {
            if model.key == key {
                tIdx = idx
                break
            }
        }
        
        if let targetIdx = tIdx {
            dataSource[targetIdx].value = value
        }
    }
    
    public
    func edgeShow() {
        
        if isSelectedFieldVisible == true {
            if let field = selectedField,
                field.canBecomeFirstResponder == true {
                field.becomeFirstResponder()
            }
        } else {
            if let firstCell = tableView.visibleCells.first as? InputStyleCell {
                firstCell.inputField.becomeFirstResponder()
            }
        }
        
        let tPath = IndexPath(row: dataSource.count - 1, section: 0)
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView.reloadRows(at: [ tPath ], with: .none)
        }
        
        checkCanSendState()
    }
    
    public
    func edgeHide() {
        
        if let sIndex = selectedIndexPath {
            isSelectedFieldVisible = tableView.indexPathsForVisibleRows?.contains(sIndex)
        }
        
        NotificationCenter.default.post(name: .UITextFieldsResignResponder, object: nil)
    }
    
    // MARK:- Init
    
    override
    init(frame: CGRect) {
        super.init(frame: frame)
        addSubTableView()
    }
    
    required
    init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    func addSubTableView() {
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.orange
        tableView.register(InputStyleCell.self, forCellReuseIdentifier: kInputCellIdentifier)
        
        sendButton = UIButton(type: .custom)
        sendButton.frame = CGRect(x: 0, y: 0, width: 10, height: 60)
        sendButton.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 40)
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendButton.setTitleColor(UIColor.gray, for: .normal)
        
        tableView.tableFooterView = sendButton
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let keys = [ "vhhe", "vhwd", "dccv", "dcfb", "dcft", "camh", "caml", "cams", "vanp" ];
        let titles = [ NSLocalizedString("Vehicle height", comment: ""),
                       NSLocalizedString("Vehicle width", comment: ""),
                       NSLocalizedString("Distance between camera and the center of vehicle", comment: ""),
                       NSLocalizedString("Distance between camera and the front bumper", comment: ""),
                       NSLocalizedString("Distance between camera and the front tire", comment: ""),
                       NSLocalizedString("Camera height (ground)", comment: ""),
                       NSLocalizedString("Camera lens", comment: ""),
                       NSLocalizedString("Camera sensor size", comment: ""),
                       NSLocalizedString("Vanishing point", comment: "") ]
        let canInputs = [ true, true, true, true, true, true, true, true, true ]
        let units = [ "㎝","㎝", "㎝", "㎝", "㎝", "㎝", "㎜", "㎛", "x,y" ];
        let values = [ "", "", "", "", "", "", "", "", "{x:0, y:0}" ]
        
        for index in 0..<keys.count {
            var model = InputStyleModel(key: keys[index], title: titles[index])
            model.unit = units[index]
            model.canInput = canInputs[index]
            model.value = values[index]
            dataSource.append(model)
        }
        
    }
    
    private
    func showingCellFrameChanged(indexPath: IndexPath?) {
        if let tIndex = indexPath {
            let cellRect = tableView.rectForRow(at: tIndex)
            frameChangedBlock?(cellRect)
        }
    }
    
    private
    func checkCanSendState() {
        
        var valuedCount = 0
        for (_, value) in dataSource.enumerated() {
            if value.value?.isEmpty == false {
                valuedCount += 1
            }
        }
        
        switch valuedCount {
        case 0:
            stateChangedBlock?(IPVState.allEmpty)
            sendButton.setTitleColor(UIColor.gray, for: .normal)
        case 1..<dataSource.count:
            stateChangedBlock?(IPVState.halfFilled)
            sendButton.setTitleColor(.gray, for: .normal)
        case dataSource.count:
            stateChangedBlock?(IPVState.canSend)
            sendButton.setTitleColor(.green, for: .normal)
        default:
            print("do nothing")
        }
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK:- UITableViewDataSource

extension InputParametersView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kInputCellIdentifier, for: indexPath) as! InputStyleCell
        cell.selectionStyle = .none
        cell.indexPath = indexPath
        cell.setModel(dataSource[indexPath.row])
        
        if indexPath.row == 0 {
            selectedField = cell.inputField
        }
        
        cell.inputHandler = { [weak self] (view, justShow) in
            
            if let backCell = view as? InputStyleCell {
                self?.selectedField = backCell.inputField
                self?.selectedIndexPath = backCell.indexPath
                
                if justShow == true {
                    self?.showingCellFrameChanged(indexPath: backCell.indexPath)
                } else {
                    if let tRow = backCell.indexPath?.row {
                        self?.dataSource[tRow].value = backCell.inputText
                        self?.checkCanSendState()
                    }
                }
            }
            
        }
        
        return cell
    }
}
