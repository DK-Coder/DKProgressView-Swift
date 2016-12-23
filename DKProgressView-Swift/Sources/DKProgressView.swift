//
//  DKProgressView.swift
//  DKProgressView-Swift
//
//  Created by xuli on 2016/12/22.
//  Copyright © 2016年 dk-coder. All rights reserved.
//

import UIKit

enum DKProgressType {
    case OnlyCircle
    case WithTextBelow
}

class DKProgressView: UIView {

    var dk_CompletedFilledColor: UIColor
    var dk_CircleTotalNumber: Int
    var dk_CircleCompletedNumber: Int
    var dk_lineWidth: Float
    var dk_animationDuration: Float {
        get {
            return 0.8
        }
    }
    /**
     * 当进度图类型为DKProgressTypeWithTextBelow时需要设置的参数。
     * 如果为空，将显示默认文字（步骤1，步骤2。。。）
     */
    var dk_arrayTitles: NSArray?
    
    private var progressType: DKProgressType
    private var widthForCircle: Float
    private var widthForLine: Float
    private var arrayCircles: NSMutableArray
    private var arrayLines: NSMutableArray
    private var arrayTextLayers: NSMutableArray?
    private var toDoFilledColor: UIColor
    
    override init(frame: CGRect) {
        dk_CompletedFilledColor = UIColor.red
        dk_CircleTotalNumber = 3
        dk_CircleCompletedNumber = 1
        dk_lineWidth = 8.0
        
        progressType = .OnlyCircle
        widthForCircle = 0.0
        widthForLine = 0.0
        arrayCircles = NSMutableArray()
        arrayLines = NSMutableArray()
        toDoFilledColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        
        super.init(frame: frame)
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, progressType type: DKProgressType, totalNumber total: Int, completedNumber completed: Int) {
        self.init(frame: frame)
        
        progressType = type
        dk_CircleTotalNumber = total
        dk_CircleCompletedNumber = completed
    }
    
    convenience init(TextBelowWithframe frame: CGRect, totalNumber total: Int, completedNumber completed: Int) {
        self.init(frame: frame)
        
        progressType = .WithTextBelow
        dk_CircleTotalNumber = total
        dk_CircleCompletedNumber = completed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 一般圆圈最多8个
        dk_CircleTotalNumber = dk_CircleTotalNumber < 8 ? dk_CircleTotalNumber : 8
        // 完成数量最少1个，不能0个
        dk_CircleCompletedNumber = dk_CircleCompletedNumber < 1 ? 1 : dk_CircleCompletedNumber
        // 圆圈的直径，取视图宽度和高度最小值然后减去上下间隔20
        widthForCircle = Float(min(frame.size.width, frame.size.height)) - 20.0
        // 根据圆圈的直径和视图的宽度计算中间线段的长度
        widthForLine = (Float(frame.size.width) - 20.0 - Float(dk_CircleTotalNumber) * widthForCircle) / Float(dk_CircleTotalNumber - 1)
        switch progressType {
        case .OnlyCircle:
            initializeOnlyCircle()
        case .WithTextBelow:
            initializeWithTextBelow()
        }
    }
    
    func moveTo(completedNumber number: Int, animated isAnimated: Bool) {
        // 完成的数量必须小于总数量，并且完成的数量不能等于已经完成的数量
        // 如果总体有8个，完成有9个，则不进行操作
        // 如果完成有8个，需要完成到第8个，那么也不进行操作，因为本身就已经完成了8个。没有变化
        if number <= dk_CircleTotalNumber && number != dk_CircleCompletedNumber {
            if number > dk_CircleCompletedNumber {
                let length = number - dk_CircleCompletedNumber
                if isAnimated {
                    for i in 0 ..< length {
                        // 获取某个圆形图层
                        let circleLayer: CALayer = arrayCircles[i + dk_CircleCompletedNumber] as! CALayer
                        // 获取某个线段图层
                        let lineLayer: CAShapeLayer = arrayLines[(i + dk_CircleCompletedNumber) * 2 - 1] as! CAShapeLayer
                        lineLayer.strokeColor = dk_CompletedFilledColor.cgColor
                        // 为线段添加动画，从左到右
                        let lineShowAnimation = generateStrokeEndAnimation()
                        lineLayer.add(lineShowAnimation, forKey: nil)
                        // 为圆圈添加动画
                        let circleContentsAnimation = generateContentsAnimationBaseOn(lineShowAnimation)
                        circleLayer.add(circleContentsAnimation, forKey: nil)
                        if progressType == .WithTextBelow {
                            let textLayer: CATextLayer = arrayTextLayers![i + dk_CircleCompletedNumber] as! CATextLayer
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + lineShowAnimation.duration, execute: { 
                                textLayer.foregroundColor = self.dk_CompletedFilledColor.cgColor
                            })
//                            let changeColorAnimation = CABasicAnimation(keyPath: "foregroundColor")
//                            changeColorAnimation.toValue = dk_CompletedFilledColor.cgColor
//                            changeColorAnimation.beginTime = lineShowAnimation.duration + CACurrentMediaTime()
//                            changeColorAnimation.duration = circleContentsAnimation.duration
//                            changeColorAnimation.fillMode = kCAFillModeForwards
//                            changeColorAnimation.isRemovedOnCompletion = false
//                            textLayer.add(changeColorAnimation, forKey: nil)
                        }
                    }
                } else {
                    for i in 0 ..< length {
                        let circleLayer: CALayer = arrayCircles[i + dk_CircleCompletedNumber] as! CALayer
                        circleLayer.contents = UIImage(named: "Resources.bundle/OK_Filled.png")!.changeColorTo(dk_CompletedFilledColor).cgImage
                        let lineLayer: CAShapeLayer = arrayLines[(i + dk_CircleCompletedNumber) * 2 - 1] as! CAShapeLayer
                        lineLayer.strokeColor = dk_CompletedFilledColor.cgColor
                        if progressType == .WithTextBelow {
                            let textLayer: CATextLayer = arrayTextLayers![i + dk_CircleCompletedNumber] as! CATextLayer
                            textLayer.foregroundColor = dk_CompletedFilledColor.cgColor
                        }
                    }
                }
            }
        }
        
        dk_CircleCompletedNumber = number
    }
    
    private func sharedInit() {
        
        backgroundColor = UIColor.white
    }
    
    private func initializeOnlyCircle() {
        for i in 0 ..< dk_CircleTotalNumber {
            let circleLayer = CALayer()
            if i < dk_CircleCompletedNumber {
                circleLayer.contents = UIImage(named: "Resources.bundle/OK_Filled.png")!.changeColorTo(dk_CompletedFilledColor).cgImage
            } else {
                circleLayer.contents = UIImage(named: "Resources.bundle/OK_Filled.png")!.cgImage
            }
            circleLayer.frame = CGRect(x: CGFloat(10.0) + CGFloat(widthForCircle + widthForLine - 2.0) * CGFloat(i), y: CGFloat(10.0), width: CGFloat(widthForCircle), height: CGFloat(widthForCircle))
            circleLayer.masksToBounds = true
            arrayCircles.add(circleLayer)
            layer.addSublayer(circleLayer)
            // 添加线段
            if i != dk_CircleTotalNumber - 1 {
                let isCompleted: Bool = dk_CircleCompletedNumber - i > 1 ? true : false
                let grayLineLayer = generateLineLayerNextToLayer(circleLayer, isCompleted: false)
                let lineLayer = generateLineLayerNextToLayer(circleLayer, isCompleted: isCompleted)
                arrayLines.add(grayLineLayer)
                arrayLines.add(lineLayer)
                layer.insertSublayer(lineLayer, below: circleLayer)
                layer.insertSublayer(grayLineLayer, below: lineLayer)
            }
        }
    }
    
    private func initializeWithTextBelow() {
        
        if dk_CircleTotalNumber != 3 && (dk_arrayTitles == nil || dk_arrayTitles?.count == 0) {
            let array = NSMutableArray()
            for i in 0 ..< dk_CircleTotalNumber {
                array.add(String(format: "步骤%d", i))
            }
            dk_arrayTitles = array
        }
        
        assert(dk_arrayTitles!.count == dk_CircleTotalNumber, "所提供的下方文字个数与圆圈总个数不相同，请检查后继续！")
        
        arrayTextLayers = NSMutableArray()
        for i in 0 ..< dk_CircleTotalNumber {
            let circleLayer = CALayer()
            if i < dk_CircleCompletedNumber {
                circleLayer.contents = UIImage(named: "Resources.bundle/OK_Filled.png")!.changeColorTo(dk_CompletedFilledColor).cgImage
            } else {
                circleLayer.contents = UIImage(named: "Resources.bundle/OK_Filled.png")!.cgImage
            }
            circleLayer.frame = CGRect(x: CGFloat(10.0) + CGFloat(widthForCircle + widthForLine - 2.0) * CGFloat(i), y: CGFloat(0.0), width: CGFloat(widthForCircle), height: CGFloat(widthForCircle))
            circleLayer.masksToBounds = true
            arrayCircles.add(circleLayer)
            layer.addSublayer(circleLayer)
            // 添加线段
            if i != dk_CircleTotalNumber - 1 {
                let isCompleted: Bool = dk_CircleCompletedNumber - i > 1 ? true : false
                let grayLineLayer = generateLineLayerNextToLayer(circleLayer, isCompleted: false)
                let lineLayer = generateLineLayerNextToLayer(circleLayer, isCompleted: isCompleted)
                arrayLines.add(grayLineLayer)
                arrayLines.add(lineLayer)
                layer.insertSublayer(lineLayer, below: circleLayer)
                layer.insertSublayer(grayLineLayer, below: lineLayer)
            }
            // 添加文字图层
            let textLayer = CATextLayer()
            textLayer.frame = CGRect(x: circleLayer.frame.origin.x, y: frame.size.height - CGFloat(20.0), width: circleLayer.frame.size.width, height: CGFloat(20.0))
            textLayer.string = dk_arrayTitles![i]
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.foregroundColor = i < dk_CircleCompletedNumber ? dk_CompletedFilledColor.cgColor : toDoFilledColor.cgColor
            textLayer.fontSize = 14.0
            textLayer.alignmentMode = kCAAlignmentCenter
            arrayTextLayers?.add(textLayer)
            layer.addSublayer(textLayer)
        }
    }
    
    
    
    private func generateLineLayerNextToLayer(_ layer: CALayer, isCompleted completed: Bool) -> CAShapeLayer {
        let pathLine = UIBezierPath()
        pathLine.move(to: CGPoint(x: layer.frame.origin.x + layer.frame.size.width - CGFloat(2.0), y: layer.position.y))
        pathLine.addLine(to: CGPoint(x: layer.frame.origin.x + layer.frame.size.width + CGFloat(widthForLine), y: layer.position.y))
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = pathLine.cgPath
        lineLayer.lineWidth = CGFloat(dk_lineWidth)
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineJoin = kCALineJoinRound
        lineLayer.strokeColor = completed ? dk_CompletedFilledColor.cgColor : toDoFilledColor.cgColor
        lineLayer.strokeStart = 0.0
        lineLayer.strokeEnd = 1.0
        
        return lineLayer
    }
    
    private func generateStrokeEndAnimation() -> CABasicAnimation {
        
        let lineShowAnimation = CABasicAnimation(keyPath: "strokeEnd")
        lineShowAnimation.fromValue = 0.0
        lineShowAnimation.toValue = 1.0
        lineShowAnimation.duration = 0.4
        lineShowAnimation.fillMode = kCAFillModeForwards
        lineShowAnimation.isRemovedOnCompletion = false
        
        return lineShowAnimation
    }
    
    private func generateContentsAnimationBaseOn(_ strokeEndAnimation: CABasicAnimation) -> CABasicAnimation {
        
        let contentsAnimation = CABasicAnimation(keyPath: "contents")
        contentsAnimation.toValue = UIImage(named: "Resources.bundle/OK_Filled.png")?.changeColorTo(dk_CompletedFilledColor).cgImage
        contentsAnimation.beginTime = strokeEndAnimation.duration + CACurrentMediaTime()
        contentsAnimation.duration = strokeEndAnimation.duration
        contentsAnimation.fillMode = kCAFillModeForwards
        contentsAnimation.isRemovedOnCompletion = false
        
        return contentsAnimation
    }
}
