//
//  CEProgressHUD.swift
//  CEProgressHUD
//
//  Created by 张延深 on 16/4/11.
//  Copyright © 2016年 宜信. All rights reserved.
//

import UIKit

enum CEProgressHUDStyle {
    case light
    case dark
}

enum CEProgressHUDMaskType {
    case none
    case clear
    case black
    case gradient
}

enum CEProgressHUDIndicatorStyle {
    case system
    case default1
    case custom
}

class CEProgressHUD: UIView {
    
    private let parallaxDepthPoints: CGFloat = 20.0
    
    // MARK:-----private properties-----
    private var foregroundColor: UIColor?
    private var backgroundLayerColor: UIColor?
    private var defaultStyle: CEProgressHUDStyle?
    private var font: UIFont?
    private var successImage: UIImage?
    private var errorImage: UIImage?
    private var cornerRadius: CGFloat?
    private var minDismissTimeInterval: NSTimeInterval?
    private var defaultMaskType: CEProgressHUDMaskType?
    private var indicatorStyle: CEProgressHUDIndicatorStyle?
    private var backgroundLayer: CALayer?
    private var animationImages: [UIImage]? = []

    private var hudInteractionEnable: Bool? = false // HUD能否与用户交互
    
    private var isInitializing: Bool?
    private var fadeOutTimer: NSTimer?
    
    private var overlayView: UIControl?
    private var hudView: UIView?
    
    private var statusLabel: UILabel?
    private var imageView: UIImageView?
    private var indicator: UIActivityIndicatorView?
    
    // MARK:------initial function------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isInitializing = true
        
        self.userInteractionEnabled = false
        self.alpha = 0.0
        
        self.backgroundColor = UIColor.clearColor()
        self.foregroundColor = UIColor.blackColor()
        self.backgroundLayerColor = UIColor(white: 0, alpha: 0.4)
        self.defaultStyle = CEProgressHUDStyle.light
        self.defaultMaskType = CEProgressHUDMaskType.none
        self.indicatorStyle = CEProgressHUDIndicatorStyle.system
        
        if UIFont.respondsToSelector(#selector(UIFont.preferredFontForTextStyle(_:))) {
            self.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        } else {
            self.font = UIFont.systemFontOfSize(15)
        }
        
        let successImage: UIImage = self.loadImage("success.png")
        let errorImage: UIImage = self.loadImage("error.png")
        
        if UIImage.instancesRespondToSelector(#selector(UIImage.imageWithRenderingMode(_:))) {
            self.successImage = successImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            self.errorImage = errorImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        } else {
            self.successImage = successImage
            self.errorImage = errorImage
        }
        
        self.cornerRadius = 14.0
        self.minDismissTimeInterval = 5.0
        
        // 注册通知
        self.registerNotification()
        
        self.isInitializing = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:-----singleTon-----
    
    class var sharedView: CEProgressHUD {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CEProgressHUD? = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = CEProgressHUD(frame: UIScreen.mainScreen().bounds)
        }
        return Static.instance!
    }
    
    // MARK:------show function(progress/indicator)------
    
    class func show() {
        showWithStatus(nil)
    }
    
    class func showWithStatus(status: String?) {
        showWithStatus(status, maskType: nil, hudStyle: nil)
    }
    
    class func showWithStatus(status: String?, maskType: CEProgressHUDMaskType?) {
        showWithStatus(status, maskType: maskType, hudStyle: nil)
    }
    
    class func showWithStatus(status: String?, hudStyle: CEProgressHUDStyle?) {
        showWithStatus(status, maskType: nil, hudStyle: hudStyle)
    }
    
    class func showWithStatus(status: String?, maskType: CEProgressHUDMaskType?, hudStyle: CEProgressHUDStyle?) {
        showProgress(progress: -1, status: status, maskType: maskType, hudStyle: hudStyle)
    }
    
    // master showProgress
    private class func showProgress(progress progress: CGFloat?, status: String?, maskType: CEProgressHUDMaskType?, hudStyle: CEProgressHUDStyle?) {
        if let type = maskType {
            self.sharedView.setDefaultMaskType(type)
        }
        if let style = hudStyle {
            self.sharedView.setDefaultHUDStyle(style)
        }
        self.sharedView.showProgress(progress: progress, status: status)
    }
    
    // MARK:-----show info(success/error)-----
    // success
    class func showSuccessWithStatus(status: String?) {
        showSuccessWithStatus(status, maskType: nil, hudStyle: nil)
    }
    
    class func showSuccessWithStatus(status: String?, maskType: CEProgressHUDMaskType?) {
        showSuccessWithStatus(status, maskType: maskType, hudStyle: nil)
    }
    
    class func showSuccessWithStatus(status: String?, hudStyle: CEProgressHUDStyle?) {
        showSuccessWithStatus(status, maskType: nil, hudStyle: hudStyle)
    }
    
    class func showSuccessWithStatus(status: String?, maskType: CEProgressHUDMaskType?, hudStyle: CEProgressHUDStyle?) {
        showImage(self.sharedView.successImage!, status: status, maskType: maskType, hudStyle: hudStyle)
    }
    
    // error
    class func showErrorWithStatus(status: String?) {
        showErrorWithStatus(status, maskType: nil, hudStyle: nil)
    }
    
    class func showErrorWithStatus(status: String?, maskType: CEProgressHUDMaskType?) {
        showErrorWithStatus(status, maskType: maskType, hudStyle: nil)
    }
    
    class func showErrorWithStatus(status: String?, hudStyle: CEProgressHUDStyle?) {
        showErrorWithStatus(status, maskType: nil, hudStyle: hudStyle)
    }
    
    class func showErrorWithStatus(status: String?, maskType: CEProgressHUDMaskType?, hudStyle: CEProgressHUDStyle?) {
        showImage(self.sharedView.errorImage!, status: status, maskType: maskType, hudStyle: hudStyle)
    }
    
    // master showImage
    class func showImage(image: UIImage, status: String?, maskType: CEProgressHUDMaskType?, hudStyle: CEProgressHUDStyle?) {
        if let type = maskType {
            self.sharedView.setDefaultMaskType(type)
        }
        if let style = hudStyle {
            self.sharedView.setDefaultHUDStyle(style)
        }
        var duration: NSTimeInterval = 0.0
        if let string = status {
            duration = self.displayDurationForString(string)
        }
        if duration == 0.0 {
            duration = 1.0
        }
        self.sharedView.showImage(image, status: status, duration: duration)
    }
    
    // MARK:-----Master show/dismiss function-----
    // 转圈的指示器/进度条
    private func showProgress(progress progress: CGFloat?, status: String?) {
        weak var weakSelf: CEProgressHUD? = self
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            let strongSelf: CEProgressHUD? = weakSelf
            if strongSelf != nil {
                // 更新视图层次使HUD可见
                strongSelf?.updateViewHierachy()
                // 显示不同的指示器
                if strongSelf?.indicatorStyle == CEProgressHUDIndicatorStyle.system {
                    // 将imageView隐藏
                    strongSelf?.getImageView().hidden = true
                    strongSelf?.getImageView().image = nil
                    strongSelf?.getImageView().animationImages = nil
                    // 更新指示器
                    let tintColor = strongSelf?.foregroundColorForStyle()
                    strongSelf?.getIndicator().color = tintColor
                    strongSelf?.getIndicator().startAnimating()
                } else if strongSelf?.indicatorStyle == CEProgressHUDIndicatorStyle.default1 {
                    // 将imageView隐藏
                    strongSelf?.getImageView().hidden = false
                    strongSelf?.getImageView().image = nil
                    // 系统指示器停止转动
                    strongSelf?.getIndicator().stopAnimating()
                    // 添加动画图片数组
                    strongSelf?.getImageView().animationImages = [(strongSelf?.loadImage("Load_the_insets1.png"))!, (strongSelf?.loadImage("Load_the_insets2.png"))!, (strongSelf?.loadImage("Load_the_insets3.png"))!, (strongSelf?.loadImage("Load_the_insets4.png"))!]
                    // 开始动画
                    strongSelf?.getImageView().startAnimating()
                } else if strongSelf?.indicatorStyle == CEProgressHUDIndicatorStyle.custom {
                    // 将imageView隐藏
                    strongSelf?.getImageView().hidden = false
                    strongSelf?.getImageView().image = nil
                    // 系统指示器停止转动
                    strongSelf?.getIndicator().stopAnimating()
                    // 添加动画图片数组
                    strongSelf?.getImageView().animationImages = self.animationImages
                    // 开始动画
                    strongSelf?.getImageView().startAnimating()
                }
                // 设置文字
                strongSelf?.getStatusLabel().text = status
                // show
                strongSelf?.showStatus(status)
            }
        }
    }
    
    // 显示图片（success/error）
    private func showImage(image: UIImage, status: String?, duration: NSTimeInterval) {
        weak var weakSelf: CEProgressHUD? = self
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            let strongSelf: CEProgressHUD? = weakSelf!
            if strongSelf != nil {
                // 保证HUD可见
                strongSelf?.updateViewHierachy()
                // 取消正在运行的动画
                strongSelf?.getIndicator().stopAnimating()
                strongSelf?.getImageView().stopAnimating()
                // 显示图片
                let tintColor = strongSelf?.foregroundColorForStyle()
                var tintedImage = image
                if strongSelf?.getImageView().respondsToSelector(Selector("setTintColor:")) == true {
                    if tintedImage.renderingMode != UIImageRenderingMode.AlwaysTemplate {
                        tintedImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    }
                    strongSelf?.getImageView().tintColor = tintColor
                } else {
                    tintedImage = (strongSelf?.getImage(image, tintColor: tintColor!))!
                }
                strongSelf?.getImageView().animationImages = nil
                strongSelf?.getImageView().image = tintedImage
                strongSelf?.getImageView().hidden = false
                // 更新文字
                strongSelf?.getStatusLabel().text = status
                // show
                strongSelf?.showStatus(status)
                // duration之后消失
                strongSelf?.fadeOutTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(CEProgressHUD.dismiss), userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer((strongSelf?.fadeOutTimer)!, forMode: NSRunLoopCommonModes)
            }
        }
    }
    
    // 最终的显示方法
    private func showStatus(status: String?) {
        // 更新HUD的frame
        self.updateHUDFrame()
        // 添加Motion Effect效果
        self.updateMotionEffect()
        // 更新背景Mask
        self.updateMask()
        // 是否能与用户交互
        if self.hudInteractionEnable == true {
            self.getOverlayView().userInteractionEnabled = false
        } else {
            self.getOverlayView().userInteractionEnabled = true
        }
        //
        if self.alpha != 1.0 || self.getHudView().alpha != 1.0 {
            self.getHudView().transform = CGAffineTransformScale(self.getHudView().transform, 1.3, 1.3)
            
            self.alpha = 0.0
            self.getHudView().alpha = 0.0
            // 动画缩放
            weak var weakSelf: CEProgressHUD? = self
            UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    let strongSelf: CEProgressHUD = weakSelf!
                    strongSelf.getHudView().transform = CGAffineTransformScale(strongSelf.getHudView().transform, 1.0 / 1.3, 1.0 / 1.3)
                    strongSelf.alpha = 1.0
                    strongSelf.getHudView().alpha = 1.0
                }, completion: { (finished: Bool) -> Void in
                    
            })
        }
    }
    
    class func dismiss() {
        self.sharedView.dismiss()
    }
    
    func dismiss() {
        dismissWithDelay(0)
    }
    
    private func dismissWithDelay(delay: NSTimeInterval) {
        weak var weakSelf: CEProgressHUD? = self
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            let strongSelf: CEProgressHUD? = weakSelf
            if strongSelf != nil {
                if self.alpha != 0.0 || self.getHudView().alpha != 0.0 {
                    UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                        strongSelf?.getHudView().transform = CGAffineTransformScale((strongSelf?.getHudView().transform)!, 0.8, 0.8)
                        strongSelf?.alpha = 0.0
                        strongSelf?.getHudView().alpha = 0.0
                        }, completion: { (finished: Bool) -> Void in
                            // 消失后要将HUD的transform还原
                            strongSelf?.getHudView().transform = CGAffineTransformIdentity
                            //
                            strongSelf?.getOverlayView().removeFromSuperview()
                            strongSelf?.getHudView().removeFromSuperview()
                            strongSelf?.removeFromSuperview()
                            //
                            strongSelf?.getIndicator().stopAnimating()
                    })
                }
            }
        }
    }
    
    // MARK:-----getter/setter-----
    // getter
    private func getOverlayView() ->UIControl {
        if overlayView == nil {
            let _overlayView: UIControl = UIControl(frame: CGRectZero)
            _overlayView.backgroundColor = UIColor.clearColor()
            overlayView = _overlayView
        }
        return overlayView!
    }
    
    private func getHudView() ->UIView {
        if hudView == nil {
            let _hudView: UIView = UIView(frame: CGRectZero)
            _hudView.layer.masksToBounds = true
            _hudView.layer.cornerRadius = self.cornerRadius!
            hudView = _hudView
        }
        // 放在括号外面用来更新背景色
        hudView!.backgroundColor = self.backgroundColorForStyle()
        
        return hudView!
    }
    
    private func getStatusLabel() ->UILabel {
        if statusLabel == nil {
            let _statusLabel = UILabel(frame: CGRectZero)
            _statusLabel.backgroundColor = UIColor.clearColor()
            _statusLabel.adjustsFontSizeToFitWidth = true
            _statusLabel.textAlignment = NSTextAlignment.Center
            _statusLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
            _statusLabel.numberOfLines = 0
            statusLabel = _statusLabel
        }
        // 放在括号外面用来更新字体和颜色
        statusLabel!.font = self.font
        statusLabel!.textColor = self.foregroundColorForStyle()
        return statusLabel!
    }
    
    private func getImageView() ->UIImageView {
        if imageView == nil {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            imageView = _imageView
            imageView?.animationDuration = 0.5 // 动画时长
        }
        return imageView!
    }
    
    private func getIndicator() ->UIActivityIndicatorView {
        if indicator == nil {
            let _indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            indicator = _indicator
        }
        return indicator!
    }
    
    // setter
    // 设置遮罩层类型
    class func setDefaultMaskType(maskType: CEProgressHUDMaskType) {
        self.sharedView.setDefaultMaskType(maskType)
    }
    // 设置HUD的样式
    class func setDefaultHUDStyle(hudStyle: CEProgressHUDStyle) {
        self.sharedView.setDefaultHUDStyle(hudStyle)
    }
    // 设置指示器的样式
    class func setIndicatorStyle(indicatorStyle: CEProgressHUDIndicatorStyle) {
        self.sharedView.setIndicatorStyle(indicatorStyle)
    }
    // 设置自定义动画使用的图片数组
    class func setAnimationImages(images: [UIImage]) {
        self.sharedView.setAnimationImages(images)
    }
    // 设置label的字体
    class func setLabelFont(font: UIFont) {
        self.sharedView.setLabelFont(font)
    }
    
    // 设置HUD能否与用户交互
    class func setHUDInteractionEnable(hudInteractionEnable: Bool) {
        self.sharedView.setHUDInteractionEnable(hudInteractionEnable)
    }
    
    // MARK:-----UIAppearance Setters-----
    
    private func setDefaultMaskType(maskType: CEProgressHUDMaskType) {
        if self.isInitializing == false {
            self.defaultMaskType = maskType
        }
    }
    
    private func setDefaultHUDStyle(hudStyle: CEProgressHUDStyle) {
        if self.isInitializing == false {
            self.defaultStyle = hudStyle
        }
    }
    
    private func setIndicatorStyle(indicatorStyle: CEProgressHUDIndicatorStyle) {
        if self.isInitializing == false {
            self.indicatorStyle = indicatorStyle
        }
    }
    
    private func setAnimationImages(images: [UIImage]) {
        if self.isInitializing == false {
            self.animationImages = images
        }
    }
    
    private func setLabelFont(font: UIFont) {
        if self.isInitializing == false {
            self.getStatusLabel().font = font
        }
    }
    
    private func setHUDInteractionEnable(hudInteractionEnable: Bool) {
        if self.isInitializing == false {
            self.hudInteractionEnable = hudInteractionEnable
        }
    }
    
    // MARK:-----UI update-----
    
    private func updateViewHierachy() {
        // overlayView
        if self.getOverlayView().superview == nil {
            UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView!)
        } else {
            self.getOverlayView().superview?.bringSubviewToFront(self.overlayView!)
        }
        // self
        if self.superview == nil {
            self.getOverlayView().addSubview(self)
        }
        // hudView
        if self.getHudView().superview == nil {
            self.addSubview(self.getHudView())
        }
        // statusLabel
        if self.getStatusLabel().superview == nil {
            self.getHudView().addSubview(self.getStatusLabel())
        }
        // imageView
        if self.getImageView().superview == nil {
            self.getHudView().addSubview(self.getImageView())
        }
        // indicator
        if self.getIndicator().superview == nil {
            self.getHudView().addSubview(self.getIndicator())
        }
    }
    
    // 更新HUD的frame
    private func updateHUDFrame() {
        var hudWidth: CGFloat = 100
        var hudHeight: CGFloat = 100
        let stringAndContentHeightBuffer: CGFloat = 80.0
        let stringHeightBuffer: CGFloat = 20.0
        var labelRect: CGRect = CGRectZero
        // 判断一下当前显示的indicator还是imageView
        let imageUsed: Bool = (self.getImageView().image != nil || self.getImageView().animationImages != nil) && self.getImageView().hidden == false
        let indicatorUsed: Bool = self.getImageView().hidden == true
        // 计算文本的size，然后更新HUD的size
        let string: String? = self.getStatusLabel().text
        if string != nil {
            let constraintSize: CGSize = CGSize(width: 200, height: 300)
            var stringRect: CGRect?
            let ocStr: NSString = NSString(string: string!)
            stringRect = ocStr.boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.getStatusLabel().font], context: nil)
            let stringWidth: CGFloat = (stringRect?.size.width)!
            let stringHeight: CGFloat = (stringRect?.size.height)!
            
            if imageUsed || indicatorUsed {
                hudHeight = stringAndContentHeightBuffer + stringHeight
            } else {
                hudHeight = stringHeightBuffer + stringHeight
            }
            if stringWidth > hudWidth {
                hudWidth = stringWidth
            }
            let labelRectY: CGFloat = (imageUsed || indicatorUsed) ? 68.0 : 9.0
            if hudHeight > 100 {
                labelRect = CGRectMake(12.0, labelRectY, hudWidth, stringHeight);
                hudWidth += 24.0;
            } else {
                hudWidth += 24.0;
                labelRect = CGRectMake(0.0, labelRectY, hudWidth, stringHeight);
            }
        }
        // overlayView
        self.getOverlayView().frame = UIScreen.mainScreen().bounds
        // self
        self.frame = self.getOverlayView().bounds
        // Hud
        self.getHudView().bounds = CGRect(x: 0, y: 0, width: hudWidth, height: hudHeight)
        self.getHudView().center = self.center
        // imageView/indicator
        if string != nil {
            self.getImageView().center = CGPoint(x: hudWidth * 0.5, y: 36.0)
            self.getIndicator().center = CGPoint(x: hudWidth * 0.5, y: 36.0)
        } else {
            self.getImageView().center = CGPoint(x: hudWidth * 0.5, y: hudHeight * 0.5)
            self.getIndicator().center = CGPoint(x: hudWidth * 0.5, y: hudHeight * 0.5)
        }
        // statusLabel
        self.getStatusLabel().hidden = false
        self.getStatusLabel().frame = labelRect
    }
    
    // 更新遮罩层
    private func updateMask() {
        if self.backgroundLayer != nil {
            self.backgroundLayer?.removeFromSuperlayer()
            self.backgroundLayer = nil
        }
        if self.defaultMaskType == CEProgressHUDMaskType.black { // black
            self.backgroundLayer = CALayer()
            self.backgroundLayer?.frame = self.bounds
            self.backgroundLayer?.backgroundColor = UIColor(white: 0, alpha: 0.4).CGColor
            self.layer.insertSublayer(self.backgroundLayer!, atIndex: 0)
            return
        }
        if self.defaultMaskType == CEProgressHUDMaskType.gradient { // gradient
            let layer: CERadialGradientLayer = CERadialGradientLayer()
            layer.frame = self.bounds
            layer.gradientCenter = self.center
            
            // 重新调用"drawInContext"
            layer.setNeedsDisplay()
            
            self.backgroundLayer = layer
            self.layer.insertSublayer(self.backgroundLayer!, atIndex: 0)
            return
        }
    }
    
    // 添加Motion Effect效果
    private func updateMotionEffect() {
        if self.getHudView().respondsToSelector(#selector(UIView.addMotionEffect(_:))) {
            let effectX: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
            effectX.minimumRelativeValue = -parallaxDepthPoints
            effectX.maximumRelativeValue = parallaxDepthPoints
            
            let effectY: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
            effectY.minimumRelativeValue = -parallaxDepthPoints
            effectY.maximumRelativeValue = parallaxDepthPoints
            
            let effectMotionGroup = UIMotionEffectGroup()
            effectMotionGroup.motionEffects = [effectX, effectY]
            
            self.getHudView().motionEffects = []
            self.getHudView().addMotionEffect(effectMotionGroup)
        }
    }
    
    // MARK:-----Utility tool function-----
    // 根据文字长度返回显示的时长
    private class func displayDurationForString(string: String) ->NSTimeInterval {
        return Double(string.characters.count) * 0.06 + 0.5
    }
    
    private func foregroundColorForStyle() ->UIColor {
        if self.defaultStyle == CEProgressHUDStyle.light {
            return UIColor.blackColor()
        } else if self.defaultStyle == CEProgressHUDStyle.dark {
            return UIColor.whiteColor()
        }
        return UIColor.blackColor()
    }
    
    private func backgroundColorForStyle() ->UIColor {
        if self.defaultStyle == CEProgressHUDStyle.light {
            return UIColor.whiteColor()
        } else if self.defaultStyle == CEProgressHUDStyle.dark {
            return UIColor.blackColor()
        }
        return UIColor.whiteColor()
    }
    
    private func getImage(image: UIImage, tintColor: UIColor) ->UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        let c = UIGraphicsGetCurrentContext()
        image.drawInRect(rect)
        CGContextSetFillColorWithColor(c, tintColor.CGColor)
        CGContextSetBlendMode(c, CGBlendMode.SourceAtop)
        CGContextFillRect(c, rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
    
    private func loadImage(imageName: String) ->UIImage {
        let imageBundleURL: NSURL? = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent("CEProgressHUD.bundle")
        let imageBundle: NSBundle? = NSBundle(URL: imageBundleURL!)
        
        let image: UIImage = UIImage(contentsOfFile: (imageBundle?.pathForResource("image/\(imageName)", ofType: nil))!)!
        
        return image
    }
    
    // MARK:-----Notification-----
    
    private func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CEProgressHUD.statusBarOrientationDidChange(_:)), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    private func unRegisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK:-----Event response-----
    
    func statusBarOrientationDidChange(notification: NSNotification) {
        self.updateViewHierachy()
        self.updateHUDFrame()
        self.updateMask()
    }
    
    // MARK:-----deinit-----
    
    deinit {
        self.unRegisterNotification()
    }
    
}
