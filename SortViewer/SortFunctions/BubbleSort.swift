//
//  BubbleSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/17.
//

import Foundation

class BubbleSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"冒泡排序"}
    }
    override class var timeComplexity: String {
        get {"O(N^2)"}
    }
    
    var i : Int = 0
    var j : Int = 0
    
    override func nextStep() -> [T] {
        let ret1 = For {
            i < count
        } _: {
            i += 1
            j = 0
        } _: {
            let ret2 = For {
                j < count - 1 - i
            } _: {
                j += 1
            } _: {
                if showChecking {
                    checkingIndex = j
                    currentCheck = j + 1
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
            
            return ret2
        }

        if ret1 == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return self.dataList
    }
}
