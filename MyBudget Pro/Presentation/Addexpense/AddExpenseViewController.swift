//
//  AddExpenseViewController.swift
//  MyBudget Pro
//

import UIKit

final class AddExpenseViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Dependencies
    private let viewModel: AddExpenseViewModel

    init(viewModel: AddExpenseViewModel = AddExpenseViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let categoryButton = UIButton(type: .system)
    private let categoryColorBar = UIView()

    private let amountTextField = UITextField()
    private let noteTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)

    // MARK: - State
    private var selectedCategory: CategoryType? {
        didSet { updateCategoryButton(); validateForm() }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Expense"
        view.backgroundColor = AppTheme.background
        setupScrollView()
        setupForm()
        setupKeyboardDismiss()
        validateForm()
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

    // MARK: - Scroll
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        // Save button pinned to bottom, outside scroll
        saveButton.setTitle("Save Expense", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = .systemGray3
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Inset scroll content so it doesn't hide behind the pinned button
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 88, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    // MARK: - Form
    private func setupForm() {
        contentStack.addArrangedSubview(makeSectionLabel("Category"))
        contentStack.addArrangedSubview(makeCategoryButton())
        contentStack.addArrangedSubview(makeSectionLabel("Amount"))
        contentStack.addArrangedSubview(makeAmountField())
        contentStack.addArrangedSubview(makeSectionLabel("Note"))
        contentStack.addArrangedSubview(makeNoteField())
        contentStack.addArrangedSubview(makeSectionLabel("Date"))
        contentStack.addArrangedSubview(makeDateRow())
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .secondaryLabel
        label.letterSpacing(1.2)
        return label
    }

    private func makeCategoryButton() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.07
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        categoryColorBar.backgroundColor = .systemGray5
        categoryColorBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(categoryColorBar)

        categoryButton.setTitle("  Tap to select a category", for: .normal)
        categoryButton.setTitleColor(.secondaryLabel, for: .normal)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(categoryButton)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            categoryColorBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            categoryColorBar.topAnchor.constraint(equalTo: container.topAnchor),
            categoryColorBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            categoryColorBar.widthAnchor.constraint(equalToConstant: 5),

            categoryButton.leadingAnchor.constraint(equalTo: categoryColorBar.trailingAnchor, constant: 14),
            categoryButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        return container
    }

    private func makeAmountField() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.07
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let prefix = UILabel()
        prefix.text = "₹"
        prefix.font = .boldSystemFont(ofSize: 22)
        prefix.textColor = AppTheme.primary
        prefix.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(prefix)

        amountTextField.placeholder = "0.00"
        amountTextField.keyboardType = .decimalPad
        amountTextField.font = .boldSystemFont(ofSize: 22)
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(amountTextField)

        NSLayoutConstraint.activate([
            prefix.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            prefix.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            amountTextField.leadingAnchor.constraint(equalTo: prefix.trailingAnchor, constant: 8),
            amountTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            amountTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeNoteField() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.07
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "pencil"))
        icon.tintColor = .tertiaryLabel
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        noteTextField.placeholder = "Add a note (optional)"
        noteTextField.font = .systemFont(ofSize: 16)
        noteTextField.delegate = self
        noteTextField.returnKeyType = .done
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(noteTextField)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            noteTextField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            noteTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            noteTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeDateRow() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.07
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "calendar"))
        icon.tintColor = AppTheme.primary
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            datePicker.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            datePicker.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    // MARK: - Category Update
    private func updateCategoryButton() {
        guard let cat = selectedCategory else { return }
        let title = "  \(cat.emoji)  \(cat.title)"
        categoryButton.setTitle(title, for: .normal)
        categoryButton.setTitleColor(.label, for: .normal)
        categoryColorBar.backgroundColor = cat.color
    }

    // MARK: - Keyboard
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Actions
    @objc private func selectCategory() {
        let picker = CategoryPickerViewController()
        picker.modalPresentationStyle = .pageSheet
        picker.onSelect = { [weak self] category in
            self?.selectedCategory = category
        }
        present(picker, animated: true)
    }

    @objc private func textChanged() { validateForm() }

    private func validateForm() {
        let isValid = Double(amountTextField.text ?? "") != nil && selectedCategory != nil
        saveButton.isEnabled = isValid
        UIView.animate(withDuration: 0.2) {
            self.saveButton.backgroundColor = isValid ? AppTheme.primary : .systemGray3
            self.saveButton.transform = isValid ? .identity : CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }

    @objc private func saveTapped() {
        guard
            let amount = Double(amountTextField.text ?? ""),
            let category = selectedCategory
        else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.saveExpense(
            category: category,
            amount: amount,
            note: noteTextField.text ?? "",
            date: datePicker.date
        )
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UILabel helper
private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attributed = NSAttributedString(
            string: text,
            attributes: [.kern: spacing]
        )
        attributedText = attributed
    }
}
