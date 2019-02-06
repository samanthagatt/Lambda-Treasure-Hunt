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
    
    
    @IBOutlet var backTo0Button: UIButton!
    @IBOutlet weak var treasureButton: UIButton!
    
    
    @IBAction func travelBackTo0(_ sender: Any) {
        backTo0Button.isEnabled = false
        
        let currentRoom = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey)
        var p = TreasureMapHelper.getPath(from: currentRoom, to: 1)
        let nextMove = p.removeFirst()
        APIHelper.shared.travel(nextMove.dir, nextRoomID: nextMove.room) { (error, status) in
            if let _ = error, status == nil {
                p.insert(nextMove, at: 0)
                print("ERRORRRRRRR")
            }
            print("Traveled to room: \(String(status?.roomID ?? 0))")
            let cd = status?.cooldown ?? 15.0
            let cooldown = Int(ceil(cd))
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(cooldown)) {
                self.travel(path: p)
            }
        }
    }
    
    @IBAction func toggleCollectTreasure(_ sender: Any) {
        
    }
    
    
    func travel(path: [(dir: String, room: Int)]) {
        if path.count > 0 {
            var p = path
            let nextMove = p.removeFirst()
            APIHelper.shared.travel(nextMove.dir, nextRoomID: nextMove.room) { (error, status) in
                if let _ = error, status == nil {
                    p.insert(nextMove, at: 0)
                    print("ERRORRRRRRR")
                }
                print("Traveled to room: \(String(status?.roomID ?? 0))")
                let cd = status?.cooldown ?? 15.0
                let cooldown = Int(ceil(cd))
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(cooldown)) {
                    self.travel(path: p)
                }
            }
        }
    }
}

