//
//  ReportsViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import UIKit

final class ReportsViewController: UITableViewController {

    private let viewModel = ReportsViewModel()

    // MARK: - State
    private var totalText: String = "₹0"
    private var insightText: String = "Loading insights…"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reports"

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false

        tableView.register(SummaryCell.self, forCellReuseIdentifier: "SummaryCell")
        tableView.register(PieChartCell.self, forCellReuseIdentifier: "PieChartCell")
        tableView.register(ProgressCell.self, forCellReuseIdentifier: "ProgressCell")
        tableView.register(InsightCell.self, forCellReuseIdentifier: "InsightCell")

        loadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExpenseUpdate),
            name: .expenseUpdated,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Data Loading
    @objc private func handleExpenseUpdate() {
        loadData()
    }

    private func loadData() {
        Task { [weak self] in
            guard let self else { return }

            self.totalText = await viewModel.totalConversionText()
            self.insightText = viewModel.differenceInsightText()

            self.tableView.reloadData()
        }
    }

    // MARK: - Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return viewModel.summaries.count
        case 3: return 1
        default: return 0
        }
    }

    // MARK: - Cells
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        // 🔝 SUMMARY (BIG TOTAL + USD)
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SummaryCell",
                for: indexPath
            ) as! SummaryCell

            cell.configure(
                totalText: totalText,
                topCategory: viewModel.topCategory
            )
            return cell

        // PIE CHART
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PieChartCell",
                for: indexPath
            ) as! PieChartCell

            cell.configure(
                slices: viewModel.pieSlices,
                total: viewModel.totalAmount
            )
            return cell

        // CATEGORY PROGRESS
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProgressCell",
                for: indexPath
            ) as! ProgressCell

            let item = viewModel.summaries[indexPath.row]
            cell.configure(
                category: item.category,
                amount: item.amount,
                max: viewModel.maxCategoryAmount
            )
            return cell

        // 🔽 INSIGHT (DIFFERENCE ONLY)
        default:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "InsightCell",
                for: indexPath
            ) as! InsightCell

            cell.configure(text: insightText)
            return cell
        }
    }

    // MARK: - Heights
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 120
        case 1: return 340
        case 2: return 78
        case 3: return 80
        default: return 44
        }
    }
}
