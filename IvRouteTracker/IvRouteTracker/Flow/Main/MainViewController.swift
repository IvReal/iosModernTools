//
//  MainViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var onMap: ((String) -> Void)?
    var onLogout: (() -> Void)?
    
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
     }

    @IBAction func showMap(_ sender: Any) {
        onMap?("example")
    }
    
    @IBAction func logout(_ sender: Any) {
        onLogout?()
    }
}
