//
//  PowerSliderDelegate.swift
//  SwiftComponents
//
//  Created by Jamie Lemon on 02/02/2016.
//  Copyright © 2016 dijipiji. All rights reserved.
//

import Foundation


protocol PowerSliderDelegate  {
    
    func sliderDidStartSliding(slider:PowerSlider)
    func sliderIsSliding(slider:PowerSlider)
    func sliderDidFinishSliding(slider:PowerSlider)
    
}
