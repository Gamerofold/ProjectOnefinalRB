//
//  ViewController.swift
//  ProjectOne
//
//  Created by Robert Whitehead on 9/27/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
//    var currentUsers: [String] = []
    
//    let usersRef = Database.database().reference(withPath: "online")

    @IBOutlet var loginIDText: UITextField!
    @IBOutlet var loginPWText: UITextField!
    @IBOutlet var currentUserText: UILabel!
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            Auth.auth().signIn(withEmail: loginIDText.text!,
                               password: loginPWText.text!)
                return
        }
        if userEmail == loginIDText.text {
            performSegue(withIdentifier: "LoginToList", sender: nil)
            return
        }
        let tPW = loginPWText.text!
        signoutButton(sender)
        loginPWText.text = tPW
        Auth.auth().signIn(withEmail: loginIDText.text!,
                           password: tPW)
    }
    @IBAction func signoutButton(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        loginPWText.text = ""
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
            dismiss(animated: true, completion: nil)
        } catch let signOutError as Error {
            print ("Error signing out: %@", signOutError)
        }
        guard let userEmail = Auth.auth().currentUser?.email else {
            currentUserText.text = "No current user logged in."
            return
        }
        currentUserText.text = "Current user: " + userEmail
    }
    @IBAction func signupButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in

                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]

                                        Auth.auth().createUser(withEmail: emailField.text!,
                                           password: passwordField.text!) { user, error in
                                            if error == nil {                                                                  Auth.auth().signIn(withEmail: self.loginIDText.text!,
                                               password: self.loginPWText.text!)
                                            }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    
    

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let usersRef = Database.database().reference(withPath: "online")
//        usersRef.observe(.childAdded, with: { snap in
//            // 2
//            guard let email = snap.value as? String else { return }
//            self.currentUsers.append(email)
//            // 3
//            let row = self.currentUsers.count - 1
//            // 4
//            let indexPath = IndexPath(row: row, section: 0)
//            // 5
//            self.tableView.insertRows(at: [indexPath], with: .top)
//        })
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToList", sender: nil)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            currentUserText.text = "No current user logged in."
            return
        }
        currentUserText.text = "Current user: " + userEmail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginIDText {
            loginPWText.becomeFirstResponder()
        }
        if textField == loginPWText {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
