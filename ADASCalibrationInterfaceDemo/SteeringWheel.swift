//
//  SteeringWheel.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/13.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

public enum SteeringWheelButtonDirection: Int {
    case up = 700
    case left = 701
    case right = 702
    case down = 703
}

private enum DispatchSourceTimerState: String {
    case null = "null"
    case started = "started"
    case cancelled = "cancelled"
}

public typealias UIButtonTouchUpInsideEvent = (AnyObject?) -> Void

class SteeringWheel: UIView {
    
    public var btnTouchEvent: UIButtonTouchUpInsideEvent?
    
    private var up: UIButton!
    private var left: UIButton!
    private var right: UIButton!
    private var down: UIButton!
    private var needRepeat: Bool!
    private var timerState: DispatchSourceTimerState?
    private var long_press_timer: DispatchSourceTimer?
    private var haptics: UIImpactFeedbackGenerator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCustomViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomViews() {
        
        let width = self.frame.width
        let height = self.frame.height
        
        let normalImageNames = [ "arrow_up_c", "arrow_left_c", "arrow_right_c", "arrow_down_c" ]
        let highlightedImageNames = [ "arrow_up_selected", "arrow_left_selected", "arrow_right_selected", "arrow_down_selected" ]
        
        let sel = #selector(self.touchButtonEvent(_:))
        
        self.up = self.gimmeButtonWith(direction: .up, image: normalImageNames[0], highlightedImage: highlightedImageNames[0], action: sel)
        self.left = self.gimmeButtonWith(direction: .left, image: normalImageNames[1], highlightedImage: highlightedImageNames[1], action: sel)
        self.right = self.gimmeButtonWith(direction: .right, image: normalImageNames[2], highlightedImage: highlightedImageNames[2], action: sel)
        self.down = self.gimmeButtonWith(direction: .down, image: normalImageNames[3], highlightedImage: highlightedImageNames[3], action: sel)
        
        self.addSubview(self.up)
        self.addSubview(self.left)
        self.addSubview(self.right)
        self.addSubview(self.down)
        
        let btn_width = width / 3.0
        let btn_height = height / 3.0
        
        self.up.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(width/3.0)
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        self.left.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height/3.0)
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        self.right.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height/3.0)
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        self.down.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(width/3.0)
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
    }
    
    func gimmeButtonWith(direction: SteeringWheelButtonDirection, image: String, highlightedImage: String, action: Selector) -> UIButton! {
        
        let btn = UIButton(type: .custom)
        btn.tag = direction.rawValue
        btn.setImage(UIImage(named: image), for: .normal)
        btn.setImage(UIImage(named: highlightedImage), for: .highlighted)
        btn.addTarget(self, action: action, for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPressButtonEvent(_:)))
        btn.addGestureRecognizer(longPress)
        
        return btn
    }
    
    @objc func touchButtonEvent(_ sender: UIButton!) {
        if self.btnTouchEvent != nil {
            self.btnTouchEvent!(sender)
        }
        
        if self.haptics == nil {
            self.haptics = UIImpactFeedbackGenerator(style: .medium)
        }
        self.haptics?.prepare()
        
        if #available(iOS 13.0, *) {
            self.haptics?.impactOccurred(intensity: 1.0)
        } else {
            self.haptics?.impactOccurred()
        }
        self.haptics?.prepare()
    }
    
    @objc func longPressButtonEvent(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if self.haptics == nil {
                self.haptics = UIImpactFeedbackGenerator(style: .medium)
            }
            self.haptics?.prepare()
            
            needRepeat = true
            engineStartTimerWith(view: gesture.view as? UIButton)
       
        case .ended:
            needRepeat = false
            haptics = nil
            
        default:
            print("do nothing")
        }
    }
    
    func engineStartTimerWith(view: UIButton?) {
        if long_press_timer == nil {
            long_press_timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            long_press_timer?.schedule(deadline: .now(), repeating: 0.05, leeway: DispatchTimeInterval.seconds(0))
            long_press_timer?.setEventHandler { [weak self] in
                
                if self?.needRepeat == false {
                    self?.long_press_timer?.cancel()
                    self?.long_press_timer = nil
                    self?.timerState = .cancelled
                } else {
                    if #available(iOS 13.0, *) {
                        self?.haptics?.impactOccurred(intensity: 1.0)
                    } else {
                        self?.haptics?.impactOccurred()
                    }
                    self?.haptics?.prepare()
                    
                    self?.btnTouchEvent?(view)
                }
            }
            timerState = .null
        }
        
        if timerState == DispatchSourceTimerState.null {
            long_press_timer?.resume()
            timerState = .started
        }
        
    }
    
    override func delete(_ sender: Any?) {
        if long_press_timer != nil {
            long_press_timer?.cancel()
            long_press_timer = nil
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
