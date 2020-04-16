//
//  LoginViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    @IBAction func login(_ sender: Any) {
        // При нажатии на кнопку «Вход» ищите пользователя в базе данных по его логину, затем проверьте пароль.
        // Если данные верны, авторизуйте пользователя.
        guard
            let login = loginView.text,
            let password = passwordView.text,
            login != "" && password != ""
        else {
            showAlert("Warning", "Login and password required")
            return
        }
        if AuthService.instance.checkUser(login: login, password: password) {
            onLogin?()
        } else {
            showAlert("Warning", "Incorrect login and/or password")
        }
    }
    
    @IBAction func register(_ sender: Any) {
        onRegister?()
    }

}
