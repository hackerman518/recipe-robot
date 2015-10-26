//
//  ImageViewExtensions.swift
//  Recipe Robot
//
//  Created by Eldon on 9/28/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

import AppKit

class GearImageView: NSImageView {

    var duration: NSTimeInterval = 2.0
    var maxOpacity: CGFloat = 0.20

    private var run = true;

    func colorize(){

        let red = CGFloat((rand() % 255) / 255)
        let green = CGFloat((rand() % 255) / 255)
        let blue = CGFloat((rand() % 255) / 255)
        let c = NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)

        if let policy = CIFilter(name: "CIColorPolynomial"){
            let rv = CIVector(x: c.redComponent, y: 0, z: 0, w: 0)
            let bv = CIVector(x: c.blueComponent, y: 0, z: 0,w: 0)
            let gv = CIVector(x: c.greenComponent, y: 0, z: 0,w: 0)

            policy.setValue(rv, forKey: "inputRedCoefficients")
            policy.setValue(gv, forKey: "inputGreenCoefficients")
            policy.setValue(bv, forKey: "inputBlueCoefficients")

            self.contentFilters.append(policy)
        }
    }

    func start(){
        run = true
        self.colorize()
        self.rotate()

        NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "fade:", userInfo: nil, repeats: true)
    }

    func stop(){
        run = false
    }

    func rotate(){
        self.wantsLayer = true
        self.layer!.anchorPoint = CGPointMake(0.50, 0.50)

        let frame = self.layer!.frame;

        let x = frame.origin.x + frame.size.width;
        let y = frame.origin.y + frame.size.height;
        self.layer!.position = CGPointMake(x, y)

        let rotation = CABasicAnimation(keyPath:"transform.rotation")

        rotation.fromValue = Float(0 * (M_PI / 180.0))
        rotation.toValue = Float((360.0) * (M_PI / 180.0))

        rotation.duration = 10.0
        rotation.delegate = self

        self.layer!.addAnimation(rotation, forKey: "transform")
    }

    func fade(timer: NSTimer){
        if !run {
            return timer.invalidate()
        }

        let _duration = self.duration
        let _maxOpacity = self.maxOpacity
        let _run = run

        NSAnimationContext.runAnimationGroup({[weak self]
            context in
                    context.duration = _duration
                    self!.animator().alphaValue = _maxOpacity
        },
            completionHandler: {
                NSAnimationContext.runAnimationGroup({[weak self]
                    context in
                        context.duration = _duration
                        self!.animator().alphaValue = 0.0
                },
                    completionHandler: {
                        if !_run {
                            self.layer!.removeAnimationForKey("transform")
                        }
                })
        })
    }
}
