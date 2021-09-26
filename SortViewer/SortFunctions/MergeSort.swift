//
//  MergeSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/26.
//

import Foundation

class MergeSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"归并排序"} //https://www.cnblogs.com/chengxiao/p/6194356.html
    }
    override class var timeComplexity: String {
        get {"O(NlogN)"}
    }
    
    private var funcDatas : [(Int, Int)] = [] //m, r
    private var i : Int = -1 //当前函数调用序数
    
    override func nextStep() -> [T] {
        i = -1
        let ret = sort(left: 0, right: count - 1)
        
        if ret == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
    
    private func sort(left : Int, right : Int) -> ForResult {
        guard left < right else {
            return .finish
        }
        let mid : Int = (left + right) / 2
        
        let ret1 = sort(left: left, right: mid)
        if ret1 != .finish {
            return ret1
        }
        
        let ret2 = sort(left: mid + 1, right: right)
        if ret2 != .finish {
            return ret2
        }
        
        let ret = merge(left: left, mid: mid, right: right)
        return ret
    }
    
    private func merge(left : Int, mid : Int, right : Int) -> ForResult {
        i += 1
        //var l : Int = mid
        var m : Int = mid //左侧数组总会用最后一个去和r元素比较
        var r : Int = right //右侧从大向小进行
        if i < funcDatas.count {
            (m, r) = funcDatas[i]
        }else{
            funcDatas.append((m, r))
        }
        
        //左侧最大的与右侧数组从大向小进行比较
        let ret = For {
            m >= left && r > m
        } _: {
            //要根据下面的判断来计算下一步状态
        } _: {
            if showChecking {
                checkingIndex = m
                currentCheck = r
            }
            //左侧最大(mid)的比右侧当前位比较
            if dataList[m] > dataList[r] {
                //左侧最大的更大，取出并插入到其后，
                let t = dataList.remove(at: m)
                dataList.insert(t, at: r)
                m -= 1 //左侧数组整体减少了1
                r -= 1 //右侧当前位也向前移动了1
                funcDatas[i] = (m, r)
                return .pause
            }else {
                r -= 1 //右侧向前移动
                funcDatas[i] = (m, r)
                if showChecking {
                    return .pause
                }else{
                    return .next
                }
            }
        }
        
        return ret
    }
}
