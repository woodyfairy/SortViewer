//
//  CanvasView.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

class CanvasView: UIView {
    //MARK:- ViewSet
    var pointSize : CGFloat = 10
    var fadeScale : CGFloat = 0.85
    var padding : UIEdgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
    
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
    
    //MARK:- Data
    private var isRunning = false
    var listPoints : [Point] = []
    var minColor : UIColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)
    var maxColor : UIColor = UIColor(red: 1, green: 0.3, blue: 0.1, alpha: 1)
    func reset(number : Int = 100) {
        isRunning = false
        curImage = nil
        listPoints.removeAll()
        //生成
        for i in 0..<number {
            let percent : CGFloat = CGFloat(i) / CGFloat(number-1)
            let p = Point(value: i, pos: CGPoint.zero, color: lerpColor(startColor: minColor, endColor: maxColor, weight: percent))
            listPoints.append(p)
        }
        //打乱
        listPoints.shuffle()
        
        //位置
        for i in 0..<number {
            let p = listPoints[i]
            p.resetPos(pos: getPos(index: i, value: p.value))
        }
        self.setNeedsDisplay() //初次绘制
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
    func startRunning() {
        isRunning = true
    }
    
    
    
    
    //MARK:- Display
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    private var displayLink : CADisplayLink? = nil //这个不可自动释放
    private var curImage : UIImage?
    
    private func initView(){
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        //displayLink?.preferredFramesPerSecond = 30
        displayLink?.add(to: RunLoop.main, forMode: .common)
        
        if TouchTest {
            isRunning = true //默认开始
            testPoint.resetPos(pos: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2))
        }
    }
    
    @objc private func update(){
        if self.superview != nil {
            if !isRunning {
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
        }else{
            displayLink?.invalidate()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setLineWidth(pointSize)
            ctx.setLineCap(.round)
            
            self.curImage?.draw(at: CGPoint.zero, blendMode: .normal, alpha: fadeScale)
            
            if TouchTest {
                if (testPoint.prePos == testPoint.currentPos) {
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
            
            for p in listPoints{
                if (p.prePos == p.currentPos) {
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
