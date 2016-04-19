//
//  ViewController.swift
//  CEProgressHUDDemo
//
//  Created by 张延深 on 16/4/12.
//  Copyright © 2016年 宜信. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK:button click
    @IBAction func show(sender: UIButton) {
        CEProgressHUD.show()
    }
    
    @IBAction func showWithStatus(sender: UIButton) {
        CEProgressHUD.showWithStatus("正在加载，请稍候...")
    }

    @IBAction func showSuccessWithStatus(sender: UIButton) {
        CEProgressHUD.showSuccessWithStatus("加载成功")
    }
    
    @IBAction func showErrorWithStatus(sender: UIButton) {
        CEProgressHUD.showErrorWithStatus("加载失败")
    }
    
    @IBAction func dismiss(sender: UIButton) {
        CEProgressHUD.dismiss()
    }
    
    // MARK:HUD配置
    
    @IBAction func maskTypeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            CEProgressHUD.setDefaultMaskType(CEProgressHUDMaskType.none)
        case 1:
            CEProgressHUD.setDefaultMaskType(CEProgressHUDMaskType.clear)
        case 2:
            CEProgressHUD.setDefaultMaskType(CEProgressHUDMaskType.black)
        case 3:
            CEProgressHUD.setDefaultMaskType(CEProgressHUDMaskType.gradient)
        default:
            CEProgressHUD.setDefaultMaskType(CEProgressHUDMaskType.none)
        }
    }
    
    @IBAction func styleChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            CEProgressHUD.setDefaultHUDStyle(CEProgressHUDStyle.light)
        case 1:
            CEProgressHUD.setDefaultHUDStyle(CEProgressHUDStyle.dark)
        default:
            CEProgressHUD.setDefaultHUDStyle(CEProgressHUDStyle.light)
        }
    }
    
    @IBAction func indicatorStyleChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            CEProgressHUD.setIndicatorStyle(CEProgressHUDIndicatorStyle.system)
        case 1:
            CEProgressHUD.setIndicatorStyle(CEProgressHUDIndicatorStyle.default1)
        case 2:
            CEProgressHUD.setIndicatorStyle(CEProgressHUDIndicatorStyle.custom)
        default:
            CEProgressHUD.setIndicatorStyle(CEProgressHUDIndicatorStyle.system)
        }
    }
    
    @IBAction func interactionEnableChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            CEProgressHUD.setHUDInteractionEnable(false)
        case 1:
            CEProgressHUD.setHUDInteractionEnable(true)
        default:
            CEProgressHUD.setHUDInteractionEnable(false)
        }
    }
    
}

