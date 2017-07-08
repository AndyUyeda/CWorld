//
//  SignInViewController.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-06.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import FirebaseAuth
class SignInViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(showingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }

    
    @IBAction func SignIn(_ sender: Any) {
        

        guard let email = email.text, let password = password.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if let error = error {
                self?.alert(message: error.localizedDescription)
                return
            }
            let table = self?.storyboard?.instantiateViewController(withIdentifier: "table") as! MessagesTableViewController
            self?.navigationController?.show(table, sender: nil)
        }
    }

    @IBAction func SignUp(_ sender: Any) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "SIGNUP") as! SignUpViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
