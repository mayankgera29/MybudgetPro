//
//  ReportsViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class ReportsViewController: UIViewController {

    private let viewModel = ReportsViewModel()

    private let pieChart = PieChartView()
    private let stackView = UIStackView()
    private let totalLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reports"
        view.backgroundColor = .systemBackground

        setupChart()
        setupLegend()
        setupTotal()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 🔥 Animate after layout is complete
        pieChart.configure(with: viewModel.pieSlices)
        updateLegend()
        updateTotal()
    }

    // MARK: - Pie Chart
    private func setupChart() {
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pieChart)

        NSLayoutConstraint.activate([
            pieChart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40), // 🔥 below navbar
            pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pieChart.widthAnchor.constraint(equalToConstant: 240),
            pieChart.heightAnchor.constraint(equalToConstant: 240)
        ])
    }

    // MARK: - Legend
    private func setupLegend() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func updateLegend() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for summary in viewModel.summaries {
            stackView.addArrangedSubview(makeLegendRow(summary))
        }
    }

    private func makeLegendRow(_ summary: ReportsViewModel.CategorySummary) -> UIView {

        let row = UIView()
        row.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let dot = UIView()
        dot.backgroundColor = summary.category.color
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "\(summary.category.title)  ₹\(Int(summary.amount))"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(dot)
        row.addSubview(label)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        return row
    }

    // MARK: - Total
    private func setupTotal() {
        totalLabel.font = .boldSystemFont(ofSize: 22)
        totalLabel.textAlignment = .center
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(totalLabel)

        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            totalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func updateTotal() {
        totalLabel.text = "Total: ₹\(Int(viewModel.totalAmount))"
    }
}
