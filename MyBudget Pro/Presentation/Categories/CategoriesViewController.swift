//
//  CategoriesViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import UIKit
import Lottie

final class CategoriesViewController: UIViewController {

    private let viewModel = CategoriesViewModel()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let segmentedControl = UISegmentedControl(items: ["All", "Today", "This Month"])

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"
        
        view.backgroundColor = .systemBackground
        view.addBackgroundLottie(named: "background_motion")

        setupScroll()
        setupSegment()
        render()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        render() // ✅ refresh data when coming back
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    // MARK: - Scroll
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 2),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Segment
    private func setupSegment() {
        let card = UIView()
        card.applyCardStyle()
        card.heightAnchor.constraint(equalToConstant: 50).isActive = true

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = AppTheme.primary
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            segmentedControl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            segmentedControl.centerYAnchor.constraint(equalTo: card.centerYAnchor,constant: -2)
        ])

        contentStack.addArrangedSubview(card)
    }

    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 1: viewModel.setFilter(.today)
        case 2: viewModel.setFilter(.thisMonth)
        default: viewModel.setFilter(.all)
        }
        render()
    }

    // MARK: - Render
    private func render() {

        contentStack.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }

        let data = viewModel.getCategoryTotals()

        for (category, total) in data {

            let wrapper = UIView()
            wrapper.heightAnchor.constraint(equalToConstant: 88).isActive = true // 🔥 SAME AS HOME

            let cardHeight: CGFloat = 72

            let card = UIView()
            card.applyCardStyle()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
            card.isUserInteractionEnabled = true

            wrapper.addSubview(card)

            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
                card.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor)
            ])

            let tap = CategoryTapGesture(
                category: category,
                target: self,
                action: #selector(categoryTapped(_:))
            )
            card.addGestureRecognizer(tap)

            // 🔹 Lottie (same proportion as Home)
            let iconSize = cardHeight * 0.65
            let icon = LottieAnimationView(
                animation: LottieAnimation.named(category.lottieName)
            )
            icon.loopMode = .loop
            icon.play()
            icon.translatesAutoresizingMaskIntoConstraints = false

            // 🔹 Title
            let titleLabel = UILabel()
            titleLabel.text = category.title
            titleLabel.font = .boldSystemFont(ofSize: 15)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // 🔹 Amount (no cut, standard formatter)
            let amountLabel = UILabel()
            amountLabel.text = CurrencyFormatter.inr(total)
            amountLabel.font = .boldSystemFont(ofSize: 15)
            amountLabel.textAlignment = .right
            amountLabel.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(icon)
            card.addSubview(titleLabel)
            card.addSubview(amountLabel)

            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: iconSize),
                icon.heightAnchor.constraint(equalToConstant: iconSize),

                titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
                titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

                amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                amountLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                amountLabel.leadingAnchor.constraint(
                    greaterThanOrEqualTo: titleLabel.trailingAnchor,
                    constant: 8
                )
            ])

            contentStack.addArrangedSubview(wrapper)
        }
    }

    // MARK: - Tap
    @objc private func categoryTapped(_ gesture: CategoryTapGesture) {
        let vc = CategoryDetailViewController(category: gesture.category)
        navigationController?.pushViewController(vc, animated: true)
    }
}
