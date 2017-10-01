//
//  GameBoardViewController.swift
//  MyChatApp
//
//  Created by Andy Uyeda on 9/20/17.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyJSON
import FirebaseDatabase
import FirebaseDatabaseUI

class GameBoardViewController: UIViewController, FUICollectionDelegate {
    var redWordsLeftLabel : UILabel?
    var blueWordsLeftLabel : UILabel?
    var redGuessesLeftLabel : UILabel?
    var blueGuessesLeftLabel : UILabel?
    var clueField : UITextField?
    var numberField : UITextField?
    var passButton : UIButton?
    var giveClueButton : UIButton?
    var redScrollView : UIScrollView?
    var blueScrollView : UIScrollView?
    
    var buttonArray = [UIButton]()
    var wordArray = [String]()
    var statusArray = [String]()
    var colorArray = [String]()
    var redClueArray = [String]()
    var blueClueArray = [String]()
    var gameID : String!
    var rdTitle: String!
    var rgTitle: String!
    var bdTitle: String!
    var bgTitle: String!
    var currentPlayer : String!
    var rD : String!
    var rG : String!
    var bD : String!
    var bG : String!
    var actionsLeft : Int!
    var myRole = "Red Guesser"
    var RedClues: FUIArray!
    var BlueClues: FUIArray!
    var WordStatus: FUIArray!
    var Roles: FUIArray!
    
    
    override func viewWillAppear(_ animated: Bool) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        let boardHeight = screenHeight * 0.45
        let bottomSectionHeight = (screenHeight - navigationBarHeight - statusbarHeight - boardHeight)
        let boardBottom = navigationBarHeight + statusbarHeight + boardHeight
        self.RedClues.observeQuery()
        self.RedClues.delegate = self
        self.BlueClues.observeQuery()
        self.BlueClues.delegate = self
        self.WordStatus.observeQuery()
        self.WordStatus.delegate = self
        self.Roles.observeQuery()
        self.Roles.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
        
        for row in 0...4{
            for col in 0...4{
                let button = UIButton(frame: CGRect(x: (col * Int(screenWidth / 5)), y: Int(navigationBarHeight + statusbarHeight) + (row * Int(boardHeight / 5)), width: Int(screenWidth / 5), height: Int(boardHeight / 5)))
                let index = (row * 5) + col
                
                button.setTitle(wordArray[index], for: UIControlState.normal)
                button.titleLabel?.font = UIFont(name: "Optima-Bold", size: 9)
                button.layer.borderColor = UIColor.gray.cgColor
                button.layer.borderWidth = 1
                button.layer.cornerRadius = 3
                button.tag = index
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                
                
                button.backgroundColor = UIColor.bma_color(rgb: 0xf5de7f)
                
                if (myRole == "Red Describer" || myRole == "Blue Describer"){
                    button.setTitleColor(UIColor.white, for: .normal)
                    if(colorArray[index] == "Blue"){
                        button.backgroundColor = UIColor.blue
                    }
                    else if(colorArray[index] == "Red"){
                        button.backgroundColor = UIColor.red
                    }
                    else if(colorArray[index] == "Black"){
                        button.backgroundColor = UIColor.black
                    }
                    else if(colorArray[index] == "Tan"){
                        button.backgroundColor = UIColor.bma_color(rgb: 0xc3c1b1)
                    }
                    
                    if(statusArray[index] == "visible"){
                        button.alpha = 0.20
                    }
                }
                else {
                    button.setTitleColor(UIColor.black, for: .normal)
                    
                    if(statusArray[index] == "visible"){
                        button.setTitleColor(UIColor.white, for: .normal)
                        if(colorArray[index] == "Blue"){
                            button.backgroundColor = UIColor.blue
                        }
                        else if(colorArray[index] == "Red"){
                            button.backgroundColor = UIColor.red
                        }
                        else if(colorArray[index] == "Black"){
                            button.backgroundColor = UIColor.black
                        }
                        else if(colorArray[index] == "Tan"){
                            button.backgroundColor = UIColor.bma_color(rgb: 0xc3c1b1)
                            
                        }
                    }
                }
                buttonArray.append(button)
                self.view.addSubview(button)
            }
        }
        
        redScrollView = UIScrollView(frame: CGRect(x: Int(screenWidth / 20), y: Int(bottomSectionHeight / 8) + Int(boardBottom), width: Int(screenWidth / 20) * 8, height: Int(bottomSectionHeight / 8) * 5))
        redScrollView?.layer.cornerRadius = 5
        redScrollView?.alpha = 0.8
        redScrollView?.backgroundColor = UIColor.red
        
        blueScrollView = UIScrollView(frame: CGRect(x: Int(screenWidth / 20) * 11, y: Int(bottomSectionHeight / 8) + Int(boardBottom), width: Int(screenWidth / 20) * 8, height: Int(bottomSectionHeight / 8) * 5))
        blueScrollView?.layer.cornerRadius = 5
        blueScrollView?.alpha = 0.8
        blueScrollView?.backgroundColor = UIColor.blue
        
        self.view.addSubview(blueScrollView!)
        
        self.view.addSubview(redScrollView!)
        
        
        
        if (myRole == "Red Describer" || myRole == "Blue Describer"){
            clueField = UITextField(frame: CGRect(x:(screenWidth / 20), y: (7 * (bottomSectionHeight / 8) - (bottomSectionHeight / 16)) + boardBottom, width: (screenWidth / 20) * 7, height:(bottomSectionHeight / 8)))
            clueField?.backgroundColor = UIColor.white
            clueField?.layer.cornerRadius = 5
            clueField?.placeholder = "Clue"
            clueField?.font = UIFont(name: "Optima-Bold", size: 15)
            
            numberField = UITextField(frame: CGRect(x:(screenWidth / 20) * 9 , y: (7 * (bottomSectionHeight / 8) - (bottomSectionHeight / 16)) + boardBottom, width: (screenWidth / 20) * 2, height:(bottomSectionHeight / 8)))
            numberField?.backgroundColor = UIColor.white
            numberField?.layer.cornerRadius = 5
            numberField?.keyboardType = UIKeyboardType.numberPad
            numberField?.placeholder = "1"
            numberField?.textAlignment = NSTextAlignment.center
            numberField?.font = UIFont(name: "Optima-Bold", size: 15)
            
            
            giveClueButton = UIButton(frame: CGRect(x: (screenWidth / 20) * 14, y: (7 * (bottomSectionHeight / 8) - (bottomSectionHeight / 16)) + boardBottom, width: 60, height: (bottomSectionHeight / 8)))
            giveClueButton?.setTitleColor(UIColor.green, for: UIControlState.normal)
            giveClueButton?.setTitle("Give", for: UIControlState.normal)
            giveClueButton?.titleLabel?.font = UIFont(name: "Optima-Bold", size: 22)
            giveClueButton?.addTarget(self, action: #selector(giveClue), for: .touchUpInside)
            
            
            self.view.addSubview(giveClueButton!)
            self.view.addSubview(numberField!)
            self.view.addSubview(clueField!)
        }
        else{
            redWordsLeftLabel = UILabel(frame: CGRect(x: 10, y: 400, width: 100, height: 100))
            redWordsLeftLabel?.center = CGPoint(x: (redScrollView?.center.x)!, y: 15 * (bottomSectionHeight / 16) + (boardBottom))
            redWordsLeftLabel?.textAlignment = NSTextAlignment.center
            redWordsLeftLabel?.textColor = UIColor.black
            redWordsLeftLabel?.text = "Words Left:"
            redWordsLeftLabel?.font = UIFont(name: "Optima-Bold", size: 15)
            
            blueWordsLeftLabel = UILabel(frame: CGRect(x: 10, y: 400, width: 100, height: 100))
            blueWordsLeftLabel?.center = CGPoint(x: (blueScrollView?.center.x)!, y: 15 * (bottomSectionHeight / 16) + (boardBottom))
            blueWordsLeftLabel?.textAlignment = NSTextAlignment.center
            blueWordsLeftLabel?.textColor = UIColor.black
            blueWordsLeftLabel?.text = "Words Left:"
            blueWordsLeftLabel?.font = UIFont(name: "Optima-Bold", size: 15)
            
            
            
            
            redGuessesLeftLabel = UILabel(frame: CGRect(x: 10, y: 400, width: 100, height: 100))
            redGuessesLeftLabel?.center = CGPoint(x: (redScrollView?.center.x)!, y: 13 * (bottomSectionHeight / 16) + (boardBottom))
            redGuessesLeftLabel?.textAlignment = NSTextAlignment.center
            redGuessesLeftLabel?.textColor = UIColor.black
            redGuessesLeftLabel?.text = "Guesses Left:"
            redGuessesLeftLabel?.font = UIFont(name: "Optima-Bold", size: 15)
            redGuessesLeftLabel?.isHidden = true
            
            blueGuessesLeftLabel = UILabel(frame: CGRect(x: 10, y: 400, width: 100, height: 100))
            blueGuessesLeftLabel?.center = CGPoint(x: (blueScrollView?.center.x)!, y: 13 * (bottomSectionHeight / 16) + (boardBottom))
            blueGuessesLeftLabel?.textAlignment = NSTextAlignment.center
            blueGuessesLeftLabel?.textColor = UIColor.black
            blueGuessesLeftLabel?.text = "Guesses Left:"
            blueGuessesLeftLabel?.font = UIFont(name: "Optima-Bold", size: 15)
            blueGuessesLeftLabel?.isHidden = true
            
            passButton = UIButton(frame: CGRect(x: (screenWidth / 20) * 16, y: (7 * (bottomSectionHeight / 8) - (bottomSectionHeight / 16)) + boardBottom, width: 40, height: (bottomSectionHeight / 8)))
            passButton?.center.x = screenWidth / 2
            passButton?.setTitleColor(UIColor.orange, for: UIControlState.normal)
            passButton?.setTitle("Pass", for: UIControlState.normal)
            passButton?.titleLabel?.font = UIFont(name: "Optima-Bold", size: 17)
            passButton?.addTarget(self, action: #selector(pass), for: .touchUpInside)
            
            self.view.addSubview(passButton!)
            
            
            self.view.addSubview(redWordsLeftLabel!)
            self.view.addSubview(blueWordsLeftLabel!)
            self.view.addSubview(redGuessesLeftLabel!)
            self.view.addSubview(blueGuessesLeftLabel!)
            
        }
        
    }
    
    func getWordsLeft(color: String!) -> Int{
        var count = 0
        
        for i in 0...24 {
            if(colorArray[i] == color && statusArray[i] == "hidden"){
                count += 1
            }
        }
        
        return count
    }
    
    func buttonAction(sender: UIButton!) {
        if(Me.uid == self.currentPlayer){
            if((myRole == "Red Guesser") || (myRole == "Blue Guesser")){
                if(statusArray[sender.tag] == "hidden"){
                    let alertController = UIAlertController(title: wordArray[sender.tag], message: "Are you sure?", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                        
                        self.updateBoardColors(sender: sender)
                    })
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateBoardColors(sender: UIButton!){
        if(Me.uid == self.currentPlayer){
            
            let date = Date()
            let double = date.timeIntervalSinceReferenceDate
            Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("GameBoard").child(sender.tag.description).updateChildValues(["status" : "visible"])
            Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("GameBoard").child(sender.tag.description).updateChildValues(["status" : "visible"])
            Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("GameBoard").child(sender.tag.description).updateChildValues(["status" : "visible"])
            Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("GameBoard").child(sender.tag.description).updateChildValues(["status" : "visible"])
            
            if(self.myRole == "Red Guesser"){
                if(colorArray[sender.tag] == "Blue" || colorArray[sender.tag] == "Tan"){
                    self.actionsLeft = 0
                }
                else if(colorArray[sender.tag] == "Black"){
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
                    
                    return
                }
                var cP = self.rG
                var numba = self.actionsLeft - 1
                if(self.actionsLeft < 1){
                    cP = self.bD
                    numba = 1
                }
                //Current Player
                Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                
                //Actions
                Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
            }
            else if(self.myRole == "Blue Guesser"){
                if(colorArray[sender.tag] == "Red" || colorArray[sender.tag] == "Tan"){
                    self.actionsLeft = 0
                }else if(colorArray[sender.tag] == "Black"){
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
                    
                    return
                }
                var cP = self.bG
                var numba = self.actionsLeft - 1
                if(numba < 1){
                    cP = self.rD
                    
                    numba = 1
                }
                //Current Player
                Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                
                //Actions
                Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
            }
            
            
            let updates =  [
                "Users/\((self.rD)!)/Games/\((self.gameID)!)/Date": (["date": double, "description": wordArray[sender.tag]] as [String : Any]),
                "Users/\((self.rG)!)/Games/\((self.gameID)!)/Date": (["date": double, "description": wordArray[sender.tag]] as [String : Any]),
                "Users/\((self.bD)!)/Games/\((self.gameID)!)/Date": (["date": double, "description": wordArray[sender.tag]] as [String : Any]),
                "Users/\((self.bG)!)/Games/\((self.gameID)!)/Date": (["date": double, "description": wordArray[sender.tag]] as [String : Any])]
            Database.database().reference().updateChildValues(updates)
        }
    }
    
    func giveClue(sender: UIButton!) {
        if(Me.uid == self.currentPlayer){
            if(!(clueField?.text?.isEmpty)! && !(numberField?.text?.isEmpty)!){
                let alertController = UIAlertController(title: String(format: "%@%@%@", (clueField?.text)!, " : ", (numberField?.text)!), message: nil, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] (_) in
                    let date = Date()
                    let double = date.timeIntervalSinceReferenceDate
                    let clue = self?.clueField?.text
                    let numba = self?.numberField?.text
                    let clueID = ("\(double)" + clue! + numba!).replacingOccurrences(of: ".", with: "")
                    
                    self?.clueField?.text = ""
                    self?.numberField?.text = ""
                    self?.view.endEditing(true)
                    
                    if(self?.myRole == "Red Describer"){
                        let updates =  [
                            "Users/\((self!.rD)!)/Games/\((self!.gameID)!)/RedClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.rG)!)/Games/\((self!.gameID)!)/RedClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.bD)!)/Games/\((self!.gameID)!)/RedClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.bG)!)/Games/\((self!.gameID)!)/RedClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            
                            "Users/\((self!.rD)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.rG)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.bD)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.bG)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any])]
                        Database.database().reference().updateChildValues(updates)
                        
                        //Current Player
                        Database.database().reference().child("Users").child((self?.rD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.rG)!])
                        Database.database().reference().child("Users").child((self?.rG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.rG)!])
                        Database.database().reference().child("Users").child((self?.bD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.rG)!])
                        Database.database().reference().child("Users").child((self?.bG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.rG)!])
                        
                        //Actions
                        Database.database().reference().child("Users").child((self?.rD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.rG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.bD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.bG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                    }
                    else if(self?.myRole == "Blue Describer"){
                        let updates =  [
                            "Users/\((self!.rD)!)/Games/\((self!.gameID)!)/BlueClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.rG)!)/Games/\((self!.gameID)!)/BlueClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.bD)!)/Games/\((self!.gameID)!)/BlueClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            "Users/\((self!.bG)!)/Games/\((self!.gameID)!)/BlueClues/\(clueID)": (["date": double, "clue": clue!, "number": numba!, "id": clueID] as [String : Any]),
                            
                            "Users/\((self!.rD)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.rG)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.bD)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any]),
                            "Users/\((self!.bG)!)/Games/\((self!.gameID)!)/Date": (["date": double, "description": clue! + ": " + numba!] as [String : Any])]
                        Database.database().reference().updateChildValues(updates)
                        
                        
                        //Current Player
                        Database.database().reference().child("Users").child((self?.rD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.bG)!])
                        Database.database().reference().child("Users").child((self?.rG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.bG)!])
                        Database.database().reference().child("Users").child((self?.bD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.bG)!])
                        Database.database().reference().child("Users").child((self?.bG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["currentPlayer" : (self?.bG)!])
                        
                        //Actions
                        Database.database().reference().child("Users").child((self?.rD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.rG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.bD)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                        Database.database().reference().child("Users").child((self?.bG)!).child("Games").child((self?.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba!)! + 1])
                    }
                    
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func pass(sender: UIButton!) {
        if(Me.uid == self.currentPlayer){
            
            let alertController = UIAlertController(title: nil, message: "Are you sure that you want to pass?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                
                if(self.myRole == "Red Guesser"){
                    let cP = self.bD
                    let numba = 1
                    
                    //Current Player
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    
                    //Actions
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                }
                else if(self.myRole == "Blue Guesser"){
                    let cP = self.rD
                    let numba = 1
                    
                    //Current Player
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : cP!])
                    
                    //Actions
                    Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                    Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["actionsLeft" : Int(numba)])
                }
                
                self.updateGuessesLeft()
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func prepareBoard(game: [String : Any], redDescriber: String, redGuesser: String, blueDescriber: String, blueGuesser: String) {
        let board = game["GameBoard"]! as! SwiftyJSON.JSON
        let roles = game["Roles"]! as! SwiftyJSON.JSON
        
        for index in 0...24 {
            let dictionary = board[index].dictionaryValue
            wordArray.append((dictionary["word"]?.string)!)
            colorArray.append((dictionary["color"]?.string)!)
            statusArray.append((dictionary["status"]?.string)!)
        }
        
        if(roles["redDescriber"].stringValue == Me.uid){
            myRole = "Red Describer"
        }
        else if(roles["redGuesser"].stringValue == Me.uid){
            myRole = "Red Guesser"
        }
        else if(roles["blueGuesser"].stringValue == Me.uid){
            myRole = "Blue Guesser"
        }
        else {
            myRole = "Blue Describer"
        }
        
        rdTitle = redDescriber
        rgTitle = redGuesser
        bdTitle = blueDescriber
        bgTitle = blueGuesser
        
        rD = (roles["redDescriber"].string)!
        rG = (roles["redGuesser"].string)!
        bD = (roles["blueDescriber"].string)!
        bG = (roles["blueGuesser"].string)!
        
        gameID = (roles["gameID"].string)!
        
        currentPlayer = roles["currentPlayer"].stringValue
        actionsLeft = roles["actionsLeft"].intValue
        
        RedClues = FUISortedArray(query: Database.database().reference().child("Users").child(Me.uid).child("Games").child(gameID).child("RedClues"), delegate: nil) { (lhs, rhs) -> ComparisonResult in
            
            let lhs = Date(timeIntervalSinceReferenceDate: JSON(lhs.value as Any)["date"].doubleValue)
            let rhs = Date(timeIntervalSinceReferenceDate:JSON(rhs.value as Any)["date"].doubleValue)
            return rhs.compare(lhs)
        }
        
        BlueClues = FUISortedArray(query: Database.database().reference().child("Users").child(Me.uid).child("Games").child(gameID).child("BlueClues"), delegate: nil) { (lhs, rhs) -> ComparisonResult in
            
            let lhs = Date(timeIntervalSinceReferenceDate: JSON(lhs.value as Any)["date"].doubleValue)
            let rhs = Date(timeIntervalSinceReferenceDate:JSON(rhs.value as Any)["date"].doubleValue)
            return rhs.compare(lhs)
        }
        
        WordStatus = FUIArray(query: Database.database().reference().child("Users").child(Me.uid).child("Games").child(gameID).child("GameBoard"), delegate: nil)
        
        Roles = FUIArray(query: Database.database().reference().child("Users").child(Me.uid).child("Games").child(gameID).child("Roles"), delegate: nil)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
}

extension GameBoardViewController {
    func updateRedClues(){
        if(RedClues.count > 0 && UInt(redClueArray.count) < UInt(RedClues.count)){
            let info = JSON((RedClues[(UInt(0))] as? DataSnapshot)?.value as Any).dictionaryValue
            redClueArray.insert(info["clue"]!.stringValue + ": " + info["number"]!.stringValue, at: 0)
            clearRedSubviews()
            
            var index = 0
            if(redClueArray.count > 0){
                for clue in redClueArray {
                    let textView = UITextView(frame: CGRect(x: 0, y: 30 * index, width: Int((redScrollView?.frame.width)!), height: 30 ))
                    textView.isScrollEnabled = false
                    textView.text = clue
                    textView.textColor = UIColor.white
                    textView.backgroundColor = UIColor.clear
                    textView.isEditable = false
                    textView.font = UIFont(name: "Optima-Bold", size: 15)
                    redScrollView?.addSubview(textView)
                    redScrollView?.contentSize = CGSize(width: (redScrollView?.frame.width)!, height: CGFloat((index + 1) * 30))
                    index += 1
                }
            }
        }
        
        
    }
    
    func updateBlueClues(){
        if(BlueClues.count > 0 && UInt(blueClueArray.count) < UInt(BlueClues.count)){
            let info = JSON((BlueClues[(UInt(0))] as? DataSnapshot)?.value as Any).dictionaryValue
            blueClueArray.insert(info["clue"]!.stringValue + ": " + info["number"]!.stringValue, at: 0)
            
            clearBlueSubviews()
            
            var index = 0
            if(blueClueArray.count > 0){
                for clue in blueClueArray {
                    let textView = UITextView(frame: CGRect(x: 0, y: 30 * index, width: Int((blueScrollView?.frame.width)!), height: 30 ))
                    textView.isScrollEnabled = false
                    textView.text = clue
                    textView.textColor = UIColor.white
                    textView.backgroundColor = UIColor.clear
                    textView.isEditable = false
                    textView.font = UIFont(name: "Optima-Bold", size: 15)
                    blueScrollView?.addSubview(textView)
                    blueScrollView?.contentSize = CGSize(width: (blueScrollView?.frame.width)!, height: CGFloat((index + 1) * 30))
                    index += 1
                }
            }
        }
        
        
    }
    
    func clearRedSubviews(){
        let subViews = self.redScrollView?.subviews
        for subview in subViews!{
            subview.removeFromSuperview()
        }
    }
    
    func clearBlueSubviews(){
        let subViews = self.blueScrollView?.subviews
        for subview in subViews!{
            subview.removeFromSuperview()
        }
    }
    
    func updateStatusBoard(){
        if(statusArray.count > 24){
            for i in 0...(statusArray.count - 1){
                if (myRole == "Red Describer" || myRole == "Blue Describer"){
                    buttonArray[Int(i)].setTitleColor(UIColor.white, for: .normal)
                    if(colorArray[Int(i)] == "Blue"){
                        buttonArray[Int(i)].backgroundColor = UIColor.blue
                    }
                    else if(colorArray[Int(i)] == "Red"){
                        buttonArray[Int(i)].backgroundColor = UIColor.red
                    }
                    else if(colorArray[Int(i)] == "Black"){
                        buttonArray[Int(i)].backgroundColor = UIColor.black
                    }
                    else if(colorArray[Int(i)] == "Tan"){
                        buttonArray[Int(i)].backgroundColor = UIColor.bma_color(rgb: 0xc3c1b1)
                    }
                    
                    if(statusArray[Int(i)] == "visible"){
                        buttonArray[Int(i)].alpha = 0.20
                    }
                }
                else {
                    buttonArray[Int(i)].setTitleColor(UIColor.black, for: .normal)
                    
                    if(statusArray[Int(i)] == "visible"){
                        buttonArray[Int(i)].setTitleColor(UIColor.white, for: .normal)
                        if(colorArray[Int(i)] == "Blue"){
                            buttonArray[Int(i)].backgroundColor = UIColor.blue
                        }
                        else if(colorArray[Int(i)] == "Red"){
                            buttonArray[Int(i)].backgroundColor = UIColor.red
                        }
                        else if(colorArray[Int(i)] == "Black"){
                            buttonArray[Int(i)].backgroundColor = UIColor.black
                        }
                        else if(colorArray[Int(i)] == "Tan"){
                            buttonArray[Int(i)].backgroundColor = UIColor.bma_color(rgb: 0xc3c1b1)
                            
                        }
                    }
                }
            }
        }
        redWordsLeftLabel?.text = "Words Left: " + getWordsLeft(color: "Red").description
        blueWordsLeftLabel?.text = "Words Left: " + getWordsLeft(color: "Blue").description
        
        if(getWordsLeft(color: "Red") < 1){
            Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
            Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
            Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
            Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
        }
        if(getWordsLeft(color: "Blue") < 1){
            Database.database().reference().child("Users").child((self.rD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
            Database.database().reference().child("Users").child((self.rG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Lost"])
            Database.database().reference().child("Users").child((self.bD)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
            Database.database().reference().child("Users").child((self.bG)!).child("Games").child((self.gameID)!).child("Roles").updateChildValues(["currentPlayer" : "Win"])
        }
    }
    
    func updateCurrentPlayerStatus(){
        if(self.currentPlayer == self.bG){
            self.navigationItem.title = bgTitle
        }
        else if(self.currentPlayer == self.bD){
            self.navigationItem.title = bdTitle
        }
        else if(self.currentPlayer == self.rD){
            self.navigationItem.title = rdTitle
        }
        else if(self.currentPlayer == self.rG){
            self.navigationItem.title = rgTitle
        }
        else if(self.currentPlayer == "Win"){
            self.navigationItem.title = "You Won!"
            self.alert(message: "You Won")
        }
        else if(self.currentPlayer == "Lost"){
            self.navigationItem.title = "You Lost"
            self.alert(message: "You Lost")
        }
    }
    
    func updateStatus(){
        if(WordStatus.count > 24){
            statusArray.removeAll()
            
            for i in 0...(WordStatus.count - 1) {
                let info = JSON((WordStatus[(UInt(i))] as? DataSnapshot)?.value as Any).dictionaryValue
                statusArray.append(info["status"]!.stringValue)
            }
            updateStatusBoard()
        }
    }
    
    func updateGuessesLeft(){
        Database.database().reference().child("Users").child(Me.uid).child("Games").child(gameID).child("Roles").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = JSON(snapshot.value as Any).dictionaryValue
            self.currentPlayer = value["currentPlayer"]!.stringValue
            
            self.actionsLeft = value["actionsLeft"]!.intValue
            if(self.currentPlayer == Me.uid){
                if(Me.uid == self.rG){
                    self.redGuessesLeftLabel?.isHidden = false
                    self.redGuessesLeftLabel?.text = "Guesses Left: " + (self.actionsLeft.description)
                    
                }
                else if(Me.uid == self.bG){
                    self.blueGuessesLeftLabel?.isHidden = false
                    self.blueGuessesLeftLabel?.text = "Guesses Left: " + (self.actionsLeft.description)
                }
                else{
                    self.redGuessesLeftLabel?.isHidden = true
                    self.blueGuessesLeftLabel?.isHidden = true
                }
            }
            else{
                self.redGuessesLeftLabel?.isHidden = true
                self.blueGuessesLeftLabel?.isHidden = true
            }
            
            self.updateCurrentPlayerStatus()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func updateFireBase(){
        updateRedClues()
        updateBlueClues()
        updateStatus()
        updateGuessesLeft()
        updateCurrentPlayerStatus()
    }
    
    func array(_ array: FUICollection, didAdd object: Any, at index: UInt) {
        updateFireBase()
    }
    
    func array(_ array: FUICollection, didMove object: Any, from fromIndex: UInt, to toIndex: UInt) {
        updateFireBase()
    }
    func array(_ array: FUICollection, didRemove object: Any, at index: UInt) {
        updateFireBase()
    }
    func array(_ array: FUICollection, didChange object: Any, at index: UInt) {
        updateFireBase()
    }
}
