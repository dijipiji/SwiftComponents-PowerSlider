//
//  ViewController.swift
//  SwiftComponents
//
//  Created by Jamie Lemon on 27/01/2016.
//  Copyright © 2016 dijipiji. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PowerSliderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGrayColor()

        var slider:PowerSlider = PowerSlider()
        slider.createSlider("basic slider", size: CGRectMake(0, 50, 320, 50), snapPoints: 0, minValue:0, maxValue:1, paddleGraphicA:UIImage(named:"paddle"))
        slider.delegate = self
        self.view.addSubview(slider)
        
        slider = PowerSlider()
        slider.createSlider("snapping slider", size: CGRectMake(0, 120, 320, 50), snapPoints:10)
        slider.delegate = self
        self.view.addSubview(slider)
        
        slider = PowerSlider()
        slider.createSlider("filter slider", size: CGRectMake(0, 190, 320, 50), snapPoints:0, dualSlider:true)
        slider.delegate = self
        self.view.addSubview(slider)
        
        slider = PowerSlider()
        slider.createSlider("snapping filter slider", size: CGRectMake(40, 260, 320-80, 50), snapPoints:4, dualSlider:true,
                            startValueA:20, startValueB:100, trackPaintColor:UIColor.orangeColor())
        slider.delegate = self
        self.view.addSubview(slider)
        
    }
    
    /*** Slider delegate methods ***/
    
    /**
     * I'll leave it up to you to how you want to display the slider data
     * Note: If the slider is just a single slider you probably won't care about rangeB, currentSnapPointB, currentValueB ...
     */
    
    
     /**
     *
     */
    
    func sliderDidStartSliding(slider:PowerSlider) {
        print("---> sliderDidStartSliding: \(slider.name)")
        printSliderValues(slider)
    }
    /**
     *
     */
    func sliderIsSliding(slider:PowerSlider) {
        print("sliderIsSliding: \(slider.name)")
        printSliderValues(slider)
    }
    
    /**
     *
     */
    func sliderDidFinishSliding(slider:PowerSlider) {
        print("\n--->sliderDidFinishSlide: \(slider.name)")
        printSliderValues(slider)
        
    }
    
    
    /**********/
    func printSliderValues(slider:PowerSlider) {
        print("rangeA: \(slider.rangeA), rangeB: \(slider.rangeB)")
        print("currentSnapIndexA:\(slider.currentSnapIndexA), currentSnapIndexB:\(slider.currentSnapIndexB)")
        print("slider.currentValueA:\(slider.currentValueA), currentValueB:\(slider.currentValueB)")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

