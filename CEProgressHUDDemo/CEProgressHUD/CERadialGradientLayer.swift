//
//  CERadialGradientLayer.swift
//  CEProgressHUD
//
//  Created by 张延深 on 16/4/12.
//  Copyright © 2016年 宜信. All rights reserved.
//

import UIKit

class CERadialGradientLayer: CALayer {
    var gradientCenter: CGPoint?
    
    override func drawInContext(ctx: CGContext) {
        let locationsCount: Int = 2
        let locations: [CGFloat] = [0.0, 1.0]
        let colors: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75]
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let gradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount)!
        
        let radius: CGFloat = min(self.bounds.size.width, self.bounds.size.height)
        CGContextDrawRadialGradient(ctx, gradient, gradientCenter!, 0, gradientCenter!, radius, CGGradientDrawingOptions.DrawsAfterEndLocation)
    }
}
