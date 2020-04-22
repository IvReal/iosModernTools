//
//  AuthCoordinator.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

final class AuthCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showLoginModule()
    }
    
    private func showLoginModule() {
        let controller = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateViewController(LoginViewController.self)
        
        controller.onRegister = { [weak self] in
            self?.showRegisterModule()
        }
        
        controller.onLogin = { [weak self] in
            self?.toMain()
            //self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showRegisterModule() {
        let controller = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateViewController(RegisterViewController.self)
        
        controller.onRegister = { [weak self] in
            self?.toMain()
        }

        rootController?.pushViewController(controller, animated: true)
    }
    
    private func toMain() {
        // Создаём координатор главного сценария
        let coordinator = MainCoordinator()
        // Устанавливаем ему поведение на завершение
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            // Так как подсценарий завершился, держать его в памяти больше не нужно
            self?.removeDependency(coordinator)
            // Заново запустим главный координатор, чтобы выбрать следующий сценарий
            self?.start()
        }
        // Сохраним ссылку на дочерний координатор, чтобы он не выгружался из памяти
        addDependency(coordinator)
        // Запустим сценарий дочернего координатора
        coordinator.start()
    }

}
