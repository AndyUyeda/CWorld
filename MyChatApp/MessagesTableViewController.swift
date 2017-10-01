//
//  MessagesTableViewController.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-08.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyJSON
import FirebaseDatabase
import FirebaseDatabaseUI
import Chatto
class MessagesTableViewController: UIViewController, FUICollectionDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var redDescriberName = "Red"
    var redGuesserName = "Red"
    var blueDescriberName = "Blue"
    var blueGuesserName = "Blue"
    var myRole = "Blue Guesser"
    
    let Games = FUISortedArray(query: Database.database().reference().child("Users").child(Me.uid).child("Games"), delegate: nil) { (lhs, rhs) -> ComparisonResult in
        let lhs = Date(timeIntervalSinceReferenceDate: JSON(lhs.value as Any)["Date"]["date"].doubleValue)
        let rhs = Date(timeIntervalSinceReferenceDate:JSON(rhs.value as Any)["Date"]["date"].doubleValue)
        return rhs.compare(lhs)
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Games.observeQuery()
        self.Games.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        Database.database().reference().child("Users").child(Me.uid).child("Games").keepSynced(true)
    }
    
    @IBAction func SignOut(_ sender: Any) {
        try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    deinit {
        
        print("deinit")
    }
}

extension MessagesTableViewController {
    
    func array(_ array: FUICollection, didAdd object: Any, at index: UInt) {
        self.tableView.insertRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
    }
    
    func array(_ array: FUICollection, didMove object: Any, from fromIndex: UInt, to toIndex: UInt) {
        self.tableView.insertRows(at: [IndexPath(row: Int(toIndex), section: 0)], with: .automatic)
        self.tableView.deleteRows(at: [IndexPath(row: Int(fromIndex), section: 0)], with: .automatic)
        
        
    }
    func array(_ array: FUICollection, didRemove object: Any, at index: UInt) {
        self.tableView.deleteRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
        
        
    }
    func array(_ array: FUICollection, didChange object: Any, at index: UInt) {
        self.tableView.reloadRows (at: [IndexPath(row: Int(index), section: 0)], with: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.Games.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagesTableViewCell
        let info = JSON((Games[(UInt(indexPath.row))] as? DataSnapshot)?.value as Any).dictionaryValue
        
        let rD = info["Roles"]?["redDescriber"].stringValue ?? ""
        let rG = info["Roles"]?["redGuesser"].stringValue ?? ""
        let bD = info["Roles"]?["blueDescriber"].stringValue ?? ""
        let bG = info["Roles"]?["blueGuesser"].stringValue ?? ""
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = JSON(snapshot.value as Any).dictionaryValue
            if(Me.uid == rD){
                cell.myRole = "Red Describer"
                cell.teammate.text = value[(info["Roles"]?["redGuesser"].stringValue)!]?["name"].string
                cell.describingTeammate.text = "Give clues to"
                cell.otherGuesser.text = value[(info["Roles"]?["blueGuesser"].stringValue)!]?["name"].string
                
                cell.otherDescriber.text = value[(info["Roles"]?["blueDescriber"].stringValue)!]?["name"].string
                
                cell.describingTeammate.textColor = UIColor.black
                cell.teammate.textColor = UIColor.red
                cell.otherGuesser.textColor = UIColor.blue
                cell.otherDescriber.textColor = UIColor.blue
            }
            else if(Me.uid == rG){
                cell.myRole = "Red Guesser"
                cell.teammate.text = "is Code Master"
                cell.describingTeammate.text = value[(info["Roles"]?["redDescriber"].stringValue)!]?["name"].string
                
                cell.otherGuesser.text = value[(info["Roles"]?["blueGuesser"].stringValue)!]?["name"].string
                
                cell.otherDescriber.text = value[(info["Roles"]?["blueDescriber"].stringValue)!]?["name"].string
                
                cell.describingTeammate.textColor = UIColor.red
                cell.teammate.textColor = UIColor.black
                cell.otherGuesser.textColor = UIColor.blue
                cell.otherDescriber.textColor = UIColor.blue
            }
            else if(Me.uid == bG){
                cell.myRole = "Blue Guesser"
                cell.teammate.text = "is Code Master"
                cell.describingTeammate.text = value[(info["Roles"]?["blueDescriber"].stringValue)!]?["name"].string
                cell.otherGuesser.text = value[(info["Roles"]?["redGuesser"].stringValue)!]?["name"].string
                
                cell.otherDescriber.text = value[(info["Roles"]?["redDescriber"].stringValue)!]?["name"].string
                
                
                cell.describingTeammate.textColor = UIColor.blue
                cell.teammate.textColor = UIColor.black
                cell.otherGuesser.textColor = UIColor.red
                cell.otherDescriber.textColor = UIColor.red
            }
            else if(Me.uid == bD){
                cell.myRole = "Blue Describer"
                cell.teammate.text = value[(info["Roles"]?["blueGuesser"].stringValue)!]?["name"].string
                cell.describingTeammate.text = "Give clues to"
                cell.otherGuesser.text = value[(info["Roles"]?["redGuesser"].stringValue)!]?["name"].string
                
                cell.otherDescriber.text = value[(info["Roles"]?["redDescriber"].stringValue)!]?["name"].string
                
                
                cell.describingTeammate.textColor = UIColor.black
                cell.teammate.textColor = UIColor.blue
                cell.otherGuesser.textColor = UIColor.red
                cell.otherDescriber.textColor = UIColor.red
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if((info["Roles"]?["currentPlayer"].stringValue) == Me.uid){
            cell.backgroundColor = UIColor.green
        }
        else if((info["Roles"]?["currentPlayer"].stringValue) == "Win"){
            cell.victoryImage.isHidden = false
        }
        else if((info["Roles"]?["currentPlayer"].stringValue) == "Lost"){
            cell.defeatImage.isHidden = false
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        
        cell.lastMessageDate.text = dateFormatter(timestamp: info["Date"]?["date"].double)
        cell.lastMessage.text = info["Date"]?["description"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! MessagesTableViewCell
        myRole = cell.myRole
        
        if(myRole == "Red Describer"){
            redDescriberName = "I am Describing"
            redGuesserName = cell.teammate.text! + " is Guessing"
            blueGuesserName = cell.otherGuesser.text! + " is Guessing"
            blueDescriberName = cell.otherDescriber.text! + " is Describing"
        }
        else if(myRole == "Red Guesser"){
            redGuesserName = "I am Guessing"
            redDescriberName = cell.describingTeammate.text! + " is Describing"
            blueGuesserName = cell.otherGuesser.text! + " is Guessing"
            blueDescriberName = cell.otherDescriber.text! + " is Describing"
        }
        else if(myRole == "Blue Describer"){
            blueDescriberName = "I am Describing"
            blueGuesserName = cell.teammate.text! + " is Guessing"
            redGuesserName = cell.otherGuesser.text! + " is Guessing"
            redDescriberName = cell.otherDescriber.text! + " is Describing"
        }
        else if(myRole == "Blue Guesser"){
            blueGuesserName = "I am Guessing"
            blueDescriberName = cell.describingTeammate.text! + " is Describing"
            redGuesserName = cell.otherGuesser.text! + " is Guessing"
            redDescriberName = cell.otherDescriber.text! + " is Describing"
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.isUserInteractionEnabled = true
        performSegue(withIdentifier: "game", sender: (UInt(indexPath.row)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "game"){
            let info = JSON((Games[sender as! UInt] as? DataSnapshot)?.value as Any).dictionaryValue
            (segue.destination as? GameBoardViewController)?
                .prepareBoard(game: info, redDescriber: redDescriberName, redGuesser: redGuesserName, blueDescriber: blueDescriberName, blueGuesser: blueGuesserName)
        }
    }
    
    
    func dateFormatter(timestamp: Double?) -> String? {
        
        if let timestamp = timestamp {
            let date = Date(timeIntervalSinceReferenceDate: timestamp)
            let dateFormatter = DateFormatter()
            let timeSinceDateInSeconds = Date().timeIntervalSince(date)
            let secondInDays: TimeInterval = 24*60*60
            if timeSinceDateInSeconds > 7 * secondInDays {
                dateFormatter.dateFormat = "MM/dd/yy"
            } else if timeSinceDateInSeconds > secondInDays {
                dateFormatter.dateFormat = "EEE"
            } else {
                dateFormatter.dateFormat = "h:mm a"
            }
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
        
    }
    
}
