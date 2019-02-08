//
//  ViewController.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import UIKit

// MARK: - Notification names
extension Notification.Name {
    static let userUpdate = Notification.Name("statusUpdate")
    static let adventureUpdate = Notification.Name("adventureUpdate")
}

// MARK: - ViewController
class ViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButtons()
        updateButtons()
        
        scrollView.backgroundColor = .white
        let (width, height) = setUpMap()
        scrollView.contentSize = CGSize(width: width + 20, height: height + 20)
        view.addSubview(scrollView)
        
        setUpCurrentRoom()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpCurrentRoom), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews(_:)), name: .userUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews(_:)), name: .adventureUpdate, object: nil)
    }
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var sideBarView: UIView!
    
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var cooldownLabel: UILabel!
    @IBOutlet weak var encumbranceLabel: UILabel!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var inventoryLabel: UILabel!
    
    @IBOutlet weak var roomIDTitleLabel: UILabel!
    @IBOutlet weak var roomDescriptionLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var northButton: UIButton!
    @IBOutlet weak var eastButton: UIButton!
    @IBOutlet weak var southButton: UIButton!
    @IBOutlet weak var westButton: UIButton!
    
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var goToShopButton: UIButton!
    @IBOutlet weak var goHuntingButton: UIButton!
    @IBOutlet weak var travelToButton: UIButton!
    
    var buttons: [UIButton] {
        return [takeButton, dropButton, sellButton, goToShopButton, goHuntingButton, travelToButton]
    }
    var dirButtons: [UIButton] {
        return [northButton, southButton, eastButton, westButton]
    }
    
    var currentRoomView: UIView!
    var roomSize = 40
    var squareSize: Int {
        return roomSize * 3 / 4
    }
    var corridorSize = 4
    var cornerRadius: Int {
        return squareSize / 10 + 2
    }
    var mapBounds: (minX: Int, minY: Int, maxX: Int, maxY: Int) = (Int.max, Int.max, Int.min, Int.min)
    
    
    
    func setUpButtons() {
        for button in buttons {
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 3
            button.layer.cornerRadius = 4
            button.setTitleColor(.darkGray, for: .disabled)
        }
    }
    
    func setButtonBorderColor() {
        for button in buttons {
            if button.isEnabled {
                button.layer.borderColor = UIColor.black.cgColor
            } else {
                button.layer.borderColor = UIColor.darkGray.cgColor
            }
        }
    }
    
    @objc func updateViews(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let dict = notification.userInfo else {
                return }
            
            if let gold = dict["gold"] {
                self.goldLabel.text = "\(gold)"
            }
            if let strength = dict["strength"] {
                self.strengthLabel.text = "\(strength)"
            }
            if let cooldown = dict["cooldown"] {
                self.cooldownLabel.text = "\(cooldown)"
            }
            if let encumbrance = dict["encumbrance"] {
                self.encumbranceLabel.text = "\(encumbrance)"
            }
            if let speed = dict["speed"] {
                self.speedLabel.text = "\(speed)"
            }
            if let inventory = dict["inventory"] as? [Any] {
                var text = ""
                for item in inventory {
                    text += "\(item), "
                }
                if text.count > 1 {
                    text.removeLast()
                    text.removeLast()
                }
                self.inventoryLabel.text = text
            }

            if let roomID = dict["roomID"] {
                self.roomIDTitleLabel.text = "Room \(roomID) - "
                if let title = dict["title"] {
                    self.roomIDTitleLabel.text! += "\(title)"
                }
            } else if let title = dict["title"] {
                self.roomIDTitleLabel.text = "\(title)"
            }
            if let roomDescription = dict["roomDescription"] {
                self.roomDescriptionLabel.text = "\(roomDescription)"
            }
            if let items = dict["items"] as? [Any] {
                var text = ""
                for item in items {
                    text += "\(item), "
                }
                if text.count > 1 {
                    text.removeLast()
                    text.removeLast()
                }
                self.itemsLabel.text = text
            }
            if let errors = dict["errors"] as? [Any] {
                var text = ""
                for error in errors {
                    text += "\(error), "
                }
                if text.count > 1 {
                    text.removeLast()
                    text.removeLast()
                }
                self.errorLabel.text = text
            }
            if let messages = dict["messages"] as? [Any], messages.count > 0 {
                var text = ""
                for message in messages {
                    text += "\(message) "
                }
                if text.count > 1 {
                    text.removeLast()
                }
                self.messagesLabel.text = text
            }
        }
    }
    
    
    @IBAction func toggleCollectTreasure(_ sender: Any) {
        if TreasureMapHelper.toggleTreasureHunting() {
            goHuntingButton.setTitle(" Stop hunting ", for: .normal)
            for button in buttons {
                if button != goHuntingButton {
                    button.isEnabled = false
                    button.layer.borderColor = UIColor.darkGray.cgColor
                }
            }
            for button in dirButtons {
                button.isEnabled = false
            }
        } else {
            goHuntingButton.setTitle(" Go hunting ", for: .normal)
            updateButtons()
        }
    }
    
    @IBAction func goToShop(_ sender: Any) {
        for button in buttons {
            if button != goToShopButton {
                button.isEnabled = false
            }
        }
        let path = TreasureMapHelper.getPath(to: 1)
        TreasureMapHelper.travelTo(path: path) { status in
            guard let status = status else { self.updateButtons(); return }
            DispatchQueue.main.asyncAfter(deadline: .now() + status.cooldown) {
                self.updateButtons()
            }
        }
    }
    
    @IBAction func travelToRoom(_ sender: Any) {
        let alert = UIAlertController(title: "Where would you like to go?", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let travelAction = UIAlertAction(title: "Travel", style: .default) { (_) in
            let textField = alert.textFields?.first
            if let destIDString = textField?.text, destIDString.count > 0, let destID = Int(destIDString), destID >= 0, destID <= 500 {
                let path = TreasureMapHelper.getPath(to: destID)
                TreasureMapHelper.travelTo(path: path)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(travelAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func manuallyTravel(_ sender: UIButton) {
        for button in dirButtons {
            button.isEnabled = false
            button.layer.borderColor = UIColor.darkGray.cgColor
        }
        let dir: String
        switch sender {
        case northButton:
            dir = "n"
        case eastButton:
            dir = "e"
        case westButton:
            dir = "w"
        case southButton:
            dir = "s"
        default:
            dir = ""
        }
        let currentExits = TreasureMapHelper.getMap()[String(UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey))]?["exits"] as? [String: Int]
        let destID = currentExits?[dir]
        if let destID = destID {
            let path = TreasureMapHelper.getPath(to: destID)
            TreasureMapHelper.travelTo(path: path) { (status) in
                guard let status = status else { return }
                if status.items.count > 0 {
                    self.takeButton.isEnabled = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + status.cooldown) {
                    self.updateButtons()
                }
            }
        }
    }
    
    
    func updateButtons() {
        DispatchQueue.main.async {
            let currentRoomID = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey)
            let roomExits = TreasureMapHelper.getMap()[String(currentRoomID)]?["exits"] as? [String: Int]
            if roomExits?.keys.contains("n") ?? false {
                self.northButton.isEnabled = true
            } else {
                self.northButton.isEnabled = false
            }
            if roomExits?.keys.contains("e") ?? false {
                self.eastButton.isEnabled = true
            } else {
                self.eastButton.isEnabled = false
            }
            if roomExits?.keys.contains("w") ?? false {
                self.westButton.isEnabled = true
            } else {
                self.westButton.isEnabled = false
            }
            if roomExits?.keys.contains("s") ?? false {
                self.southButton.isEnabled = true
            } else {
                self.southButton.isEnabled = false
            }
            if currentRoomID == 1 {
                self.goToShopButton.isEnabled = false
                self.sellButton.isEnabled = true
            } else {
                self.goToShopButton.isEnabled = true
                self.sellButton.isEnabled = false
            }
            self.travelToButton.isEnabled = true
            self.setButtonBorderColor()
        }
    }
    
    @objc func setUpCurrentRoom() {
        DispatchQueue.main.async {
            self.currentRoomView?.removeFromSuperview()
            let map = TreasureMapHelper.getMap()
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
        let map = TreasureMapHelper.getMap()
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

