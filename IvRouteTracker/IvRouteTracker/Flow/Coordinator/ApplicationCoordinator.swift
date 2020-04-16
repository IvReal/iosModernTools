//
//  ApplicationCoordinator.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit

final class ApplicationCoordinator: BaseCoordinator {
    
    override func start() {
        toAuth()
    }
    
    private func toAuth() {
        // Создаём координатор сценария авторизации
        let coordinator = AuthCoordinator()
        // Устанавливаем ему поведение на завершение
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            // Так как подсценарий завершился, держать его в памяти больше не нужно
            self?.removeDependency(coordinator)
            // Заново запустим главный координатор, чтобы выбрать выбрать следующий сценарий
            self?.start()
        }
        // Сохраним ссылку на дочерний координатор, чтобы он не выгружался из памяти
        addDependency(coordinator)
        // Запустим сценарий дочернего координатора
        coordinator.start()
    }
    
}
