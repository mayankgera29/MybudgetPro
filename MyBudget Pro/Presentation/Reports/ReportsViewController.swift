//
//  ReportsViewController.swift
//  MyBudget Pro
//

import UIKit

final class ReportsViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: ReportsViewModel

    // MARK: - Init
    init(viewModel: ReportsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        tv.register(SummaryCell.self,     forCellReuseIdentifier: SummaryCell.reuseID)
        tv.register(PieChartCell.self,    forCellReuseIdentifier: PieChartCell.reuseID)
        tv.register(ProgressCell.self,    forCellReuseIdentifier: ProgressCell.reuseID)
        tv.register(InsightCell.self,     forCellReuseIdentifier: InsightCell.reuseID)
        tv.register(EmptyReportCell.self, forCellReuseIdentifier: EmptyReportCell.reuseID)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - State
    private var totalText: String = ""
    private var insightText: String = ""
    private var summaries: [ReportsViewModel.CategorySummary] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reports"
        view.backgroundColor = AppTheme.background
        setupTableView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExpenseUpdate),
            name: .expenseUpdated,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Safety reload in case frame wasn't ready in viewWillAppear
        if tableView.numberOfSections == 0 {
            refreshData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        view.refreshAppGradient()
        tableView.reloadData()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Setup
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data
    @objc private func handleExpenseUpdate() {
        refreshData()
    }

    private func refreshData() {
        summaries = viewModel.summaries
        insightText = viewModel.differenceInsightText()
        totalText = summaries.isEmpty ? "₹0" : CurrencyFormatter.inr(viewModel.totalAmount)
        tableView.reloadData()

        guard !summaries.isEmpty else { return }

        Task { [weak self] in
            guard let self else { return }
            let text = await viewModel.totalConversionText()
            await MainActor.run {
                self.totalText = text
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ReportsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        summaries.isEmpty ? 1 : 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if summaries.isEmpty { return 1 }
        switch section {
        case 0: return 1                  // Summary
        case 1: return 1                  // Pie chart
        case 2: return summaries.count    // Progress bars
        case 3: return 1                  // Insight
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if summaries.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyReportCell.reuseID, for: indexPath) as! EmptyReportCell
            return cell
        }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.reuseID, for: indexPath) as! SummaryCell
            cell.configure(totalText: totalText, topCategory: viewModel.topCategory)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PieChartCell.reuseID, for: indexPath) as! PieChartCell
            cell.configure(slices: viewModel.pieSlices, total: viewModel.totalAmount)
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProgressCell.reuseID, for: indexPath) as! ProgressCell
            let item = summaries[indexPath.row]
            cell.configure(category: item.category, amount: item.amount, max: viewModel.maxCategoryAmount)
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: InsightCell.reuseID, for: indexPath) as! InsightCell
            cell.configure(text: insightText)
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if summaries.isEmpty { return 300 }
        switch indexPath.section {
        case 0: return 120
        case 1: return 300
        case 2: return 74
        case 3: return UITableView.automaticDimension
        default: return 44
        }
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 3 ? 110 : 74
    }
}

// MARK: - Empty state cell
final class EmptyReportCell: UITableViewCell {
    static let reuseID = "EmptyReportCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let icon = UIImageView(image: UIImage(systemName: "chart.pie.fill"))
        icon.tintColor = AppTheme.primary.withAlphaComponent(0.4)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Add expenses to see your reports"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 72),
            icon.heightAnchor.constraint(equalToConstant: 72),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
