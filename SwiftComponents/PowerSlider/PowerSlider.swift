/*
BSD License

Copyright © dijipiji.com 2016 - Jamie Lemon
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the owner nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//
//  PowerSlider.swift
//  SwiftComponents
//
//  Created by Jamie Lemon on 02/02/2016.
//  Copyright © 2016 dijipiji. All rights reserved.
//



import UIKit

class PowerSlider: UIView {
    
    // internal vars
    internal var delegate:PowerSliderDelegate! = nil
    internal var name:String = ""
    internal var rangeA:CGFloat = 0
    internal var rangeB:CGFloat = 0
    internal var currentSnapIndexA:Int = 0
    internal var currentSnapIndexB:Int = 0
    internal var currentValueA:CGFloat = 0
    internal var currentValueB:CGFloat = 0
    internal var _minValue:CGFloat = 0
    internal var _maxValue:CGFloat = 0
    internal var isDualSlider:Bool = false
    
    // private vars
    private let PADDLE_W_H:CGFloat = 50
    private let snapPointMetrics:(w:CGFloat, h:CGFloat) = (3,8)
    private let trackPaintMetrics:(w:CGFloat, h:CGFloat) = (0,1)
    
    private var paddleA:UIImageView = UIImageView()
    private var paddleB:UIImageView = UIImageView()
    private var touchedPaddle:UIImageView!
    private var movePaddle:Bool = false
    private var xInc:CGFloat = 1.0
    private var SNAP_POINTS:[CGFloat] = []
    private var paddleIsAnimatingToPosition:Bool = false
    private var paintColor:UIColor!
    private var paintView:UIView!
    private var paintTimer:NSTimer = NSTimer()
    
    /**
     *
     */
    func createSlider(myName:String, size:CGRect, snapPoints:Int,
        dualSlider:Bool? = false,
        minValue:CGFloat? = 0,
        maxValue:CGFloat? = 100,
        startValueA:CGFloat? = 0,
        startValueB:CGFloat? = 100,
        trackPaintColor:UIColor? = UIColor.greenColor(),
        paddleGraphicA:UIImage? = UIImage(named: "paddle-a")!,
        paddleGraphicB:UIImage? = UIImage(named: "paddle-b")!,
        trackAssetLeft:UIImage? = UIImage(named: "track-left")!,
        trackAssetRight:UIImage? = UIImage(named: "track-right")!,
        trackAssetMiddle:UIImage? = UIImage(named: "track-middle")!,
        trackAssetSnapPoint:UIImage? = UIImage(named: "track-snap-point")!) {
            
        name = myName
        isDualSlider = dualSlider!
        self.frame = size
        
        paintColor = trackPaintColor!
        _minValue = minValue!
        _maxValue = maxValue!
 
        currentValueA = startValueA!
        currentValueB = startValueB!
        
        if _minValue > maxValue {
            // display an error
            self.backgroundColor = UIColor.redColor()
            let lbl:UILabel = UILabel(frame: CGRectMake(0,0,size.width,size.height))
            lbl.text = "min value > max value"
            self.addSubview(lbl)
            return
        }
            
        if currentValueA > maxValue {
            currentValueA = maxValue!
        }
        else if currentValueA < minValue {
            currentValueA = minValue!
        }
            
        if currentValueB > maxValue {
            currentValueB = maxValue!
        }
        else if currentValueB < minValue {
            currentValueB = minValue!
        }
        
        // build the slider track
        let startX:CGFloat = 0
        let startY:CGFloat = 0
        let endX:CGFloat = size.width - PADDLE_W_H
        let endY:CGFloat = 0
        
        let trackLeft:UIImageView = UIImageView(frame:CGRectMake(startX, startY, PADDLE_W_H, PADDLE_W_H))
        trackLeft.image = trackAssetLeft
        trackLeft.userInteractionEnabled = false
        self.addSubview(trackLeft)
        
        let trackMiddle:UIImageView = UIImageView(frame:CGRectMake(startX+PADDLE_W_H, startY, size.width-(PADDLE_W_H*2), PADDLE_W_H))
        trackMiddle.image = trackAssetMiddle
        trackMiddle.userInteractionEnabled = false
        self.addSubview(trackMiddle)
        
        let trackRight:UIImageView = UIImageView(frame:CGRectMake(endX, endY, PADDLE_W_H, PADDLE_W_H))
        trackRight.image = trackAssetRight
        trackRight.userInteractionEnabled = false
        self.addSubview(trackRight)
        
        // figure out snapPoints
        if snapPoints > 0 {
            
            let xGap:CGFloat = (size.width-PADDLE_W_H)/CGFloat(snapPoints-1)
            
            for position in 0...snapPoints-1 {
                
                let xPosition = ((PADDLE_W_H/2)+(xGap * CGFloat(position))-(snapPointMetrics.w)/2)
                
                // avoid rendering the 1st and last points as they are at the start and end of the track
                if position > 0 && position < snapPoints-1 {
                    let snapPoint:UIImageView = UIImageView(frame:CGRectMake(xPosition, (PADDLE_W_H-snapPointMetrics.h)/2, snapPointMetrics.w, snapPointMetrics.h))
                    snapPoint.image = trackAssetSnapPoint
                    snapPoint.userInteractionEnabled = false
                    self.addSubview(snapPoint)
                }
                
                SNAP_POINTS.append(xPosition+(snapPointMetrics.w)/2)
            }
        }
            
        // find the start ranges for the paddles
        rangeA = (currentValueA-_minValue)/(_maxValue-_minValue)
        rangeB = (currentValueB-_minValue)/(_maxValue-_minValue)
        
        if dualSlider == true {
            // create the paintTrack
            paintView = UIView(frame:CGRectMake(PADDLE_W_H/2, (PADDLE_W_H-trackPaintMetrics.h)/2, size.width-(PADDLE_W_H), trackPaintMetrics.h))
            paintView.backgroundColor = paintColor
            self.addSubview(paintView)
        }
            
        // create paddle A
        paddleA.frame = CGRectMake(0, startY, PADDLE_W_H, PADDLE_W_H)
        paddleA.tag = 0
        paddleA.image = paddleGraphicA
        paddleA.userInteractionEnabled = true
        self.addSubview(paddleA)
        setPaddlePositionFromRange(paddleA, range:rangeA)
        checkPaddleLimits(paddleA)
        
        if dualSlider == true {
            // create paddle B
            paddleB.frame = CGRectMake(0, startY, PADDLE_W_H, PADDLE_W_H)
            paddleB.tag = 1
            paddleB.image = paddleGraphicB
            paddleB.userInteractionEnabled = true
            self.addSubview(paddleB)
            setPaddlePositionFromRange(paddleB, range:rangeB)
            checkPaddleLimits(paddleB)
            
            paintTrack()
        }
            
        if snapPoints > 0 {
            setSnapPoint(paddleA)

            if dualSlider == true {
                setSnapPoint(paddleB)
            }
            
            movePaddleToNearest(paddleA)
            
            // required to check again due to the frame logic for paddles
            if dualSlider == true {
                movePaddleToNearest(paddleB)
            }
            
        }
            
        setupPanGesture()
            
    }
    

    
    /**
     *
     */
    private func setPaddlePositionFromRange(paddle:UIImageView, range:CGFloat) {
        paddle.center.x = (PADDLE_W_H/2)+((self.frame.width-PADDLE_W_H) * range)
    }
    
    /**
     *
     */
    private func setRangeAndValueFromPaddlePosition(paddle:UIImageView) {
        if paddle.tag == 0 {
            rangeA = paddle.frame.origin.x / (self.frame.size.width-PADDLE_W_H)
            currentValueA = _minValue + rangeA*(_maxValue-_minValue)
        }
        else {
            rangeB = paddle.frame.origin.x / (self.frame.size.width-PADDLE_W_H)
            currentValueB = _minValue + rangeB*(_maxValue-_minValue)
        }
    }
    
    /**
     *
     */
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target:self, action:"pan:")
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
    }
    
    /**
     *
     */
    private func checkPaddleLimits(paddle:UIImageView) {

        // checks for lower limit of slider
        if paddle.center.x <= (PADDLE_W_H/2) {
            paddle.center.x = (PADDLE_W_H/2)
        }
        
        // checks for upper limit of slider
        if paddle.center.x >= self.frame.width-(PADDLE_W_H/2) {
            paddle.center.x = self.frame.width-(PADDLE_W_H/2)
        }
        
        // checks for paddles not getting too close to each other
        // paddle A
        if paddle.tag==0 && paddleB.frame != CGRectZero {
            if paddle.center.x >= paddleB.center.x-(PADDLE_W_H/2) {
                paddle.center.x = paddleB.center.x-(PADDLE_W_H/2)
            }
        }
        else if paddle.tag==1 && paddleA.frame != CGRectZero {
            if paddle.center.x <= paddleA.center.x+(PADDLE_W_H/2) {
                paddle.center.x = paddleA.center.x+(PADDLE_W_H/2)
            }
        }
    }
    
    /**
     *
     */
    internal func setSnapPoint(paddle:UIImageView) {
        
        if SNAP_POINTS.count == 0 {
            return
        }
        
        var sliderFindingSnapPoint:Bool = false
        
        for position in 0...SNAP_POINTS.count-2  {
            
            // compare the paddle position against 2 adjacent snap points
            let posA = SNAP_POINTS[position]
            let posB = SNAP_POINTS[position+1]
            
            // is the paddle closer to posA or posB ?
            let distA = paddle.center.x - posA
            let distB = posB - paddle.center.x
            
            if paddle.center.x < posB {
                if distA < distB {
                    sliderFindingSnapPoint = true
                    
                    if paddle.tag == 0 {
                        currentSnapIndexA = position
                    }
                    else {
                        currentSnapIndexB = position
                    }
                    
                    
                    break
                }
                else if distB <= distA {
                    sliderFindingSnapPoint = true
                    
                    if paddle.tag == 0 {
                        currentSnapIndexA = position+1
                    }
                    else {
                        currentSnapIndexB = position+1
                    }
                    
                    
                    break
                }
            }
        }
        
        if !sliderFindingSnapPoint {
            
            if paddle.tag == 0 {
                currentSnapIndexA = SNAP_POINTS.count-1
            }
            else {
                currentSnapIndexB = SNAP_POINTS.count-1
            }
        }
    }
    
    /**
     *
     */
    private func movePaddleToNearest(paddle:UIImageView) {
        
        if paddle.tag == 0 {
            // paddle A can't share the same snap index as paddle B, let's just validate that
            if currentSnapIndexA == currentSnapIndexB && isDualSlider {
                currentSnapIndexA = currentSnapIndexB-1
            }

            animateSliderToPosition(paddle, position:SNAP_POINTS[currentSnapIndexA])
        }
        else {
            // paddle B can't share the same snap index as paddle A, let's just validate that
            if currentSnapIndexB == currentSnapIndexA && isDualSlider {
                currentSnapIndexB = currentSnapIndexA+1
            }
            
            animateSliderToPosition(paddle, position:SNAP_POINTS[currentSnapIndexB])
        }
    }
    
    
    /**
     *
     */
    internal func paintTrack() {
        paintView.frame = CGRectMake(paddleA.center.x, paintView.frame.origin.y, paddleB.center.x - paddleA.center.x, paintView.frame.size.height)
    }
    
    /**
     *
     */
    internal func pan(gesture:UIPanGestureRecognizer) {
        
        let pt:CGPoint = gesture.locationInView(self)
        var hitPaddle:UIView
        
        switch gesture.state {
            
            case .Began:
                movePaddle = false
                hitPaddle = self.hitTest(pt, withEvent: nil)!
                if hitPaddle == paddleA {
                    touchedPaddle = paddleA
                    movePaddle = true
                }
                else if hitPaddle == paddleB {
                    touchedPaddle = paddleB
                    movePaddle = true
                }
                
                if movePaddle {
                    self.bringSubviewToFront(touchedPaddle)
                    sliderDidStartSliding()
                }
                
            case .Changed:
                if movePaddle {
                    touchedPaddle.center.x = pt.x - (pt.x % xInc)
                    checkPaddleLimits(touchedPaddle)
                    
                    if isDualSlider {
                        paintTrack()
                    }
                    setSnapPoint(touchedPaddle)
                    setRangeAndValueFromPaddlePosition(touchedPaddle)
                    sliderIsSliding()
                    
                }
                
            case .Ended:
                if movePaddle{
                    
                    // find the closest snap point as required
                    if SNAP_POINTS.count > 0 {
                        movePaddleToNearest(touchedPaddle)
                    }
                    else {
                        setRangeAndValueFromPaddlePosition(touchedPaddle)
                        sliderDidFinishSlide()
                    }
                    
                    movePaddle = false
                }
                
            case .Possible:
                print("PowerSlider.pan.Possible")
                
            case .Cancelled:
                print("PowerSlider.pan.Cancelled")
                
            case .Failed:
                print("PowerSlider.pan.Failed")
        }
    }
    
    
    /**
     *
     */
    private func animateSliderToPosition(paddle:UIImageView, position:CGFloat) {

        // maybe there is no need to animate?
        if paddle.center.x == position {
            setRangeAndValueFromPaddlePosition(paddle)
            sliderDidFinishSlide()
        }
        else {
            
            if isDualSlider {
                paintTimer = NSTimer.scheduledTimerWithTimeInterval(0.04, target: self, selector: Selector("paintTrack"), userInfo: nil, repeats: true)
                paintTimer.fire()
            }
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                paddle.center.x = position
                self.paddleIsAnimatingToPosition = true
                
                }, completion: {
                    (value: Bool) in
                    if self.isDualSlider {
                        self.paintTimer.invalidate()
                        self.paintTrack()
                    }
                    
                    self.paddleIsAnimatingToPosition = false
                    self.setRangeAndValueFromPaddlePosition(paddle)
                    self.sliderDidFinishSlide()
                    
            })
        }
    }
    
    /**
     *
     */
    private func sliderDidStartSliding() {
        if delegate != nil {
            delegate.sliderDidStartSliding(self)
        }
    }
    
    /**
     *
     */
    private func sliderIsSliding() {
        if delegate != nil {
            delegate.sliderIsSliding(self)
        }
    }
    
    /**
     *
     */
    private func sliderDidFinishSlide() {
        if delegate != nil {
            delegate.sliderDidFinishSliding(self)
        }
    }
    
}

