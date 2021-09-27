//
//  SelectionSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/18.
//

import Foundation

class SelectionSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {NSLocalizedString("SelectionSort", comment: "选择排序")}
    }
    override class var timeComplexity: String {
        get {"O(N^2)"}
    }
    
    //初始化
    private var i : Int = 0
    private var j : Int = 1
    private var minIndex : Int = 0
    private var swaped : Bool = false
    
    override func nextStep() -> [T] {
        let ret1 = For {
            i < count - 1
        } _: {
            i += 1
            minIndex = i
            j = i
            swaped = false
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
                
                if showChecking {
                    j += 1
                    return .pause
                }else{
                    return .next
                }
            }
            
            //循环结束后进行交换
            if ret2 == .finish && !swaped {
                swaped = true
                //插入
//                    let min = dataList.remove(at: minIndex)
//                    dataList.insert(min, at: i)
                //交换
                dataList.swapAt(i, minIndex) //这里即使是同一个（第一个比较的既是最小的）也要停一步，因为也经历了一次遍历，这样节奏最合理
                if showChecking {
                    checkingIndex = i
                    currentCheck = -1
                }
                                
                return .pause
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
