//
//  BudgetEditorViewController.swift
//  MyBudget Pro
//

import UIKit

final class BudgetEditorViewController: UIViewController {

    // MARK: - Callbacks
    var onSave: ((Double) -> Void)?
    var onRemove: (() -> Void)?

    // MARK: - Config
    private let category: CategoryType
    private let currentLimit: Double

    init(category: CategoryType, currentLimit: Double) {
        self.category = category
        self.currentLimit = currentLimit
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let amountField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        setupUI()
        setupKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountField.becomeFirstResponder()
    }

    private func setupUI() {
        // Header
        let iconCircle = UIView()
        iconCircle.backgroundColor = category.color.withAlphaComponent(0.15)
        iconCircle.layer.cornerRadius = 30
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: category.sfSymbol, withConfiguration: iconCfg))
        iconView.tintColor = category.color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = "\(category.emoji)  \(category.title)"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Set monthly budget limit"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Amount input card
        let inputCard = UIView()
        inputCard.backgroundColor = AppTheme.cardBackground
        inputCard.layer.cornerRadius = 18
        inputCard.layer.shadowColor = UIColor.black.cgColor
        inputCard.layer.shadowOpacity = 0.06
        inputCard.layer.shadowRadius = 8
        inputCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        inputCard.translatesAutoresizingMaskIntoConstraints = false

        let currencyLabel = UILabel()
        currencyLabel.text = "₹"
        currencyLabel.font = .systemFont(ofSize: 28, weight: .bold)
        currencyLabel.textColor = AppTheme.primary
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false

        amountField.keyboardType = .decimalPad
        amountField.font = .systemFont(ofSize: 28, weight: .bold)
        amountField.textColor = .label
        amountField.placeholder = "0"
        amountField.translatesAutoresizingMaskIntoConstraints = false
        if currentLimit > 0 {
            amountField.text = String(format: "%.0f", currentLimit)
        }
        amountField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        inputCard.addSubview(currencyLabel)
        inputCard.addSubview(amountField)

        // Save button
        saveButton.setTitle("Save Budget", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = AppTheme.primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.layer.shadowColor = AppTheme.primary.cgColor
        saveButton.layer.shadowOpacity = 0.35
        saveButton.layer.shadowRadius = 10
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // Remove button (only if budget exists)
        removeButton.setTitle("Remove Budget", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        removeButton.setTitleColor(.systemRed, for: .normal)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.isHidden = currentLimit <= 0
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)

        view.addSubview(iconCircle)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(inputCard)
        view.addSubview(saveButton)
        view.addSubview(removeButton)

        NSLayoutConstraint.activate([
            iconCircle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            iconCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            iconCircle.widthAnchor.constraint(equalToConstant: 60),
            iconCircle.heightAnchor.constraint(equalToConstant: 60),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: iconCircle.topAnchor, constant: 4),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),

            inputCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputCard.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 28),
            inputCard.heightAnchor.constraint(equalToConstant: 72),

            currencyLabel.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 20),
            currencyLabel.centerYAnchor.constraint(equalTo: inputCard.centerYAnchor),

            amountField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8),
            amountField.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -20),
            amountField.centerYAnchor.constraint(equalTo: inputCard.centerYAnchor),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.topAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: 24),
            saveButton.heightAnchor.constraint(equalToConstant: 54),

            removeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16)
        ])

        updateSaveButton()
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        // Sheet handles keyboard avoidance automatically
    }

    @objc private func textChanged() { updateSaveButton() }

    private func updateSaveButton() {
        let valid = Double(amountField.text ?? "") != nil && !(amountField.text ?? "").isEmpty
        saveButton.alpha = valid ? 1.0 : 0.5
        saveButton.isEnabled = valid
    }

    @objc private func saveTapped() {
        guard let text = amountField.text, let amount = Double(text), amount > 0 else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss(animated: true) { [weak self] in
            self?.onSave?(amount)
        }
    }

    @objc private func removeTapped() {
        let alert = UIAlertController(title: "Remove Budget?",
                                      message: "This will delete the budget limit for \(category.title).",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true) { self?.onRemove?() }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
