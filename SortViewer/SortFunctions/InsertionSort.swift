//
//  InsertionSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/18.
//

import Foundation

class InsertionSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"插入排序"}
    }
    override class var timeComplexity: String {
        get {"O(N^2)"}
    }
    
    //初始化
    var i : Int = 1
    var j : Int = 0
    
    override func nextStep() -> [T] {
        let ret1 = For {
            i < count
        } _: {
            i += 1
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
                //最后一个
                if j == 0 || dataList[i] >= dataList[j - 1] {
                    if showChecking {
                        checkingIndex = j //插入过来
                        currentCheck = j + 1 //之前的后移
                    }
                    let temp = dataList.remove(at: i)
                    dataList.insert(temp, at: j)
                    j -= 1
                    return .pause
                }
                
                if showChecking {
                    j -= 1
                    return .pause
                }else{
                    return .next
                }
            }
            
            //重置循环要放到最后
            if ret2 == .finish {
                j = i //这里在i循环之前，下一步i+=1，j就=i-1了
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
