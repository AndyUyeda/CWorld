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
class MessagesTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Add(_ sender: Any) {
        self.presentAlert()
    }

    @IBAction func SignOut(_ sender: Any) {
       try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func presentAlert() {
    let alertController = UIAlertController(title: "Email?", message: "Please write the email:", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] (_) in
            
            if let email = alertController.textFields?[0].text {
                self?.addContact(email: email)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    func addContact(email: String) {
        
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: {  [weak self] (snapshot) in
            
            let snapshot = JSON(snapshot.value as Any).dictionaryValue
            if let index = snapshot.index(where: { (key, value) -> Bool in
                return value["email"].stringValue == email
            }) {
            
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Contacts").child(snapshot[index].key).updateChildValues(["email": snapshot[index].value["email"].stringValue, "name": snapshot[index].value["name"].stringValue])
                self?.alert(message: "success")
            
            } else {
                self?.alert(message: "no such email")
            }
            
            
        })
    
    
    
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
