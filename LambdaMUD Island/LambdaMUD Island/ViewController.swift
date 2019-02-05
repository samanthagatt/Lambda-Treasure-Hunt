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
        
        TreasureMapHelper.shared.travel() { timeInterval in
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: timeInterval ?? 20.0, target: self, selector: #selector(self.keepTraveling), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func keepTraveling() {
        let map = TreasureMapHelper.shared.getMap()
        if map.count < 500 {
            TreasureMapHelper.shared.travel() { timeInterval in
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(timeInterval: timeInterval ?? 20.0, target: self, selector: #selector(self.keepTraveling), userInfo: nil, repeats: false)
                }
            }
        } else {
            print(TreasureMapHelper.shared.path)
            UserDefaults.standard.set(TreasureMapHelper.shared.path, forKey: "FINALPATH")
        }
    }
}

