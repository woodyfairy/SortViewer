//
//  ViewController.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

struct Option {
    var number : Int = 30
    var sortStepTime : TimeInterval = 0.05
//    var number : Int = 6
//    var sortStepTime : TimeInterval = 1
    var showChecking : Bool = true
}

class ViewController: UIViewController {
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var autoPlayBtn: UIButton!
    
    var option : Option = Option()
    var currentIndex : Int = -1
    
    let sortTypes : [SortBase<Point>.Type] = [
        BubbleSort<Point>.self,
        SelectionSort<Point>.self,
        InsertionSort<Point>.self,
        HeapSort<Point>.self,
        QuickSort<Point>.self,
        RadixSort<Point>.self,
        ShellSort<Point>.self,
        MergeSort<Point>.self,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshAutoPlayButton()
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reset() //默认点击
    }

    @IBAction func reset(_ sender: Any? = nil) {
        canvas.reset(number: option.number)
        canvas.sortStepTime = option.sortStepTime
        currentIndex = -1
        tableView.reloadData()
    }
    @IBAction func autoPlay(_ sender: Any) {
        canvas.autoPlay = !canvas.autoPlay
        refreshAutoPlayButton()
    }
    @IBAction func next(_ sender: Any) {
        if canvas.autoPlay {
            canvas.autoPlay = false
            refreshAutoPlayButton()
        }else{
            canvas.nextStep()
        }
    }
    private func refreshAutoPlayButton(){
        autoPlayBtn.tintColor = canvas.autoPlay ? .systemBlue : .black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOption" {
            if let optionVC = segue.destination as? OptionViewController {
                optionVC.delegate = self
                optionVC.option = self.option
            }
        }
    }
}
extension ViewController : OptionViewControllerDelegate {
    func optionViewDidOk(option: Option) {
        self.option = option
        self.reset()
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "sortCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "sortCell")
            cell?.selectionStyle = .none
        }
        let type = sortTypes[indexPath.row]
        cell?.textLabel?.text = type.name
        cell?.textLabel?.textColor = (indexPath.row == currentIndex) ? .systemBlue : .black
        cell?.detailTextLabel?.text = type.timeComplexity
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sortTypes[indexPath.row]
        if canvas.isRunning {
            self.reset()
        }
        canvas.startRunning(sortFunctionType: type, showChecking: option.showChecking)
        
        currentIndex = indexPath.row
        self.tableView.reloadData()
        //tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    }
    
}

