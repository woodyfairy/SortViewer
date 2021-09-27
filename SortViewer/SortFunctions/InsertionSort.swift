//
//  InsertionSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/18.
//

import Foundation

class InsertionSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {NSLocalizedString("InsertionSort", comment: "插入排序")}
    }
    override class var timeComplexity: String {
        get {"O(N) - O(N^2)"}
    }
    
    //初始化
    private var i : Int = 1
    private var j : Int = 0
    private var swaped : Bool = false
    
    override func nextStep() -> [T] {
        let ret1 = For {
            i < count
        } _: {
            i += 1
            j = i - 1
            swaped = false
        } _: {
            let ret2 = For {
                //倒序比较：如果默认就比最大的大就不用执行了，如果从0开始的直接比第一个还小，不执行就不对了
                return j >= 0 && dataList[i] < dataList[j]
            } _: {
                j -= 1
            } _: {
                if showChecking {
                    checkingIndex = i
                    currentCheck = j
                }
                
                if showChecking {
                    j -= 1
                    return .pause
                }else{
                    return .next
                }
            }
            
            //最后结束要停一步
            if ret2 == .finish && !swaped {
                swaped = true
                let temp = dataList.remove(at: i)
                dataList.insert(temp, at: j + 1) //插入到上一个之前
                if showChecking {
                    checkingIndex = j + 1 //插入过来
                    currentCheck = j
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
