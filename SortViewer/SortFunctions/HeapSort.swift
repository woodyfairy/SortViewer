//
//  HeapSort.swift
//  SortViewer
//
//  Created by fairy on 2021/9/22.
//

//堆排序要点：
//堆的特点：N节点的两个子节点为2N+1,2N+2，最后一个非叶子节点为 length/2-1
//首先建立大顶堆：从最后一个非叶子结点向前进行堆调整（双循环：O(log1) + O(log2) + O(log3) + … O(logn) = O(n)）
//进行一次首位交换，排除最后一个(最大值)
//此时堆结构不变，只需要从第一个元素向下级开始进行调整（logN）
//继续收尾交换、重排序。外层加一个循环(N)

import Foundation

class HeapSort<T : Comparable>: SortBase<T> {
    class override var name : String {
        get {"堆排序"}
    }
    override class var timeComplexity: String {
        get {"O(NlogN)"}
    }
    
    private var f : Int = 0 //first
    private var s : Int = 9 //second
    override func start() {
        //初始化
        f = count / 2 - 1 //最后一个非叶子结点
        i = f
        h = i * 2 + 1
    }
    
    //第二次初始化
    private var inited2 : Bool = false
    private func init2() {
        if inited2 {
            return
        }
        print("init2")
        s = count - 1
        i = 0
        h = i * 2 + 1
        inited2 = true
    }
    
    private var swaped : Bool = false //记录这次循环中是否进行过循环
    override func nextStep() -> [T] {
        //初次建立大顶堆
        let retF = For {
            f >= 0;
        } _: {
            f -= 1
            i = f
            h = i * 2 + 1
        } _: {
            return heapify(length: count)
        }
        
        if retF != .finish {
            return dataList
        }
        
        init2() //初始化第二个循环
        
        //2.调整堆结构+交换堆顶元素与末尾元素
        let ret2 = For {
            s > 0
        } _: {
            s -= 1
            i = 0
            h = i * 2 + 1
        } _: {
            if !swaped {
                dataList.swapAt(0, s)
                swaped = true
                return .pause
            }
            
            let retH = heapify(length: s)
            
            
            if retH == .finish {
                 swaped = false //下次循环可交换
            }
            
            return retH
            
        }
        
        if ret2 == .finish {
            isFinished = true
            checkingIndex = -1
            currentCheck = -1
        }
        
        return dataList
    }
    
    
    //堆调整
    private var i : Int = 0 //记录传入值
    private var h : Int = 0 //内部循环
    func heapify(length : Int) -> ForResult {
        return For {
            h < length
        } _: {
            h = h * 2 + 1 //下一级
        } _: {
            if(h + 1 < length && dataList[h] < dataList[h + 1]){
                h += 1 //如果左子结点小于右子结点，指向右子结点
            }
            
            if showChecking {
                checkingIndex = i
                currentCheck = h
            }
            
            if dataList[h] > dataList[i] {
                dataList.swapAt(i, h)
                //下一级
                i = h
                h = h * 2 + 1
                return .pause
            }else{
                // break
                if showChecking {
                    h = length //设置为最后一个
                    return .pause
                }else{
                    return .finish
                }
            }
        }
    }
}
