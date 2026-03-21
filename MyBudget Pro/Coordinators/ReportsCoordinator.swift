//
//  ReportsCoordinator.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import UIKit

final class ReportsCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = ReportsViewModel()
        let vc = ReportsViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }
}
