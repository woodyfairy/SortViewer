//
//  CanvasView.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

class CanvasView: UIView {
    //MARK:- Options
    var pointSize : CGFloat = 10
    var fadeScale : CGFloat = 0.85
    var padding : UIEdgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
    var sortStepTime : TimeInterval = 0.01
    
    
    //MARK:- TouchTest
    let TouchTest : Bool = false
    var testPoint : Point = Point(value: 0, pos: CGPoint.zero, color: .red) //test
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if TouchTest, let t = touches.first {
            let pos = t.location(in: self)
            testPoint.animteTo(pos)
        }
    }
    
    //MARK:- Sort Data
    var listPoints : [Point] = []
    var minColor : UIColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)
    var maxColor : UIColor = UIColor(red: 1, green: 0.3, blue: 0.1, alpha: 1)
    func reset(number : Int = 30) {
        stop()
        if TouchTest {
            isRunning = true //默认开始
            testPoint.resetPos(pos: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
        }
        //生成
        for i in 0..<number {
            let percent : CGFloat = CGFloat(i) / CGFloat(number-1)
            let p = Point(value: i, pos: CGPoint.zero, color: lerpColor(startColor: minColor, endColor: maxColor, weight: percent))
            listPoints.append(p)
            
            let view = UIView()
            view.layer.cornerRadius = pointSize/2
            self.addSubview(view)
        }
        //打乱
        listPoints.shuffle()
        
        //位置
        for i in 0..<number {
            let p = listPoints[i]
            p.preIndex = i //重置index
            p.resetPos(pos: getPos(index: i, value: p.value))
        }
        self.setNeedsDisplay() //初次绘制
    }
    private func stop(forStart : Bool = false){
        if !forStart {
            listPoints.removeAll()
        }
        isRunning = false
        curImage = nil
        timer?.invalidate()
        timer = nil
        sortFunction = nil
    }
    private func getPos(index : Int, value : Int) -> CGPoint {
        let number = listPoints.count - 1
        guard number > 0 else {
            return CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        }
        let percent : CGFloat = CGFloat(index) / CGFloat(number)
        let valuePerent : CGFloat = CGFloat(value) / CGFloat(number)
        return CGPoint(x: padding.left + (self.bounds.width - padding.left - padding.right) * percent, y: self.bounds.height - padding.bottom - (self.bounds.height - padding.top - padding.bottom) * valuePerent)
    }
    
    //start sort
    private var timer : Timer? = nil
    private var sortFunction : SortBase<Point>? = nil
    func startRunning<T : SortBase<Point>>(sortFunctionType : T.Type, showChecking : Bool = false) {
        stop(forStart: true)
        isRunning = true
        
        sortFunction = sortFunctionType.init(dataList: self.listPoints, showChecking: showChecking)
        sortFunction?.start()
        
        timer = Timer(timeInterval: sortStepTime, target: self, selector: #selector(nextStep), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    @objc private func nextStep(){
        if self.superview == nil {
            stop()
            return
        }
        //print("next")
        if let sortFunction = sortFunction {
            if sortFunction.isFinished {
                timer?.invalidate()
                timer = nil
                //这里不能直接stop，否则不会有减隐
            }
            
            listPoints = sortFunction.nextStep() //更新数组
            for i in 0..<listPoints.count {
                let p = listPoints[i]
                if p.preIndex != i {
                    p.preIndex = i
                    p.animteTo(getPos(index: i, value: p.value)) 
                }
            }
        }
    }
    
    
    
    //MARK:- Display
    private var displayLink : CADisplayLink? = nil //这个不会自动释放
    private var curImage : UIImage?
    
    var isRunning = false //表示是否在绘制中(算法开始，绘制同时开始；算法结束，绘制不会结束)
    {
        didSet {
            if isRunning {
                if displayLink == nil {
                    displayLink = CADisplayLink(target: self, selector: #selector(update))
                    //displayLink?.preferredFramesPerSecond = 30
                    displayLink?.add(to: RunLoop.main, forMode: .common)
                }
            }else {
                //displayLink?.remove(from: RunLoop.main, forMode: .common)
                displayLink?.invalidate() //包含了remove from RunLoop
                displayLink = nil
            }
        }
    }
    
    @objc private func update(){
        if self.superview == nil {
            stop()
            return
        }
        
        if TouchTest {
            testPoint.update()
        }
        
        for point in listPoints {
            point.update()
        }
        
        self.setNeedsDisplay()
        
        //记录当前画面
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            self.layer.render(in: ctx)
            self.curImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setLineWidth(pointSize)
            ctx.setLineCap(.round)
            
            self.curImage?.draw(at: CGPoint.zero, blendMode: .normal, alpha: fadeScale)
            
            if TouchTest {
                if (distance(p1: testPoint.prePos, p2: testPoint.currentPos) <= pointSize/4) {
                    ctx.move(to: testPoint.prePos)
                    ctx.addLine(to: testPoint.currentPos)
                    ctx.setStrokeColor(testPoint.color.cgColor)
                    ctx.strokePath()
                }else{
                    let a = pointSize/2
                    ctx.saveGState()
                    //path
                    let rad = atan2(testPoint.currentPos.y - testPoint.prePos.y, testPoint.currentPos.x - testPoint.prePos.x) //顺时针方向
//                    print(rad)
                    
                    ctx.move(to: testPoint.prePos - CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addArc(center: testPoint.prePos, radius: a, startAngle: rad + .pi/2, endAngle: rad - .pi/2, clockwise: true)
//                    ctx.addLine(to: point.prePos + CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addLine(to: testPoint.currentPos + CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addArc(center: testPoint.currentPos, radius: a, startAngle: rad - .pi/2, endAngle: rad + .pi/2, clockwise: false)
//                    ctx.addLine(to: point.currentPos - CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    
                    ctx.closePath()
                    ctx.clip(using: .winding)
                    //渐变色
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    let locations:[CGFloat] = [0,1]
                    let startC = testPoint.color.withAlphaComponent(fadeScale)
                    let endC = testPoint.color
                    let colors = [startC.cgColor,endC.cgColor]
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
                    ctx.drawLinearGradient(gradient!, start: testPoint.prePos, end: testPoint.currentPos, options: CGGradientDrawingOptions.drawsAfterEndLocation) //需要延伸颜色
                    ctx.restoreGState()
                }
            }
            
            for (i, p) in listPoints.enumerated() {
                if (distance(p1: p.prePos, p2: p.currentPos) <= pointSize/4) {
                    ctx.move(to: p.prePos)
                    ctx.addLine(to: p.currentPos)
                    ctx.setStrokeColor(p.color.cgColor)
                    ctx.strokePath()
                }else{
                    let a = pointSize/2
                    ctx.saveGState()
                    //path
                    let rad = atan2(p.currentPos.y - p.prePos.y, p.currentPos.x - p.prePos.x) //顺时针方向
//                    print(rad)
                    
                    ctx.move(to: p.prePos - CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addArc(center: p.prePos, radius: a, startAngle: rad + .pi/2, endAngle: rad - .pi/2, clockwise: true)
//                    ctx.addLine(to: point.prePos + CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addLine(to: p.currentPos + CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    ctx.addArc(center: p.currentPos, radius: a, startAngle: rad - .pi/2, endAngle: rad + .pi/2, clockwise: false)
//                    ctx.addLine(to: point.currentPos - CGPoint(x: sin(rad) * a, y: -cos(rad) * a))
                    
                    ctx.closePath()
                    ctx.clip(using: .winding)
                    //渐变色
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    let locations:[CGFloat] = [0,1]
                    let startC = p.color.withAlphaComponent(fadeScale)
                    let endC = p.color
                    let colors = [startC.cgColor,endC.cgColor]
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
                    ctx.drawLinearGradient(gradient!, start: p.prePos, end: p.currentPos, options: CGGradientDrawingOptions.drawsAfterEndLocation) //需要延伸颜色
                    ctx.restoreGState()
                }
                
                //checking
                if i == sortFunction?.checkingIndex || i == sortFunction?.currentCheck {
                    ctx.addArc(center: p.currentPos, radius: pointSize, startAngle: 0, endAngle: .pi*2, clockwise: true)
                    ctx.setStrokeColor(p.color.cgColor)
                    ctx.setLineWidth(pointSize/4)
                    ctx.strokePath()
                    ctx.setLineWidth(pointSize) //恢复
//                    ctx.setFillColor(p.color.cgColor)
//                    ctx.fillPath()
                }
            }
        }
    }
}

//MARK:- tools
//infix operator +
func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
//infix operator -
func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func lerpColor(startColor : UIColor, endColor : UIColor, weight : CGFloat) -> UIColor {
    var start_R : CGFloat = 0
    var start_G : CGFloat = 0
    var start_B : CGFloat = 0
    var start_A : CGFloat = 0
    startColor.getRed(&start_R, green: &start_G, blue: &start_B, alpha: &start_A)
    
    var end_R : CGFloat = 0
    var end_G : CGFloat = 0
    var end_B : CGFloat = 0
    var end_A : CGFloat = 0
    endColor.getRed(&end_R, green: &end_G, blue: &end_B, alpha: &end_A)
    
    return UIColor(red: start_R + (end_R - start_R) * weight, green: start_G + (end_G - start_G) * weight, blue: start_B + (end_B - start_B) * weight, alpha: start_A + (end_A - start_A) * weight)
    
}

func distance(p1 : CGPoint, p2 : CGPoint) -> CGFloat {
    return sqrt( (p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y) )
}
