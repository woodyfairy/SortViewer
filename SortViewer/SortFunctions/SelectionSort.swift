//
//  SelectionSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/18.
//

import Foundation

class SelectionSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"选择排序"}
    }
    override class var timeComplexity: String {
        get {"O(N^2)"}
    }
    
    //初始化
    var i : Int = 0
    var j : Int = 1
    var minIndex : Int = 0
    
    override func nextStep() -> [T] {
        let ret1 = For {
            i < count - 1
        } _: {
            i += 1
            minIndex = i
            j = i
        } _: {
            let ret2 = For {
                j < count
            } _: {
                j += 1
            } _: {
                if showChecking {
                    checkingIndex = minIndex
                    currentCheck = j
                }
                
                if dataList[j] < dataList[minIndex] {
                    minIndex = j
                }
                
                //如果是最后一个，不放在finish里是因为需要暂定绘图，finish不会暂停
                if j == count - 1 {
                    checkingIndex = -1
                    //插入
//                    let min = dataList.remove(at: minIndex)
//                    dataList.insert(min, at: i)
                    //交换
                    dataList.swapAt(i, minIndex)
                    
                    j += 1
                    return .pause
                }
                
                if showChecking {
                    j += 1
                    return .pause
                }else{
                    return .next
                }
            }
            
            return ret2
        }
        
        if ret1 == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
}
