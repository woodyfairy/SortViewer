//
//  ViewController.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

class Option {
    var number : Int = 20
    var sortStepTime : TimeInterval = 0.05
    var showChecking : Bool = true
}

class ViewController: UIViewController {
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var tableView: UITableView!
    
    var option : Option = Option()
    
    let sortTypes : [SortBase<Point>.Type] = [
        BubbleSort<Point>.self
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOption" {
            if let optionVC = segue.destination as? OptionViewController {
                optionVC.option = self.option
            }
        }
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "sortCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "sortCell")
        }
        let type = sortTypes[indexPath.row]
        cell?.textLabel?.text = type.name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        let type = sortTypes[indexPath.row]
        canvas.startRunning(sortFunctionType: type, showChecking: option.showChecking)
    }
    
}

