//
//  BudgetCoordinator.swift
//  MyBudget Pro
//

import UIKit

final class BudgetCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = BudgetViewController(viewModel: BudgetViewModel())
        navigationController.setViewControllers([vc], animated: false)
    }
}
