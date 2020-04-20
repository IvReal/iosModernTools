//
//  RegisterViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         
         let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
         self.view?.addGestureRecognizer(hideKeyboardGesture)
         loginView.delegate = self
         loginView.returnKeyType = .continue
         passwordView.delegate = self
         passwordView.returnKeyType = .done
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginView.becomeFirstResponder()
    }

    @objc func hideKeyboard() {
        self.view?.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === loginView {
            passwordView.becomeFirstResponder()
        } else if textField === passwordView {
            register(textField)
        }
        return true
    }

    @IBAction func register(_ sender: Any) {
        // При нажатии на кнопку регистрации создайте пользователя и запишите в базу данных.
        // Прежде чем делать запись, поищите в базе пользователя с таким логином.
        // Если он существует, измените ему пароль
        guard
            let login = loginView.text,
            let password = passwordView.text,
            login != "" && password != ""
        else {
            showAlert("Warning", "Login and password required")
            return
        }
        if AuthService.instance.registerUser(login: login, password: password) {
            showAlertOk("Info", "User was registered successfully") {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            showAlert("Error", "Error occured while user register")
        }
    }
    
}
