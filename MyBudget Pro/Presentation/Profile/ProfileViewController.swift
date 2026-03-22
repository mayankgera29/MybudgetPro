//
//  ProfileViewController.swift
//  MyBudget Pro
//

import UIKit

final class ProfileViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let avatarView   = UIView()
    private let avatarLabel  = UILabel()
    private let nameField    = UITextField()
    private let nameContainer = UIView()

    // Avatar color palette
    private let colorPalette: [(String, UIColor)] = [
        ("#6366F1", UIColor(red: 99/255,  green: 102/255, blue: 241/255, alpha: 1)),
        ("#EF4444", UIColor(red: 239/255, green: 68/255,  blue: 68/255,  alpha: 1)),
        ("#F97316", UIColor(red: 249/255, green: 115/255, blue: 22/255,  alpha: 1)),
        ("#22C55E", UIColor(red: 34/255,  green: 197/255, blue: 94/255,  alpha: 1)),
        ("#06B6D4", UIColor(red: 6/255,   green: 182/255, blue: 212/255, alpha: 1)),
        ("#8B5CF6", UIColor(red: 139/255, green: 92/255,  blue: 246/255, alpha: 1)),
        ("#EC4899", UIColor(red: 236/255, green: 72/255,  blue: 153/255, alpha: 1)),
    ]
    private var selectedColorHex: String = UserSession.avatarColor

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = AppTheme.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = AppTheme.primary
        setupScrollView()
        buildContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        view.refreshAppGradient()
    }

    private func setupScrollView() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func buildContent() {
        // Avatar section
        contentStack.addArrangedSubview(buildAvatarSection())
        // Name section
        contentStack.addArrangedSubview(buildNameSection())
        // Color picker
        contentStack.addArrangedSubview(buildColorSection())
        // Stats card
        contentStack.addArrangedSubview(buildStatsCard())

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Avatar
    private func buildAvatarSection() -> UIView {
        let wrapper = UIView()

        let color = UIColor(hex: selectedColorHex) ?? AppTheme.primary

        avatarView.backgroundColor = color.withAlphaComponent(0.18)
        avatarView.layer.cornerRadius = 50
        avatarView.layer.borderWidth = 3
        avatarView.layer.borderColor = color.cgColor
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        avatarLabel.text = String((UserSession.userName ?? "?").prefix(1)).uppercased()
        avatarLabel.font = .systemFont(ofSize: 40, weight: .bold)
        avatarLabel.textColor = color
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)

        let nameLabel = UILabel()
        nameLabel.text = UserSession.userName ?? "Your Name"
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let idLabel = UILabel()
        idLabel.text = "Member since \(memberSinceText())"
        idLabel.font = .systemFont(ofSize: 12, weight: .regular)
        idLabel.textColor = .secondaryLabel
        idLabel.textAlignment = .center
        idLabel.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(avatarView)
        wrapper.addSubview(nameLabel)
        wrapper.addSubview(idLabel)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            avatarView.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 14),
            nameLabel.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            idLabel.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    // MARK: - Name field
    private func buildNameSection() -> UIView {
        let wrapper = UIView()

        let sectionLabel = makeSectionLabel("Display Name")
        nameContainer.backgroundColor = AppTheme.cardBackground
        nameContainer.layer.cornerRadius = 16
        nameContainer.layer.borderWidth = 1.5
        nameContainer.layer.borderColor = AppTheme.primary.withAlphaComponent(0.2).cgColor
        nameContainer.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "person.fill"))
        icon.tintColor = AppTheme.primary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(icon)

        nameField.text = UserSession.userName
        nameField.font = .systemFont(ofSize: 16, weight: .medium)
        nameField.textColor = .label
        nameField.backgroundColor = .clear
        nameField.borderStyle = .none
        nameField.returnKeyType = .done
        nameField.delegate = self
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(nameField)

        wrapper.addSubview(sectionLabel)
        wrapper.addSubview(nameContainer)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: wrapper.topAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            nameContainer.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 8),
            nameContainer.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            nameContainer.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            nameContainer.heightAnchor.constraint(equalToConstant: 52),
            nameContainer.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            icon.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            nameField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            nameField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
            nameField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor)
        ])
        return wrapper
    }

    // MARK: - Color picker
    private func buildColorSection() -> UIView {
        let wrapper = UIView()
        let sectionLabel = makeSectionLabel("Avatar Color")

        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 12
        colorStack.distribution = .fillEqually
        colorStack.translatesAutoresizingMaskIntoConstraints = false

        for (hex, color) in colorPalette {
            let btn = ColorButton(hex: hex, color: color)
            btn.isSelected = hex == selectedColorHex
            btn.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
            colorStack.addArrangedSubview(btn)
        }

        wrapper.addSubview(sectionLabel)
        wrapper.addSubview(colorStack)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: wrapper.topAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            colorStack.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 12),
            colorStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            colorStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            colorStack.heightAnchor.constraint(equalToConstant: 40),
            colorStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    // MARK: - Stats card
    private func buildStatsCard() -> UIView {
        let storage = FileStorageService.shared
        let expenses: [Expense] = storage.load() ?? []
        let total = expenses.reduce(0) { $0 + $1.amount }
        let splitExpenses = SplitStorageService.shared.loadExpenses()

        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)

        let items: [(String, String, String)] = [
            ("Total Expenses", "\(expenses.count)", "list.bullet"),
            ("Total Spent", CurrencyFormatter.inr(total), "indianrupeesign.circle"),
            ("Split Expenses", "\(splitExpenses.count)", "person.2.fill")
        ]

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        for (title, value, symbol) in items {
            let item = buildStatItem(title: title, value: value, symbol: symbol)
            stack.addArrangedSubview(item)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func buildStatItem(title: String, value: String, symbol: String) -> UIView {
        let v = UIView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let icon = UIImageView(image: UIImage(systemName: symbol, withConfiguration: cfg))
        icon.tintColor = AppTheme.primary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valLabel.textColor = .label
        valLabel.textAlignment = .center
        valLabel.adjustsFontSizeToFitWidth = true
        valLabel.minimumScaleFactor = 0.7
        valLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        v.addSubview(icon)
        v.addSubview(valLabel)
        v.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: v.topAnchor),
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            valLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 6),
            valLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 4),
            valLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: valLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: v.bottomAnchor)
        ])
        return v
    }

    // MARK: - Actions
    @objc private func colorTapped(_ sender: ColorButton) {
        selectedColorHex = sender.hex
        let color = UIColor(hex: selectedColorHex) ?? AppTheme.primary

        // Update avatar preview
        avatarView.backgroundColor = color.withAlphaComponent(0.18)
        avatarView.layer.borderColor = color.cgColor
        avatarLabel.textColor = color

        // Update button states
        if let stack = sender.superview as? UIStackView {
            stack.arrangedSubviews.compactMap { $0 as? ColorButton }.forEach { $0.isSelected = $0.hex == selectedColorHex }
        }
    }

    @objc private func saveTapped() {
        guard let name = nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UserSession.userName = name
        UserSession.avatarColor = selectedColorHex
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Helpers
    private func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func memberSinceText() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df.string(from: Date())
    }
}

// MARK: - ColorButton
private final class ColorButton: UIButton {
    let hex: String
    private let colorView = UIView()

    init(hex: String, color: UIColor) {
        self.hex = hex
        super.init(frame: .zero)
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 16
        colorView.isUserInteractionEnabled = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: topAnchor),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isSelected: Bool {
        didSet {
            colorView.layer.borderWidth = isSelected ? 3 : 0
            colorView.layer.borderColor = UIColor.white.cgColor
            colorView.transform = isSelected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
        }
    }
}
