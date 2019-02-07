//
//  ViewController.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrollView = UIScrollView()
//        let (width, height) = setUpMap()
//        scrollView.contentSize = CGSize(width: width, height: height)
//        view.addSubview(scrollView)
//        scrollView.fillSuperview()
//        scrollView.delegate = self
        
//        
//        do {
//            let map = TreasureMapHelper.shared.getMap()
//            let data = try JSONSerialization.data(withJSONObject: map, options: .prettyPrinted)
//            textView.text = String(data: data, encoding: .utf8)
//        } catch {
//            print("error:", error)
//        }
        
        
    }
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - UIScrollViewDelegate
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return scrollView
//    }
    
    
    
    
    func setUpMap() -> (Int, Int) {
        let roomSize = 60
        var mapBounds: (minX: Int, minY: Int, maxX: Int, maxY: Int) = (Int.max, Int.max, Int.min, Int.min)
        let map = TreasureMapHelper.shared.getMap()
        for (_, valueDict) in map {
            let coordsString = valueDict["coordinates"] as? String ?? "0,0"
            let subStringArray = coordsString.split(separator: ",")
            let coords = (x: Int(String(subStringArray[0])) ?? 0,
                          y: Int(String(subStringArray[1])) ?? 0)
            if coords.x > mapBounds.maxX {
                mapBounds.maxX = coords.x
            } else if coords.x < mapBounds.minX {
                mapBounds.minX = coords.x
            }
            if coords.y > mapBounds.maxY {
                mapBounds.maxY = coords.y
            } else if coords.y < mapBounds.minY {
                mapBounds.minY = coords.y
            }
        }
        
        for(_, valueDict) in map {
            let coordsString = valueDict["coordinates"] as? String ?? "0,0"
            let subStringArray = coordsString.split(separator: ",")
            let coords = (x: Int(String(subStringArray[0])) ?? 0,
                          y: Int(String(subStringArray[1])) ?? 0)
            let exitsDict = valueDict["exits"] as? [String: Int] ?? [:]
            let exits = exitsDict.keys
            
            let x = (coords.x * roomSize) - (mapBounds.minX * roomSize)
            let y = (coords.y * roomSize) - (mapBounds.minY * roomSize)
            let squareSize = roomSize * 3 / 4
            let leftoverSize = roomSize / 4
            let halfSquare = squareSize / 2
            let corridorSize = 5
            
            let roomView = UIView(frame: CGRect(x: x, y: y, width: squareSize, height: squareSize))
            roomView.backgroundColor = .clear
            roomView.layer.borderWidth = CGFloat(corridorSize)
            roomView.layer.borderColor = UIColor.lightGray.cgColor
            roomView.layer.cornerRadius = CGFloat(squareSize / 10 + 2)
            scrollView.addSubview(roomView)
            
            if exits.contains("n") {
                let corridor = UIView(frame: CGRect(x: x + halfSquare - (corridorSize / 2), y: y + squareSize, width: corridorSize, height: leftoverSize / 2 + 1))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("s") {
                let corridor = UIView(frame: CGRect(x: x + halfSquare - (corridorSize / 2), y: y - (leftoverSize / 2), width: corridorSize, height: leftoverSize / 2 + 1))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("e") {
                let corridor = UIView(frame: CGRect(x: x + squareSize, y: y + halfSquare - (corridorSize / 2), width: leftoverSize / 2 + 1, height: corridorSize))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("w") {
                let corridor = UIView(frame: CGRect(x: x - (leftoverSize / 2), y: y + halfSquare - (corridorSize / 2), width: leftoverSize / 2 + 1, height: corridorSize))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
        }
        
        return ((mapBounds.maxX - mapBounds.minX) * roomSize, (mapBounds.maxY - mapBounds.minY) * roomSize)
    }
    
    
    var scrollView: UIScrollView!
    
    @IBOutlet var backTo0Button: UIButton!
    @IBOutlet weak var treasureButton: UIButton!
    
    
    @IBAction func travelBackTo0(_ sender: Any) {
        
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
        TreasureMapHelper.shared.getRandomTreasure() { (_, _) in }
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

