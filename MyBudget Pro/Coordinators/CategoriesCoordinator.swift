//
//  CategoriesCoordinator.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import UIKit

final class CategoriesCoordinator: Coordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = CategoriesViewController()   // ✅ NO ARGUMENTS
        navigationController.setViewControllers([vc], animated: false)
    }
}
