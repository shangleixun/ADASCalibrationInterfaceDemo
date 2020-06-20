//
//  ViewController.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/13.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let kPixelWidthMax = 1280
    let kPixelHeightMax = 720
    let kScreenWidth = UIScreen.main.bounds.width
    let kScreenHeight = UIScreen.main.bounds.height
    
    var v_size: CGSize!
    var input_size: CGSize!
    var input_origin: CGPoint!
    var input_origin_hide: CGPoint!
    var selected_screen_point: CGPoint?
    var selected_pixel_point: CGPoint?
    
    var keyboardAnimDuration: Double = 0.0
    
    var videoView: UIImageView!
    var touchPoint: UIImageView!
    var wheel: SteeringWheel!
    var showInfo: UILabel!
    var inputView_c: InputParametersView!
    var inputViewShowing = false
    var showInputViewBtn: UIButton!
    
    var leftArrowTriangle: UIImage? {
        get {
            let imageConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50, weight: .light))
            return UIImage.init(systemName: "arrowtriangle.left.circle.fill", withConfiguration: imageConfig)
        }
    }
    
    var rightArrowTriangle: UIImage? {
        get {
            let imageConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50, weight: .light))
            return UIImage.init(systemName: "arrowtriangle.right.circle.fill", withConfiguration: imageConfig)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addVideoViewAndWheelControl()
        self.addInputView()
        self.addShowBtn()
        self.addViewControllerObservers(isAdd: true)
        
    }
    
    func addShowBtn() {
        
        showInputViewBtn = UIButton(type: .custom)
        showInputViewBtn.setImage(leftArrowTriangle, for: .normal)
        self.view.addSubview(showInputViewBtn)
        
        showInputViewBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        showInputViewBtn.addTarget(self, action: #selector(self.showInputView), for: .touchUpInside)
    }
    
    @objc func showInputView() {
        if inputViewShowing {
            self.animateInInputView()
            return
        }
        self.animateOutInputView()
    }
    
    func addInputView() {
        
        input_size = CGSize(width: kScreenWidth * 3.2 / 5.0, height: kScreenHeight - 162)
        input_origin = CGPoint(x: kScreenWidth / 2.0 - input_size.width / 2.0, y: 0)
        input_origin_hide = CGPoint(x: kScreenWidth + 30.0, y: 0)
        
        inputView_c = InputParametersView(frame: CGRect(origin: input_origin_hide, size: input_size))
        inputView_c.frameChangedBlock = { [weak self] (newFrame) in
            if let new = self?.view.convert(newFrame, from: self?.inputView_c) {
                print("\(NSCoder.string(for: new))")
            }
        }
        self.view.addSubview(inputView_c)
    }
    
    func addVideoViewAndWheelControl() {
        
        v_size = CGSize(width: kScreenWidth, height: kScreenHeight)
        videoView = UIImageView()
        videoView.isUserInteractionEnabled = true
        videoView.image = UIImage.init(named: "image.jpg")
        videoView.contentMode = .scaleToFill
        
        self.view.addSubview(videoView)
        videoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        wheel = SteeringWheel(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        wheel.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        wheel.layer.cornerRadius = 60.0
        wheel.btnTouchEvent = { [weak self] (sender) in
            if let senderView = sender as? UIView {
                print("点击了 或者长按了 \(senderView.tag)")
                self?.moveTargetViewWith(SteeringWheelButtonDirection(rawValue: senderView.tag)!)
            }
        }
        videoView.addSubview(wheel)
        wheel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 120))
        }
        
        touchPoint = UIImageView(image: UIImage.init(named: "cross_black"))
        videoView.addSubview(touchPoint)
        selected_pixel_point = CGPoint.zero
        
        self.viewDrawLine()
        
        showInfo = UILabel()
        showInfo.backgroundColor = UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        showInfo.frame = CGRect(x: 100, y: 100, width: 150, height: 60)
        showInfo.font = UIFont.systemFont(ofSize: 20.0, weight: .heavy)
        showInfo.layer.cornerRadius = 5.0
        showInfo.layer.masksToBounds = true
        showInfo.layer.borderWidth = 0
        
        videoView.addSubview(showInfo)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.edgeShowInputView(_:)))
        edgePan.edges = .right
        self.view.addGestureRecognizer(edgePan)
        
    }
    
    @objc func edgeShowInputView(_ ges: UIScreenEdgePanGestureRecognizer) {
        switch ges.state {
        case .began:
            self.animateOutInputView()
        default:
            print("do nothing")
        }
    }
    
    func animateOutInputView() {
        guard inputViewShowing == false else {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.inputView_c.frame = CGRect(origin: (self?.input_origin)!, size: (self?.input_size)!)
            self?.inputView_c.edgeShow()
            self?.showInputViewBtn.setImage(self?.rightArrowTriangle, for: .normal)
        }) { [weak self] (finished) in
            self?.inputViewShowing = true
        }
    }
    
    func animateInInputView() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.inputView_c.frame = CGRect(origin: (self?.input_origin_hide)!, size: (self?.input_size)!)
            self?.inputView_c.edgeHide()
            self?.showInputViewBtn.setImage(self?.leftArrowTriangle, for: .normal)
        }) { [weak self] (finished) in
            self?.inputViewShowing = false
        }
    }
    
    func addViewControllerObservers(isAdd: Bool) {
        if isAdd == true {
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchComesToView(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchComesToView(touches)
    }
    
    func touchComesToView(_ touches: Set<UITouch>) {
        
        if var point = touches.first?.location(in: self.view) {
            
            point = videoView.layer.convert(point, from: self.view.layer)
            if videoView.layer.contains(point) {
                if inputViewShowing {
                    self.animateInInputView()
                    return
                }
                
                let wheelPoint = wheel.layer.convert(point, from: videoView.layer)
                guard wheel.layer.contains(wheelPoint) == false else {
                    return
                }
                
                let wMax = CGFloat(kPixelWidthMax)
                let hMax = CGFloat(kPixelHeightMax)
                var x_p = point.x / v_size.width * wMax
                var y_p = point.y / v_size.height * hMax
                x_p = x_p.rounded(.up)
                y_p = y_p.rounded(.up)
                if x_p > wMax {
                    x_p = wMax
                }
                if y_p > hMax {
                    y_p = hMax
                }
                self.moveTargetViewTo(x: x_p, y: y_p)
            }
        }
    }
    
    func moveTargetViewWith(_ direction: SteeringWheelButtonDirection) {
        
        var pointx = selected_pixel_point!.x
        var pointy = selected_pixel_point!.y
        let pixelWidthMax = CGFloat(kPixelWidthMax)
        let pixelHeightMax = CGFloat(kPixelHeightMax)
        
        switch direction {
        case .up:
            pointy -= 1
            if pointy < CGFloat.zero {
                pointy = CGFloat.zero
            }
            
        case .left:
            pointx -= 1
            if pointx < CGFloat.zero {
                pointx = 0
            }
            
        case .right:
            pointx += 1
            if pointx > pixelWidthMax {
                pointx = pixelWidthMax
            }
        case .down:
            pointy += 1
            if pointy > pixelHeightMax {
                pointy = pixelHeightMax
            }
        }
        
        self.moveTargetViewTo(x: pointx, y: pointy)
    }
    
    func moveTargetViewTo(x: CGFloat, y: CGFloat) {
        
        selected_pixel_point = CGPoint(x: x, y: y)
        let targetScreenPointX = x * v_size.width / CGFloat(kPixelWidthMax)
        let targetScreenPointY = y * v_size.height / CGFloat(kPixelHeightMax)
        
        selected_screen_point = CGPoint(x: targetScreenPointX, y: targetScreenPointY)
        touchPoint.center = selected_screen_point!
        
        let text = String.init(format: "{x:%.1f, y:%.1f}", x, y)
        let txtRect = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 60), options: .usesLineFragmentOrigin, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy) ], context: nil)
        
        inputView_c.updateModelBy(key: "vanp", value: text)
        
        let newFrame = CGRect(x: 100, y: 100, width: txtRect.width.rounded(.up), height: 60)
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.showInfo.frame = newFrame
            self?.showInfo.text = text
        }
    }

    func viewDrawLine() {
        let h1_ratio: CGFloat = 300.0 / 720.0
        let h2_ratio: CGFloat = 420.0 / 720.0
        let hcenter_ratio: CGFloat = 0.5
        let vcenter_ratio: CGFloat = 0.5
        
        let width = v_size.width
        let height = v_size.height
        
        let h1_start = CGPoint(x: 0, y: height * h1_ratio)
        let h1_end = CGPoint(x: width, y: height * h1_ratio)
        let h2_start = CGPoint(x: 0, y: height * h2_ratio)
        let h2_end = CGPoint(x: width, y: height * h2_ratio)
        
        let hcenter_start = CGPoint(x: 0, y: hcenter_ratio * height)
        let hcenter_end = CGPoint(x: width, y: hcenter_ratio * height)
        let vcenter_start = CGPoint(x: vcenter_ratio * width, y: 0)
        let vcenter_end = CGPoint(x: vcenter_ratio * width, y: height)
        
        let linePath = UIBezierPath()
        linePath.move(to: h1_start)
        linePath.addLine(to: h1_end)
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1.0
        lineLayer.strokeColor = UIColor.orange.cgColor
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        videoView.layer.addSublayer(lineLayer)
        
        let linePath2 = UIBezierPath()
        linePath2.move(to: h2_start)
        linePath2.addLine(to: h2_end)
        let lineLayer2 = CAShapeLayer()
        lineLayer2.lineWidth = 1.0
        lineLayer2.strokeColor = UIColor.orange.cgColor
        lineLayer2.path = linePath2.cgPath
        lineLayer2.fillColor = nil
        videoView.layer.addSublayer(lineLayer2)
        
        let linePath3 = UIBezierPath()
        linePath3.move(to: hcenter_start)
        linePath3.addLine(to: hcenter_end)
        let lineLayer3 = CAShapeLayer()
        lineLayer3.lineWidth = 1.0
        lineLayer3.strokeColor = UIColor.red.cgColor
        lineLayer3.path = linePath3.cgPath
        lineLayer3.lineDashPattern = [ NSNumber(5), NSNumber(2) ]
        lineLayer3.fillColor = nil
        videoView.layer.addSublayer(lineLayer3)
        
        let linePath4 = UIBezierPath()
        linePath4.move(to: vcenter_start)
        linePath4.addLine(to: vcenter_end)
        let lineLayer4 = CAShapeLayer()
        lineLayer4.lineWidth = 1.0
        lineLayer4.strokeColor = UIColor.red.cgColor
        lineLayer4.path = linePath4.cgPath
        lineLayer4.lineDashPattern = [ NSNumber(5), NSNumber(2) ]
        lineLayer4.fillColor = nil
        videoView.layer.addSublayer(lineLayer4)
    }
    
    @objc func keyboardWillShow(_ notif: Notification) {
        
        if let isMyKeyboard = notif.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            let keyboardFrame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animDuration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            if isMyKeyboard == true {
                
                let kScreenHeight = UIScreen.main.bounds.height
                let keyboardH = keyboardFrame.height
                let targetHeight = kScreenHeight - keyboardH
                
                input_size = CGSize(width: input_size.width, height: targetHeight)
                keyboardAnimDuration = animDuration
                UIView.animate(withDuration: animDuration) { [weak self] in
                    self?.inputView_c.frame = CGRect(origin: (self?.input_origin)!, size: (self?.input_size)!)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notif: Notification) {
        print("keyboard will hide")
    }


}



