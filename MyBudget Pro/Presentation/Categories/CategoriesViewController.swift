//
//  CategoriesViewController.swift
//  MyBudget Pro
//

import UIKit

final class CategoriesViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: CategoriesViewModel

    // MARK: - Init
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private let scrollView    = UIScrollView()
    private let contentStack  = UIStackView()
    private let segmentedControl = UISegmentedControl(items: ["All", "Today", "This Month"])

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = AppTheme.background
        view.addBackgroundLottie(named: "background_motion")
        setupScroll()
        setupSegment()
        render()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        render()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        view.refreshAppGradient()
        render()
    }

    // MARK: - Scroll
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Segment
    private func setupSegment() {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = AppTheme.primary
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(segmentedControl)
        wrapper.addSubview(card)
        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 64),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            card.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            card.heightAnchor.constraint(equalToConstant: 48),
            segmentedControl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            segmentedControl.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        contentStack.addArrangedSubview(wrapper)
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
        if !data.isEmpty {
            let total = data.reduce(0) { $0 + $1.1 }
            contentStack.addArrangedSubview(buildSummaryBanner(total: total, count: data.count))
        }
        let topSpacer = UIView()
        topSpacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        contentStack.addArrangedSubview(topSpacer)
        for (category, total) in data {
            contentStack.addArrangedSubview(buildCategoryCard(category: category, total: total))
        }
        let bottomSpacer = UIView()
        bottomSpacer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        contentStack.addArrangedSubview(bottomSpacer)
    }

    // MARK: - Summary Banner
    private func buildSummaryBanner(total: Double, count: Int) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = AppTheme.primary
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppTheme.primary.cgColor
        card.layer.shadowOpacity = 0.3
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.translatesAutoresizingMaskIntoConstraints = false
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        let monthLabel = makeLabel(df.string(from: Date()).uppercased(), 10, .semibold, UIColor.white.withAlphaComponent(0.7))
        monthLabel.letterSpacing(1.2)
        let totalLabel = makeLabel(CurrencyFormatter.inr(total), 28, .bold, .white)
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.minimumScaleFactor = 0.7
        let subLabel = makeLabel("\(count) categories tracked", 12, .medium, UIColor.white.withAlphaComponent(0.75))
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: "chart.pie.fill", withConfiguration: iconCfg))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.25)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let leftStack = UIStackView(arrangedSubviews: [monthLabel, totalLabel, subLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 3
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(leftStack)
        card.addSubview(iconView)
        wrapper.addSubview(card)
        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 110),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -8),
            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            leftStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -12),
            iconView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44)
        ])
        return wrapper
    }

    // MARK: - Category Card
    private func buildCategoryCard(category: CategoryType, total: Double) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.heightAnchor.constraint(equalToConstant: 80).isActive = true
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.clipsToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        let innerClip = UIView()
        innerClip.layer.cornerRadius = 18
        innerClip.clipsToBounds = true
        innerClip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerClip)
        let bar = UIView()
        bar.backgroundColor = category.color
        bar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(bar)
        let circle = UIView()
        circle.backgroundColor = category.color.withAlphaComponent(0.15)
        circle.layer.cornerRadius = 20
        circle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(circle)
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: category.sfSymbol, withConfiguration: iconCfg))
        iconView.tintColor = category.color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(iconView)
        let titleLabel = makeLabel(category.title, 14, .semibold, .label)
        titleLabel.numberOfLines = 1
        let amountLabel = makeLabel(CurrencyFormatter.inr(total), 14, .bold, .label)
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let maxTotal = viewModel.maxCategoryTotal()
        let ratio = maxTotal > 0 ? CGFloat(total / maxTotal) : 0
        let progressBg = UIView()
        progressBg.backgroundColor = category.color.withAlphaComponent(0.12)
        progressBg.layer.cornerRadius = 2.5
        progressBg.translatesAutoresizingMaskIntoConstraints = false
        let progressFill = UIView()
        progressFill.backgroundColor = category.color.withAlphaComponent(0.6)
        progressFill.layer.cornerRadius = 2.5
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)
        card.addSubview(titleLabel)
        card.addSubview(amountLabel)
        card.addSubview(progressBg)
        wrapper.addSubview(card)
        let tap = CategoryTapGesture(category: category, target: self, action: #selector(categoryTapped(_:)))
        card.addGestureRecognizer(tap)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -4),
            innerClip.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: card.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 5),
            bar.leadingAnchor.constraint(equalTo: innerClip.leadingAnchor),
            bar.topAnchor.constraint(equalTo: innerClip.topAnchor),
            bar.bottomAnchor.constraint(equalTo: innerClip.bottomAnchor),
            bar.trailingAnchor.constraint(equalTo: innerClip.trailingAnchor),
            circle.leadingAnchor.constraint(equalTo: innerClip.trailingAnchor, constant: 12),
            circle.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -5),
            circle.widthAnchor.constraint(equalToConstant: 40),
            circle.heightAnchor.constraint(equalToConstant: 40),
            iconView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            progressBg.leadingAnchor.constraint(equalTo: circle.leadingAnchor),
            progressBg.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            progressBg.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            progressBg.heightAnchor.constraint(equalToConstant: 4),
            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: ratio)
        ])
        return wrapper
    }

    // MARK: - Tap
    @objc private func categoryTapped(_ gesture: CategoryTapGesture) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let detailVM = CategoryDetailViewModel(category: gesture.category)
        let vc = CategoryDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Helpers
    private func makeLabel(_ text: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
}

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        attributedText = NSAttributedString(string: text, attributes: [.kern: spacing])
    }
}
