//
//  HomeViewController 2.swift
//  MyBudget Pro
//
//  Created by mayank gera on 20/01/26.
//
import UIKit
import Lottie

final class HomeViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate {

    // MARK: - Properties
    private let viewModel = HomeViewModel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)

    // Theme toggle
    private var isDarkModeEnabled = false

    // Empty state Lottie
    private let emptyAnimation = LottieAnimationView(
        animation: LottieAnimation.named("wallet")
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"

        setupTable()
        setupFloatingButton()
        setupEmptyState()
        setupThemeToggleButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
        setupTableHeader()
        updateTableHeaderHeight()
        updateEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - Theme Toggle (FIXED)
    private func setupThemeToggleButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "moon.fill"),
            style: .plain,
            target: self,
            action: #selector(themeToggleTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    @objc private func themeToggleTapped() {

        isDarkModeEnabled.toggle()
        let style: UIUserInterfaceStyle = isDarkModeEnabled ? .dark : .light

        view.window?.overrideUserInterfaceStyle = style

        // 🔥 Update tab bar instance
        if let tabBarController = tabBarController as? MainTabBarController {
            tabBarController.applyTabBarTheme()
        }

        navigationItem.rightBarButtonItem?.image =
            UIImage(systemName: isDarkModeEnabled ? "sun.max.fill" : "moon.fill")

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }



    // MARK: - Empty State
    private func setupEmptyState() {
        emptyAnimation.loopMode = .loop
        emptyAnimation.animationSpeed = 1.0
        emptyAnimation.translatesAutoresizingMaskIntoConstraints = false
        emptyAnimation.isHidden = true

        view.addSubview(emptyAnimation)

        NSLayoutConstraint.activate([
            emptyAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            emptyAnimation.widthAnchor.constraint(equalToConstant: 220),
            emptyAnimation.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func updateEmptyState() {
        let isEmpty = viewModel.getExpenses().isEmpty
        emptyAnimation.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        isEmpty ? emptyAnimation.play() : emptyAnimation.stop()
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.frame = view.bounds
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = false

        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 83
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: tabBarHeight + 80,
            right: 0
        )
        tableView.scrollIndicatorInsets = tableView.contentInset

        view.addSubview(tableView)
    }

    // MARK: - Header
    private func setupTableHeader() {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black.withAlphaComponent(0.25)

        let titleLabel = UILabel()
        titleLabel.text = "Welcome back, Mayank 👋"
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Here are your recent transactions"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        [titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 32),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])

        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: 1
        )

        tableView.tableHeaderView = headerView
    }

    private func updateTableHeaderHeight() {
        guard let header = tableView.tableHeaderView else { return }

        header.setNeedsLayout()
        header.layoutIfNeeded()

        let height = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width,
                   height: UIView.layoutFittingCompressedSize.height)
        ).height

        if header.frame.height != height {
            header.frame.size.height = height
            tableView.tableHeaderView = header
        }
    }

    // MARK: - Floating Add Button
    private func setupFloatingButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = AppTheme.primary
        addButton.layer.cornerRadius = 28
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }

    @objc private func addTapped() {
        navigationController?.pushViewController(AddExpenseViewController(), animated: true)
    }

    // MARK: - Table DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.getExpenses().count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let expense = viewModel.getExpenses()[indexPath.row]
        let cardHeight: CGFloat = 72

        let card = UIView(frame: CGRect(
            x: 20,
            y: 6,
            width: tableView.bounds.width - 40,
            height: cardHeight
        ))
        card.applyCardStyle()

        let iconSize = cardHeight * 0.65
        let lottieView = LottieAnimationView(
            animation: LottieAnimation.named(expense.category.lottieName)
        )
        lottieView.frame = CGRect(
            x: 14,
            y: (cardHeight - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
        lottieView.loopMode = .loop
        lottieView.play()

        let titleLabel = UILabel(frame: CGRect(
            x: 14 + iconSize + 10,
            y: 12,
            width: card.bounds.width - 160,
            height: 20
        ))
        titleLabel.text = expense.category.title
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.textColor = .label

        let noteLabel = UILabel(frame: CGRect(
            x: 14 + iconSize + 10,
            y: 34,
            width: card.bounds.width - 160,
            height: 16
        ))
        noteLabel.text = expense.note.isEmpty ? "—" : expense.note
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textColor = .secondaryLabel

        let amountLabel = UILabel(frame: CGRect(
            x: card.bounds.width - 90,
            y: 26,
            width: 70,
            height: 20
        ))
        amountLabel.text = "₹\(expense.amount)"
        amountLabel.font = .boldSystemFont(ofSize: 15)
        amountLabel.textAlignment = .right
        amountLabel.textColor = .label

        card.addSubview(lottieView)
        card.addSubview(titleLabel)
        card.addSubview(noteLabel)
        card.addSubview(amountLabel)

        cell.contentView.addSubview(card)
        return cell
    }

    // MARK: - Row Height
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }

    // MARK: - Delete
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let expense = viewModel.getExpenses()[indexPath.row]
            viewModel.deleteExpense(id: expense.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateEmptyState()
        }
    }
}
