//
//  QuickSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/22.
//

import Foundation

class QuickSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"快速排序"}
    }
    override class var timeComplexity: String {
        get {"O(NlogN) - O(N^2)"}
    }
    
    private var funcDatas : [(Int, Int)] = [] //current, sortted
    private var i : Int = 0 //当前函数调用序数
    
    override func start() {
        funcDatas.removeAll()
        i = 0
    }
    
    override func nextStep() -> [T] {
        i = 0
        let ret = quickSort(left: 0, right: count - 1)
        
        if ret == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
    
    private func quickSort(left : Int, right : Int) -> ForResult {
        var current : Int = left
        var sortted : Int = left - 1
        if i < funcDatas.count {
            (current, sortted) = funcDatas[i]
        }else{
            funcDatas.append((current, sortted))
        }
        i += 1
        
        guard left < right else {
            return .finish
        }
        
        let retF = For {
            current <= right
        } _: {
            current += 1
        } _: {
            if showChecking {
                checkingIndex = right
                currentCheck = current
            }
            if dataList[current] <= dataList[right] {
                sortted += 1
                if !showChecking && current == sortted {
                    return .next //交换自身
                }
//                let c = dataList.remove(at: current)
//                dataList.insert(c, at: sortted)
                dataList.swapAt(sortted, current)
//                print("swap: \(current), \(sortted)")
                if showChecking{
                    currentCheck = sortted
                }
                current += 1
                funcDatas[i - 1] = ((current, sortted))
                return .pause
            }else{
                if showChecking {
                    //暂停一步
                    current += 1
                    funcDatas[i - 1] = ((current, sortted))
                    return .pause
                }else{
                    return .next
                }
            }
        }
        
        if retF == .pause {
            return .pause
        }
        
        let retL = quickSort(left: left, right: sortted - 1)
        if retL == .pause {
            return .pause
        }
        
        let retR = quickSort(left: sortted + 1, right: right)
        if retR == .pause {
            return .pause
        }
        
        return .finish
    }
}
