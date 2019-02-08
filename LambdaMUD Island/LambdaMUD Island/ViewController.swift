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
        
        scrollView.backgroundColor = .white
        let (width, height) = setUpMap()
        scrollView.contentSize = CGSize(width: width + 20, height: height + 20)
        view.addSubview(scrollView)
        setUpCurrentRoom()
        NotificationCenter.default.addObserver(self, selector: #selector(setUpCurrentRoom), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateText(_:)), name: .userUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateText(_:)), name: .adventureUpdate, object: nil)
    }
    
    
    @objc func updateText(_ notification: Notification) {
        
    }
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var treasureButton: UIButton!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet var travelButton: UIButton!
    
    var currentRoomView: UIView!
    var roomSize = 60
    var squareSize: Int {
        return roomSize * 3 / 4
    }
    var corridorSize = 6
    var cornerRadius: Int {
        return squareSize / 10 + 2
    }
    var mapBounds: (minX: Int, minY: Int, maxX: Int, maxY: Int) = (Int.max, Int.max, Int.min, Int.min)
    
    
    @IBAction func toggleCollectTreasure(_ sender: Any) {
        TreasureMapHelper.shared.getRandomTreasure() { (_, _) in }
    }
    
    @IBAction func travel(_ sender: Any) {
        guard let destString = destinationTextField.text,
            let dest = Int(destString) else {
            return
        }
        let path = TreasureMapHelper.getPath(to: dest)
        TreasureMapHelper.travelTo(path: path)
        travelButton.isEnabled = false
    }
    
    @objc func setUpCurrentRoom() {
        DispatchQueue.main.async {
            self.currentRoomView?.removeFromSuperview()
            let map = TreasureMapHelper.shared.getMap()
            let currentRoom = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey)
            let coordsString = map[String(currentRoom)]?["coordinates"] as? String ?? "0,0"
            let subStringArray = coordsString.split(separator: ",")
            let coords = (x: Int(String(subStringArray[0])) ?? 0,
                          y: Int(String(subStringArray[1])) ?? 0)
            let x = (coords.x * self.roomSize) - (self.mapBounds.minX * self.roomSize) + 10
            let y = (coords.y * self.roomSize) - (self.mapBounds.minY * self.roomSize) + 10
            self.currentRoomView = UIView(frame: CGRect(x: x, y: y, width: self.squareSize, height: self.squareSize))
            self.currentRoomView.backgroundColor = UIColor(red:0.56, green:0.93, blue:0.56, alpha:1.0)
            self.currentRoomView.layer.borderWidth = CGFloat(self.corridorSize)
            self.currentRoomView.layer.borderColor = UIColor.lightGray.cgColor
            self.currentRoomView.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.scrollView.addSubview(self.currentRoomView)
        }
    }
    
    func setUpMap() -> (Int, Int) {
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
            
            let x = (coords.x * roomSize) - (mapBounds.minX * roomSize) + 10
            let y = (coords.y * roomSize) - (mapBounds.minY * roomSize) + 10
            let leftoverSize = roomSize / 4
            let halfSquare = squareSize / 2
            
            let roomView = UIView(frame: CGRect(x: x, y: y, width: squareSize, height: squareSize))
            roomView.backgroundColor = .clear
            roomView.layer.borderWidth = CGFloat(corridorSize)
            roomView.layer.borderColor = UIColor.lightGray.cgColor
            roomView.layer.cornerRadius = CGFloat(cornerRadius)
            scrollView.addSubview(roomView)
            
            if exits.contains("n") {
                let corridor = UIView(frame: CGRect(x: x + halfSquare - (corridorSize / 2), y: y + squareSize, width: corridorSize, height: leftoverSize / 2 + 2))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("s") {
                let corridor = UIView(frame: CGRect(x: x + halfSquare - (corridorSize / 2), y: y - (leftoverSize / 2), width: corridorSize, height: leftoverSize / 2 + 2))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("e") {
                let corridor = UIView(frame: CGRect(x: x + squareSize, y: y + halfSquare - (corridorSize / 2), width: leftoverSize / 2 + 2, height: corridorSize))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
            if exits.contains("w") {
                let corridor = UIView(frame: CGRect(x: x - (leftoverSize / 2), y: y + halfSquare - (corridorSize / 2), width: leftoverSize / 2 + 2, height: corridorSize))
                corridor.backgroundColor = .lightGray
                scrollView.addSubview(corridor)
            }
        }
        
        return ((mapBounds.maxX - mapBounds.minX) * roomSize, (mapBounds.maxY - mapBounds.minY) * roomSize)
    }
}

