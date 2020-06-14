//
//  ViewController.swift
//  ADASCalibrationInterfaceDemo
//
//  Created by 尚雷勋 on 2020/6/13.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var wheel: SteeringWheel?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.wheel = SteeringWheel(frame: CGRect(x: 50, y: 50, width: 120, height: 120))
        
        self.wheel?.btnTouchEvent = { (view) in
            print("time\(Date()) come here once")
        }
        
        self.view.addSubview(self.wheel!)
        
        
    }


}



