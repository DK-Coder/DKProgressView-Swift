//
//  ViewController.swift
//  DKProgressView-Swift
//
//  Created by xuli on 2016/12/22.
//  Copyright © 2016年 dk-coder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var arrayProgressView: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.lightGray
        
        addButtonArea()
        resetProgressView()
        addMoveAnimationOnProgressView()
    }
    
    func addButtonArea() {
        let buttonArea: UIView = UIView(frame: CGRect(x: 0.0, y: 64.0, width: view.frame.size.width, height: 60.0))
        buttonArea.backgroundColor = UIColor.white
        view.addSubview(buttonArea)
        
        let widthForButton: CGFloat = (view.frame.size.width - CGFloat(30.0)) / CGFloat(2.0)
        let btnReset: UIButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: widthForButton, height: 40.0))
        btnReset.setTitle("重置控件", for: .normal)
        btnReset.setTitleColor(UIColor.orange, for: .normal)
        btnReset.layer.cornerRadius = 10.0
        btnReset.layer.borderWidth = 2.0
        btnReset.layer.borderColor = UIColor.orange.cgColor
        btnReset.addTarget(self, action: #selector(resetProgressView), for: .touchUpInside)
        buttonArea.addSubview(btnReset)
        
        let btnStartAnimation: UIButton = UIButton(frame: CGRect(x: 20.0 + widthForButton, y: 10.0, width: widthForButton, height: btnReset.frame.height))
        btnStartAnimation.setTitle("开始动画", for: .normal)
        btnStartAnimation.setTitleColor(UIColor.orange, for: .normal)
        btnStartAnimation.layer.cornerRadius = 10.0
        btnStartAnimation.layer.borderWidth = 2.0
        btnStartAnimation.layer.borderColor = UIColor.orange.cgColor
        btnStartAnimation.addTarget(self, action: #selector(addMoveAnimationOnProgressView), for: .touchUpInside)
        buttonArea.addSubview(btnStartAnimation)
    }
    
    func resetProgressView() {
        
        if arrayProgressView.count != 0 {
            arrayProgressView.removeAllObjects()
        }
        
        for view in view.subviews {
            if view.isKind(of: DKProgressView.self) {
                view.removeFromSuperview()
            }
        }
        
        for i in 0 ..< 4 {
            let frame: CGRect = CGRect(x: 0.0, y: 64.0 + 60.0 * CGFloat(i + 1) + 10.0, width: view.frame.width, height: 60.0)
            let progressView: DKProgressView = DKProgressView(frame: frame)
            progressView.dk_CircleTotalNumber = i + 5
            progressView.dk_CircleCompletedNumber = i + 1
            arrayProgressView.add(progressView)
            view.addSubview(progressView)
        }
        
        for i in 0 ..< 4 {
            let offsetY: CGFloat = 60.0 * CGFloat(i + 1)
            let frame: CGRect = CGRect(x: 0.0, y: 64.0 + 60.0 * 4 + 20.0 + offsetY, width: view.frame.width, height: 60.0)
            let progressView: DKProgressView = DKProgressView(TextBelowWithframe: frame, totalNumber: i + 5, completedNumber: i)
            arrayProgressView.add(progressView)
            view.addSubview(progressView)
        }
    }
    
    func addMoveAnimationOnProgressView() {
        
        for progressView in arrayProgressView {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { 
                let progress: DKProgressView = progressView as! DKProgressView
                progress.moveTo(completedNumber: progress.dk_CircleCompletedNumber + 2, animated: progress.dk_CircleCompletedNumber % 2 == 0)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

