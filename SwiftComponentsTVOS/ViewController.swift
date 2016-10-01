//
//  ViewController.swift
//  SwiftComponentsTVOS
//
//  Created by Jamie Lemon on 01/02/2016.
//  Copyright © 2016 dijipiji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let slider:DPSlider = DPSlider()
        slider.createSlider("helloSlider", size: CGRectMake(0, 50, 320, 50), snapPoints: 4, minValue:-100, maxValue:100, startValue:0)
        slider.delegate = self
        self.view.addSubview(slider)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

