//
//  NewGameViewController.swift
//  MyChatApp
//
//  Created by Andy Uyeda on 9/18/17.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyJSON
import FirebaseDatabase
import FirebaseDatabaseUI
import Chatto

class NewGameViewController: UIViewController {
    
    @IBOutlet weak var redCodeMaster: UITextField!
    @IBOutlet weak var redGuesser: UITextField!
    @IBOutlet weak var blueCodeMaster: UITextField!
    @IBOutlet weak var blueGuesser: UITextField!
    
    
    var gameWords = [String]()
    var gameMap = [String]()
    var redGuesserUid : String = ""
    var blueGuesserUid : String = ""
    var redDescriberUid : String = ""
    var blueDescriberUid : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(maybeShowKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }
    
    func maybeShowKeyboard(notification: Notification) {
        if(blueCodeMaster.isEditing || blueGuesser.isEditing){
            if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
                
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func startGame(_ sender: Any) {
        var isEnd = true
        if(Set([(self.blueGuesser.text!), (self.blueCodeMaster.text!), (self.redGuesser.text!), (self.redCodeMaster.text!)]).count == 4){
            Database.database().reference().child("Users").observeSingleEvent(of: .value, with: {  [weak self] (snapshot) in
                let snapshot = JSON(snapshot.value as Any).dictionaryValue
                if let index = snapshot.index(where: { (key, value) -> Bool in
                    return (value["user"].stringValue == ((self?.redCodeMaster.text!)! + "@cworld.com"))
                }) {
                    
                    self?.redDescriberUid = (snapshot[index].key)
                    
                }
                else {
                    self?.alert(message: "Red Describer is invalid")
                    isEnd = false
                    return
                }
                if let index2 = snapshot.index(where: { (key, value) -> Bool in
                    return (value["user"].stringValue == ((self?.redGuesser.text!)! + "@cworld.com"))
                }) {
                    
                    self?.redGuesserUid = (snapshot[index2].key)
                    
                    
                }
                else {
                    self?.alert(message: "Red Guesser is invalid")
                    isEnd = false
                    return
                }
                if let index3 = snapshot.index(where: { (key, value) -> Bool in
                    return (value["user"].stringValue == ((self?.blueCodeMaster.text!)! + "@cworld.com"))
                }) {
                    
                    self?.blueDescriberUid = (snapshot[index3].key)
                    
                }
                else {
                    self?.alert(message: "Blue Describer is invalid")
                    isEnd = false
                    return
                }
                if let index4 = snapshot.index(where: { (key, value) -> Bool in
                    return (value["user"].stringValue == ((self?.blueGuesser.text!)! + "@cworld.com"))
                }) {
                    
                    self?.blueGuesserUid = (snapshot[index4].key)
                }
                else {
                    self?.alert(message: "Blue Guesser is invalid")
                    isEnd = false
                    return
                }
                
                if(!isEnd){
                    return
                }
                
                let date = Date()
                let double = date.timeIntervalSinceReferenceDate
                let allUIDs = (self?.redDescriberUid)! + (self?.redGuesserUid)! + (self?.blueDescriberUid)! + (self?.blueGuesserUid)!
                let messageUID = ("\(double)" + allUIDs).replacingOccurrences(of: ".", with: "")
                let startingColor = arc4random_uniform(2) + 1
                
                self?.setGameBoard(color: Int(startingColor))
                
                
                var startingRole : String = (self?.redDescriberUid)!
                
                if 2 == startingColor {
                    startingRole = (self?.blueDescriberUid)!
                }
                
                print("MADE IT")
                self?.navigationController?.popViewController(animated: true)
                for index in 0...24 {
                    //*** GameBoard
                    let updates =  [
                        //*** Dates
                        "Users/\((self?.redDescriberUid)!)/Games/\(messageUID)/Date": (["date": double, "description": "Start"] as [String : Any]),
                        "Users/\((self?.redGuesserUid)!)/Games/\(messageUID)/Date": (["date": double, "description": "Start"] as [String : Any]),
                        "Users/\((self?.blueDescriberUid)!)/Games/\(messageUID)/Date": (["date": double, "description": "Start"] as [String : Any]),
                        "Users/\((self?.blueGuesserUid)!)/Games/\(messageUID)/Date": (["date": double, "description": "Start"] as [String : Any]),
                        
                        
                        
                        "Users/\((self?.redDescriberUid)!)/Games/\(messageUID)/GameBoard/\(index)": (["word": self?.gameWords[index], "color": self?.gameMap[index], "status": "hidden"]),
                        "Users/\((self?.redGuesserUid)!)/Games/\(messageUID)/GameBoard/\(index)": (["word": self?.gameWords[index], "color": self?.gameMap[index], "status": "hidden"]),
                        
                        "Users/\((self?.blueDescriberUid)!)/Games/\(messageUID)/GameBoard/\(index)": (["word": self?.gameWords[index], "color": self?.gameMap[index], "status": "hidden"]),
                        
                        "Users/\((self?.blueGuesserUid)!)/Games/\(messageUID)/GameBoard/\(index)": (["word": self?.gameWords[index], "color": self?.gameMap[index], "status": "hidden"]),
                        
                        
                        //*** ROLES
                        "Users/\((self?.redDescriberUid)!)/Games/\(messageUID)/Roles": (["redDescriber": (self?.redDescriberUid)!, "redGuesser": (self?.redGuesserUid)!, "blueDescriber": (self?.blueDescriberUid)!, "blueGuesser": (self?.blueGuesserUid)!, "currentPlayer": startingRole, "actionsLeft": 1, "gameID": messageUID]),
                        "Users/\((self?.redGuesserUid)!)/Games/\(messageUID)/Roles": (["redDescriber": (self?.redDescriberUid)!, "redGuesser": (self?.redGuesserUid)!, "blueDescriber": (self?.blueDescriberUid)!, "blueGuesser": (self?.blueGuesserUid)!, "currentPlayer": startingRole, "actionsLeft": 1, "gameID": messageUID]),
                        
                        "Users/\((self?.blueDescriberUid)!)/Games/\(messageUID)/Roles": (["redDescriber": (self?.redDescriberUid)!, "redGuesser": (self?.redGuesserUid)!, "blueDescriber": (self?.blueDescriberUid)!, "blueGuesser": (self?.blueGuesserUid)!, "currentPlayer": startingRole, "actionsLeft": 1, "gameID": messageUID]),
                        
                        "Users/\((self?.blueGuesserUid)!)/Games/\(messageUID)/Roles": (["redDescriber": (self?.redDescriberUid)!, "redGuesser": (self?.redGuesserUid)!, "blueDescriber": (self?.blueDescriberUid)!, "blueGuesser": (self?.blueGuesserUid)!, "currentPlayer": startingRole, "actionsLeft": 1, "gameID": messageUID])]
                    Database.database().reference().updateChildValues(updates)
                }
                
                
                
            })
        }
        else{
            self.alert(message: "Duplicate users")
        }
        
        gameWords.removeAll()
        gameMap.removeAll()
    }
    
    func setGameBoard(color : Int){
        var blueColor : [String] = ["Red", "Red", "Red", "Red", "Red", "Red", "Red", "Red", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Tan", "Tan", "Tan", "Tan", "Tan", "Tan", "Tan", "Black"]
        var redColor : [String] = ["Red", "Red", "Red", "Red", "Red", "Red", "Red", "Red", "Red", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Blue", "Tan", "Tan", "Tan", "Tan", "Tan", "Tan", "Tan", "Black"]
        
        var word : [String] = ["CENTER",
                               "CHICK",
                               "FLUTE",
                               "CARROT",
                               "PISTOL",
                               "ROW",
                               "TOWER",
                               "POISON",
                               "NOTE",
                               "GROUND",
                               "SUPERHERO",
                               "OIL",
                               "COTTON",
                               "FISH",
                               "PUPIL",
                               "PLOT",
                               "QUEEN",
                               "ALPS",
                               "WORM",
                               "GERMANY",
                               "FORK",
                               "SHAKESPEARE",
                               "ENGINE",
                               "CHINA",
                               "BOLT",
                               "CAST",
                               "GAS",
                               "POOL",
                               "STAR",
                               "GAME",
                               "WASHER",
                               "WAR",
                               "MOUSE",
                               "PORT",
                               "DISEASE",
                               "WATCH",
                               "LEAD",
                               "CONDUCTOR",
                               "DOG",
                               "BAND",
                               "FIRE",
                               "SHADOW",
                               "CENTAUR",
                               "CAT",
                               "SHOT",
                               "YARD",
                               "CHEST",
                               "LIMOUSINE",
                               "AUSTRALIA",
                               "SEAL",
                               "CROSS",
                               "UNICORN",
                               "SPY",
                               "CZECH",
                               "BACK",
                               "NIGHT",
                               "STRING",
                               "LEMON",
                               "BELL",
                               "BUFFALO",
                               "DECK",
                               "PASTE",
                               "MISSILE",
                               "PALM",
                               "MOSCOW",
                               "RAY",
                               "POST",
                               "POLE",
                               "APPLE",
                               "SCHOOL",
                               "SERVER",
                               "SATELLITE",
                               "LAWYER",
                               "LOG",
                               "LOCH NESS",
                               "BUG",
                               "MINT",
                               "CHARGE",
                               "BEACH",
                               "PLATYPUS",
                               "STICK",
                               "PILOT",
                               "CASINO",
                               "LINK",
                               "DANCE",
                               "DRESS",
                               "AMBULANCE",
                               "HOSPITAL",
                               "SATURN",
                               "MAIL",
                               "UNDERTAKER",
                               "TAP",
                               "MOUTH",
                               "KID",
                               "WIND",
                               "FORCE",
                               "TRACK",
                               "CARD",
                               "HORN",
                               "TUBE",
                               "POINT",
                               "BOARD",
                               "CLOAK",
                               "JAM",
                               "ORGAN",
                               "SCREEN",
                               "FAIR",
                               "BRIDGE",
                               "ROBIN",
                               "TRUNK",
                               "SNOW",
                               "GREECE",
                               "SQUARE",
                               "PLATE",
                               "LINE",
                               "GRASS",
                               "SPELL",
                               "SMUGGLER",
                               "ENGLAND",
                               "HOOD",
                               "HEART",
                               "HAWK",
                               "BATTERY",
                               "PRESS",
                               "SPINE",
                               "HOOK",
                               "SPACE",
                               "CHOCOLATE",
                               "SUIT",
                               "BRUSH",
                               "LOCK",
                               "NAIL",
                               "GIANT",
                               "PRINCESS",
                               "TIME",
                               "CHANGE",
                               "ROSE",
                               "PASS",
                               "GREEN",
                               "LUCK",
                               "AMAZON",
                               "FLY",
                               "PIT",
                               "LEPRECHAUN",
                               "NURSE",
                               "PENGUIN",
                               "ROOT",
                               "SNOWMAN",
                               "HELICOPTER",
                               "LION",
                               "POLICE",
                               "TOOTH",
                               "PLAY",
                               "BERLIN",
                               "FACE",
                               "CANADA",
                               "SCORPION",
                               "WEB",
                               "FAN",
                               "CLUB",
                               "SINK",
                               "POUND",
                               "SUB",
                               "FOOT",
                               "NEW YORK",
                               "FENCE",
                               "CAPITAL",
                               "FALL",
                               "SCALE",
                               "EMBASSY",
                               "ROBOT",
                               "ANGEL",
                               "SPIDER",
                               "SCUBA DIVER",
                               "AFRICA",
                               "LONDON",
                               "ROCK",
                               "BED",
                               "CIRCLE",
                               "MAMMOTH",
                               "COMIC",
                               "BEIJING",
                               "RACKET",
                               "SOUL",
                               "EUROPE",
                               "PHOENIX",
                               "DROP",
                               "FIGHTER",
                               "WAKE",
                               "GLOVE",
                               "STREAM",
                               "SHOE",
                               "MOLE",
                               "SKYSCRAPER",
                               "LASER",
                               "BAR",
                               "FILE",
                               "WHIP",
                               "OCTOPUS",
                               "MASS",
                               "BAT",
                               "OLYMPUS",
                               "NINJA",
                               "TURKEY",
                               "MINE",
                               "TRIP",
                               "CRANE",
                               "SWITCH",
                               "STRAW",
                               "GLASS",
                               "BEAR",
                               "MICROSCOPE",
                               "JET",
                               "ORANGE",
                               "TEMPLE",
                               "THUMB",
                               "ANTARCTICA",
                               "CHAIR",
                               "WATER",
                               "AZTEC",
                               "MAPLE",
                               "TAG",
                               "ICE",
                               "CONTRACT",
                               "MARCH",
                               "RULER",
                               "BOMB",
                               "CRASH",
                               "TAIL",
                               "SOCK",
                               "NUT",
                               "SCIENTIST",
                               "SPIKE",
                               "KEY",
                               "ALIEN",
                               "FRANCE",
                               "BLOCK",
                               "RABBIT",
                               "ICE CREAM",
                               "NEEDLE",
                               "SHOP",
                               "WALL",
                               "PANTS",
                               "CROWN",
                               "HIMALAYAS",
                               "LIFE",
                               "LAP",
                               "DEATH",
                               "STOCK",
                               "CHURCH",
                               "KNIFE",
                               "ARM",
                               "BERMUDA",
                               "MUG",
                               "CONCERT",
                               "BALL",
                               "DOCTOR",
                               "COVER",
                               "CELL",
                               "BOOT",
                               "GHOST",
                               "WHALE",
                               "DIAMOND",
                               "BUCK",
                               "AGENT",
                               "HOTEL",
                               "PARACHUTE",
                               "FIELD",
                               "TRAIN",
                               "LAB",
                               "CLIFF",
                               "AIR",
                               "CALF",
                               "FIGURE",
                               "PARK",
                               "EGYPT",
                               "THEATRE",
                               "NOVEL",
                               "PIPE",
                               "KANGAROO",
                               "STRIKE",
                               "IRON",
                               "MATCH",
                               "JUPITER",
                               "SHARK",
                               "PYRAMID",
                               "OPERA",
                               "TABLET",
                               "SLIP",
                               "FOREST",
                               "BOTTLE",
                               "ROME",
                               "PLANE",
                               "PIANO",
                               "SPOT",
                               "FILM",
                               "BUTTON",
                               "BANK",
                               "BOOM",
                               "WITCH",
                               "KETCHUP",
                               "DINOSAUR",
                               "BILL",
                               "RING",
                               "DUCK",
                               "BOND",
                               "PAN",
                               "HAND",
                               "SWING",
                               "AMERICA",
                               "IVORY",
                               "VET",
                               "VAN",
                               "BUGLE",
                               "PART",
                               "DWARF",
                               "PLASTIC",
                               "PUMPKIN",
                               "TEACHER",
                               "NET",
                               "MOON",
                               "BARK",
                               "THIEF",
                               "COOK",
                               "REVOLUTION",
                               "CRICKET",
                               "COLD",
                               "STATE",
                               "TORCH",
                               "OLIVE",
                               "GRACE",
                               "ROULETTE",
                               "MERCURY",
                               "DAY",
                               "MILLIONAIRE",
                               "COPPER",
                               "JACK",
                               "STADIUM",
                               "DRAGON",
                               "LITTER",
                               "HEAD",
                               "DEGREE",
                               "BOW",
                               "PIE",
                               "KNIGHT",
                               "SOUND",
                               "PAPER",
                               "TRIANGLE",
                               "CAP",
                               "COMPOUND",
                               "SLUG",
                               "BELT",
                               "LIGHT",
                               "BEAT",
                               "HOLE",
                               "CYCLE",
                               "TELESCOPE",
                               "ATLANTIS",
                               "VACUUM",
                               "CODE",
                               "KIWI",
                               "BERRY",
                               "SOLDIER",
                               "HORSE",
                               "PIRATE",
                               "TICK",
                               "GOLD",
                               "SHIP",
                               "DICE",
                               "MODEL",
                               "TOKYO",
                               "STAFF",
                               "MARBLE",
                               "CAR",
                               "WAVE",
                               "HOLLYWOOD",
                               "WELL",
                               "MEXICO",
                               "EYE",
                               "DRAFT",
                               "HAM",
                               "HORSESHOE",
                               "HONEY",
                               "ROUND",
                               "INDIA",
                               "DATE",
                               "DRILL",
                               "BOX",
                               "MOUNT",
                               "TABLE",
                               "TIE",
                               "GENIUS",
                               "EAGLE",
                               "KING",
                               "PITCH",
                               "PIN",
                               "WASHINGTON",
                               "COURT",
                               "SPRINT"]
        for _ in 0...24 {
            let randomWordIndex = Int(arc4random_uniform(UInt32(word.count)))
            gameWords.append(word[randomWordIndex])
            word.remove(at: randomWordIndex)
            
            if(1 == color){
                let randomColorIndex = Int(arc4random_uniform(UInt32(redColor.count)))
                gameMap.append(redColor[randomColorIndex])
                redColor.remove(at: randomColorIndex)
            }else{
                let randomColorIndex = Int(arc4random_uniform(UInt32(blueColor.count)))
                gameMap.append(blueColor[randomColorIndex])
                blueColor.remove(at: randomColorIndex)
            }
        }
        
        print(gameWords)
        print(gameMap)
    }
    
    
    
}
