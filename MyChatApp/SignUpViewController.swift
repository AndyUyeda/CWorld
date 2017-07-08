//
//  SignUpViewController.swift
//  
//
//  Created by Rayan Slim on 2017-07-06.
//
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SignUpViewController: UIViewController {

    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(showingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidingKeyboard), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func SignUp(_ sender: Any) {
        
        guard let email = email.text, let password = password.text, let fullname = fullname.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            if let error = error {
            
                self?.alert(message: error.localizedDescription)
                return
            }
            Database.database().reference().child("Users").child(user!.uid).updateChildValues(["email": email, "name": fullname])
            let table = self?.storyboard?.instantiateViewController(withIdentifier: "table") as! MessagesTableViewController
            self?.navigationController?.show(table, sender: nil)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
