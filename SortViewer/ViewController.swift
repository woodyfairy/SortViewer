//
//  ViewController.swift
//  SortViewer
//
//  Created by fairy on 2021/9/16.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var canvas: CanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func reset(_ sender: Any) {
        canvas.reset(number: 100)
    }
    
}

