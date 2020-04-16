//
//  BaseCoordinator.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

class BaseCoordinator {
    
    var childCoordinators: [BaseCoordinator] = []
    
    func start() {
    }
    
    func addDependency(_ coordinator: BaseCoordinator) {
        for element in childCoordinators where element === coordinator {
            return
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: BaseCoordinator?) {
        guard
            childCoordinators.isEmpty == false,
            let coordinator = coordinator
            else { return }
        
        for (index, element) in childCoordinators.reversed().enumerated() where element === coordinator {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    func setAsRoot(_ controller: UIViewController) {
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
}
