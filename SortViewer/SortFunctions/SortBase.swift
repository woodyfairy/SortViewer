//
//  SortBase.swift
//  SortViewer
//
//  Created by fairy on 2021/9/17.
//

import UIKit

class SortBase<T : Comparable> {
    var isFinished : Bool = false
    var checkingIndex : Int = -1
    var currentCheck : Int = -1
    var showChecking : Bool
    class var name : String {
        get {""}
    }
    class var timeComplexity : String {
        get {""}
    }
    
    var dataList : [T]
    var count : Int
    
    required init(dataList : [T], showChecking : Bool = false) {
        self.dataList = dataList
        self.count = dataList.count
        self.showChecking = showChecking
    }
    func start() {
        //初始化
    }
    func nextStep() -> [T] {
        fatalError("next() has not been implemented")
    }
    
    enum ForResult {
        case pause
        case next
        case finish //最后一个next
    }
    
    func For(_ condition: ()->Bool, _ then : ()->(), _ doFunc : ()->ForResult) -> ForResult{
        while condition() {
            let result = doFunc()
            switch result {
            case .pause:
                return .pause
            default:
                then() //next/finish 都是进行下次循环(For嵌套时，内层for返回finish，这里不能return finish)
                break
            }
        }
        return .finish
    }
    
}
