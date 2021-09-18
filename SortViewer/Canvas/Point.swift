//
//  Point.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

class Point : Comparable {
    //data
    var value : Int
    var color : UIColor
    var prePos : CGPoint
    var currentPos : CGPoint
    
    //排序
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.value == rhs.value
    }
    static func < (lhs: Point, rhs: Point) -> Bool {
        return lhs.value < rhs.value
    }
    var preIndex : Int = 0
    
    //动画
    private var startTime : Date? = nil
    private var startPos : CGPoint
    private var endPos : CGPoint
    private var duration : TimeInterval = 0
    var percent : Double {
        get{
            if let startTime = startTime {
                let time = Date().timeIntervalSince(startTime)
                var percent = time / duration
                if percent < 0 { //clamp
                    percent = 0
                }else if percent >= 1 {
                    percent = 1
                    isAnimating = false
                }
                return percent
            }else{
                return 0
            }
        }
    }
    var isAnimating : Bool = false
    
    init(value : Int, pos : CGPoint, color: UIColor) {
        self.value = value
        startPos = pos
        endPos = pos
        prePos = pos
        currentPos = pos
        self.color = color
    }
    func resetPos(pos : CGPoint) {
        startPos = pos
        endPos = pos
        prePos = pos
        currentPos = pos
    }
    
    private var jumpTo : CGPoint? = nil //在快速的情况下，同一个点的连续移动会使其一直处于初始运动状态，本应很快的点反而移动很慢
    func animteTo(_ toPos : CGPoint, fromPos : CGPoint? = nil, duration : TimeInterval = 0.15, jump : Bool = true) {
        if fromPos == nil && jump {
            //设置动画时设置第一次是否为直接跳跃
            jumpTo = endPos
        }
        isAnimating = true
        startTime = Date()
        endPos = toPos
        if let from = fromPos {
            startPos = from
            prePos = from
            currentPos = from
        }else{
            startPos = currentPos
        }
        self.duration = duration
    }
    
    func update() {
        prePos = currentPos //重设pre
        if !isAnimating {return}
        
        if let jumpTo = jumpTo {
            //首次移动（如果之前的动画还没有结束），直接跳到结束位置
            startPos = jumpTo
            currentPos = jumpTo
            self.jumpTo = nil
        }else{
            let funcPercent = getTimingFunction(percent: CGFloat(percent))
            currentPos = CGPoint(x: startPos.x + (endPos.x - startPos.x) * funcPercent, y: startPos.y + (endPos.y - startPos.y) * funcPercent)
        }
    }
    
    private func getTimingFunction(percent : CGFloat) -> CGFloat {
        return -cos(percent * .pi) * 0.5 + 0.5
    }
}
