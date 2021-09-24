//
//  ShellSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/24.
//

import Foundation

class ShellSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"希尔排序"} //https://blog.csdn.net/daiyudong2020/article/details/52445044
    }
    override class var timeComplexity: String {
        get {"O(N^(1.3-2))"} //?
    }
    
    //初始化
    private let gatDiv : Int = 3 //步长缩减除数
    private var gap : Int = 1
    private var i : Int = 1
    private var j : Int = 0
    private var swaped : Bool = false
    
    override func start() {
        gap = count / gatDiv
        if gap < 1 {
            gap = 1
        }
        
        i = gap
        j = i - gap // 0
    }
    
    
    override func nextStep() -> [T] {
        let ret = For {
            gap > 0
        } _: {
            let nextGap = gap / gatDiv
            if nextGap < 1 && gap > 1 { //上一次gap不为1，而这次除后<1
                gap = 1 //保证最后一个是1
            }else{
                gap = nextGap
            }
            
            i = gap
            j = i - gap
        } _: {
            //下面就是按gap步长分组的插入排序
            let ret1 = For {
                i < count
            } _: {
                i += 1
                j = i - gap
                swaped = false
            } _: {
                let ret2 = For {
                    //倒序比较：如果默认就比最大的大就不用执行了，如果从0开始的直接比第一个还小，不执行就不对了
                    return j >= 0 && dataList[i] < dataList[j]
                } _: {
                    j -= gap
                } _: {
                    if showChecking {
                        checkingIndex = i
                        currentCheck = j
                    }
                    
                    if showChecking {
                        j -= gap
                        return .pause
                    }else{
                        return .next
                    }
                }
                
                //最后结束要停一步
                if ret2 == .finish && !swaped {
                    swaped = true
                    let temp = dataList.remove(at: i)
                    dataList.insert(temp, at: j + gap) //插入到上一个之前
                    if showChecking {
                        checkingIndex = j + gap //插入过来
                        currentCheck = j
                    }
                    return .pause
                }
                
                return ret2
            }
            
            return ret1
        }

        if ret == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
}
