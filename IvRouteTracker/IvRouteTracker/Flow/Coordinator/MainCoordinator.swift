//
//  MainCoordinator.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

final class MainCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showMainModule()
    }
    
    private func showMainModule() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(MainViewController.self)
        
        controller.onMap = { [weak self] usseles in
            self?.showMapModule(usseles: usseles)
        }
        
        controller.onLogout = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showMapModule(usseles: String) {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(MapViewController.self)
        
        rootController?.pushViewController(controller, animated: true)
    }
    
}
