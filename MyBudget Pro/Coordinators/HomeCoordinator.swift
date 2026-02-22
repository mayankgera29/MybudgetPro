//
//  HomeCoordinator.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import UIKit

final class HomeCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let repository: ExpenseRepositoryProtocol

    init(
        navigationController: UINavigationController,
        repository: ExpenseRepositoryProtocol = ExpenseRepository.shared
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func start() {
        let viewModel = HomeViewModel(repository: repository)
        let homeVC = HomeViewController(viewModel: viewModel)

        navigationController.setViewControllers([homeVC], animated: false)
    }
}
