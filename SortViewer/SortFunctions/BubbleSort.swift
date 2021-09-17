//
//  BubbleSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/17.
//

import UIKit

class BubbleSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"冒泡排序"}
    }
    
    var count : Int = 0
    var i : Int = 0
    var j : Int = 0
    override func start() {
        count = dataList.count
    }
    
    override func nextStep() -> [T] {
        let ret = For {
            i < count
        } _: {
            i += 1
        } _: {
            let ret2 = For {
                j < count - 1 - i
            } _: {
                j += 1
            } _: {
                if showChecking {
                    checkingIndex = j
                }
                if dataList[j] > dataList[j + 1] {
                    self.dataList.swapAt(j, j + 1) //元素交换
                    j += 1
                    return .pause
                }else{
                    if showChecking {
                        j += 1
                        return .pause
                    }else{
                        return .next
                    }
                }
            }
            
            if ret2 == .finish {
                j = 0 //重置循环
            }
            return ret2
        }

        if ret == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return self.dataList
    }
}
