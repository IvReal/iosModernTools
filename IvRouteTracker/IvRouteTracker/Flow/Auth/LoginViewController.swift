//
//  LoginViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    let disposeBag = DisposeBag()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view?.addGestureRecognizer(hideKeyboardGesture)
        loginView.delegate = self
        loginView.returnKeyType = .continue
        passwordView.delegate = self
        passwordView.returnKeyType = .done
        
        Observable
            .combineLatest(
                loginView.rx.text,
                passwordView.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && !(password ?? "").isEmpty
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
            }
            .disposed(by: disposeBag)
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
            login(textField)
        }
        return true
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
