//
//  MessagesTableViewController.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-08.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import FirebaseAuth
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
    }

    @IBAction func SignOut(_ sender: Any) {
       try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
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
