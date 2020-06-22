//
//  SteeringWheel.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/13.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

public enum SteeringWheelButtonDirection: Int {
    case up     = 700
    case left   = 701
    case right  = 702
    case down   = 703
}

private enum DispatchSourceTimerState: String {
    case null
    case started
    static let cancelled = DispatchSourceTimerState.null
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
    private var longPressTimer: DispatchSourceTimer?
    private var haptics: UIImpactFeedbackGenerator?
    
    override
    init(frame: CGRect) {
        super.init(frame: frame)
        addCustomViews()
    }
    
    required
    init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    func addCustomViews() {
        
        let width = frame.width
        let height = frame.height
        
        let normalImageNames = [ "arrow_up_c", "arrow_left_c", "arrow_right_c", "arrow_down_c" ]
        let highlightedImageNames = [ "arrow_up_selected", "arrow_left_selected", "arrow_right_selected", "arrow_down_selected" ]
        
        let sel = #selector(touchButtonEvent(_:))
        
        up = gimmeButtonWith(direction: .up, image: normalImageNames[0], highlightedImage: highlightedImageNames[0], action: sel)
        left = gimmeButtonWith(direction: .left, image: normalImageNames[1], highlightedImage: highlightedImageNames[1], action: sel)
        right = gimmeButtonWith(direction: .right, image: normalImageNames[2], highlightedImage: highlightedImageNames[2], action: sel)
        down = gimmeButtonWith(direction: .down, image: normalImageNames[3], highlightedImage: highlightedImageNames[3], action: sel)
        
        addSubview(up)
        addSubview(left)
        addSubview(right)
        addSubview(down)
        
        let btn_width = width / 3.0
        let btn_height = height / 3.0
        
        up.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(width/3.0)
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        left.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height/3.0)
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        right.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height/3.0)
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
        down.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(width/3.0)
            make.size.equalTo(CGSize(width: btn_width, height: btn_height))
        }
        
    }
    
    private
    func gimmeButtonWith(direction: SteeringWheelButtonDirection, image: String, highlightedImage: String, action: Selector) -> UIButton! {
        
        let btn = UIButton(type: .custom)
        btn.tag = direction.rawValue
        btn.setImage(UIImage(named: image), for: .normal)
        btn.setImage(UIImage(named: highlightedImage), for: .highlighted)
        btn.addTarget(self, action: action, for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressButtonEvent(_:)))
        btn.addGestureRecognizer(longPress)
        
        return btn
    }
    
    @objc private
    func touchButtonEvent(_ sender: UIButton!) {
        if btnTouchEvent != nil {
            btnTouchEvent!(sender)
        }
        
        if haptics == nil {
            haptics = UIImpactFeedbackGenerator(style: .medium)
        }
        haptics?.prepare()
        
        if #available(iOS 13.0, *) {
            haptics?.impactOccurred(intensity: 1.0)
        } else {
            haptics?.impactOccurred()
        }
        haptics?.prepare()
    }
    
    @objc private
    func longPressButtonEvent(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if haptics == nil {
                haptics = UIImpactFeedbackGenerator(style: .medium)
            }
            haptics?.prepare()
            
            needRepeat = true
            engineStartTimerWith(view: gesture.view as? UIButton)
       
        case .ended:
            needRepeat = false
            haptics = nil
            
        default:
            print("do nothing")
        }
    }
    
    private
    func engineStartTimerWith(view: UIButton?) {
        if longPressTimer == nil {
            longPressTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            longPressTimer?.schedule(deadline: .now(), repeating: 0.05, leeway: DispatchTimeInterval.seconds(0))
            longPressTimer?.setEventHandler { [weak self] in
                
                if self?.needRepeat == false {
                    self?.longPressTimer?.cancel()
                    self?.longPressTimer = nil
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
            longPressTimer?.resume()
            timerState = .started
        }
    }
    
    deinit {
        if longPressTimer != nil {
            longPressTimer?.cancel()
            longPressTimer = nil
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
