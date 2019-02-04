//
//  ViewController.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    var timer: Timer?
    
    @IBOutlet weak var startTraversalButton: UIButton!
    
    @IBAction func startTraversal(_ sender: Any) {
        startTraversalButton.isEnabled = false
        
        TreasureMapHelper.shared.travel { timeInterval in
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval ?? 20.0, target: self, selector: #selector(self.this), userInfo: nil, repeats: false)
        }
    }
    
    @objc func this() {
        let map = TreasureMapHelper.shared.getMap()
        while map.count < 500 {
            TreasureMapHelper.shared.travel { timeInterval in
                self.timer = Timer.scheduledTimer(timeInterval: timeInterval ?? 20.0, target: self, selector: #selector(self.this), userInfo: nil, repeats: false)
            }
        }
    }
}

