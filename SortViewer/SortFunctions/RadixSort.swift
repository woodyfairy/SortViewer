//
//  RadixSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/23.
//


import UIKit

//当前只实现【正整数】数列！

class RadixSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"基数排序"}
    }
    override class var timeComplexity: String {
        get {"O(d(N+radix))"}
    }
    
    private var maxDigit : Int = 0 //最大位数
    private var mod : Int = 10 //取模数
    private var dev : Int = 1 //除数，截去后位
    private var counter : [[Point]] = []
    private var i : Int = 0 //外层循环，位数
    
    override func start() {
        guard dataList.count > 0 else {
            return
        }
        //取得最大位数
        if let list = dataList as? [Point] {
            var maxValue : Int = list[0].value
            for m in 1..<dataList.count {
                if maxValue < list[m].value {
                    maxValue = list[m].value
                }
            }
            //print("maxValue: \(maxValue)")
            maxDigit = 1
            while maxValue >= mod {
                maxValue /= 10
                maxDigit += 1
            }
            //print("maxDigit: \(maxDigit)")
        }
        
        //初始化桶
        for _ in 0..<mod {
            counter.append([])
        }
    }
    
    var f : Int = 0 //first
    var s : Int = 0 //second
    var pos : Int = 0 //重构数组的位置
    override func nextStep() -> [T] {
        let ret = For {
            i < maxDigit
        } _: {
            i += 1
            mod *= 10
            dev *= 10
            f = 0
            s = 0
            pos = 0
        } _: {
            let retF = For {
                f < count
            } _: {
                f += 1
            } _: {
                if let p = dataList[f] as? Point {
                    let bucket = (p.value % mod) / dev
                    counter[bucket].append(p)
                    p.preIndex = -1 //手动表示变化，设置动画后，还会立刻被设置成数组中的真实位置
                    p.xPercent = CGFloat(bucket) / CGFloat(counter.count - 1)
                    p.yPercent = CGFloat(counter[bucket].count - 1) / CGFloat(count - 1)
                    
                    f += 1
                    return .pause
                }else{
                    return .next
                }
            }
            guard retF == .finish else {
                return retF
            }
            
            let retS = For {
                s < counter.count
            } _: {
                s += 1
            } _: {
                return For {
                    counter[s].count > 0
                } _: {
                    //nothing
                } _: {
                    let p = counter[s].removeFirst()
                    if let pP = dataList.firstIndex(of: p as! T) {
                        dataList.remove(at: pP)
                        p.preIndex = -1 //手动表示变化，设置动画后，还会立刻被设置成数组中的真实位置
                        p.xPercent = -1
                        p.yPercent = -1
                    }
                    dataList.insert(p as! T, at: pos)
                    pos += 1
                    
                    return .pause
                }
            }
            
            return retS
        }

        if ret == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
}
