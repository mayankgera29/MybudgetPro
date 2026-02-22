//
//  AddExpenseViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//
import UIKit

final class AddExpenseViewController: UIViewController, UITextFieldDelegate {

    // MARK: - UI
    private let categoryButton = UIButton(type: .system)

    private let amountCard = UIView()
    private let noteCard = UIView()

    private let amountTextField = UITextField()
    private let noteTextField = UITextField()
    

    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)

    // MARK: - Data
    private var selectedCategory: CategoryType? {
        didSet { validateForm() }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Expense"
        view.backgroundColor = .systemBackground

        setupUI()
        setupKeyboardDismiss()
        validateForm()
    }

    // MARK: - UI Setup
    private func setupUI() {

        // CATEGORY
        categoryButton.setTitle("Select Category", for: .normal)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        categoryButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false

        // AMOUNT CARD
        amountCard.backgroundColor = .secondarySystemBackground
        amountCard.layer.cornerRadius = 14
        amountCard.translatesAutoresizingMaskIntoConstraints = false

        amountTextField.placeholder = "Amount"
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        // DONE BUTTON (RIGHT OF AMOUNT)
       
        // HORIZONTAL STACK (Amount + Done)
        let amountRow = UIStackView(arrangedSubviews: [
            amountTextField
        ])
        amountRow.axis = .horizontal
        amountRow.spacing = 12
        amountRow.alignment = .center
        amountRow.translatesAutoresizingMaskIntoConstraints = false

        amountTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        

        amountCard.addSubview(amountRow)

        // NOTE CARD
        noteCard.backgroundColor = .secondarySystemBackground
        noteCard.layer.cornerRadius = 14
        noteCard.translatesAutoresizingMaskIntoConstraints = false

        noteTextField.placeholder = "Note (optional)"
        noteTextField.delegate = self
        noteTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        noteCard.addSubview(noteTextField)
        noteTextField.translatesAutoresizingMaskIntoConstraints = false

        // DATE
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        // SAVE BUTTON
        saveButton.setTitle("Save Expense", for: .normal)
        saveButton.backgroundColor = .systemGray
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // ADD TO VIEW
        [categoryButton, amountCard, noteCard, datePicker, saveButton].forEach {
            view.addSubview($0)
        }

        // CONSTRAINTS
        NSLayoutConstraint.activate([

            // CATEGORY
            categoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // AMOUNT CARD
            amountCard.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 20),
            amountCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            amountRow.topAnchor.constraint(equalTo: amountCard.topAnchor, constant: 16),
            amountRow.bottomAnchor.constraint(equalTo: amountCard.bottomAnchor, constant: -16),
            amountRow.leadingAnchor.constraint(equalTo: amountCard.leadingAnchor, constant: 16),
            amountRow.trailingAnchor.constraint(equalTo: amountCard.trailingAnchor, constant: -16),

            // NOTE CARD
            noteCard.topAnchor.constraint(equalTo: amountCard.bottomAnchor, constant: 16),
            noteCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            noteTextField.topAnchor.constraint(equalTo: noteCard.topAnchor, constant: 16),
            noteTextField.bottomAnchor.constraint(equalTo: noteCard.bottomAnchor, constant: -16),
            noteTextField.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 16),
            noteTextField.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor, constant: -16),

            // DATE
            datePicker.topAnchor.constraint(equalTo: noteCard.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // SAVE
            saveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Keyboard
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Category
    @objc private func selectCategory() {
        let picker = CategoryPickerViewController()
        picker.modalPresentationStyle = .pageSheet
        picker.onSelect = { [weak self] category in
            self?.selectedCategory = category
            self?.categoryButton.setTitle(category.title, for: .normal)
        }
        present(picker, animated: true)
    }

    // MARK: - Validation
    @objc private func textChanged() {
        validateForm()
    }

    private func validateForm() {
        let isAmountValid = Double(amountTextField.text ?? "") != nil
        let isValid = isAmountValid && selectedCategory != nil
        saveButton.isEnabled = isValid
        saveButton.backgroundColor = isValid ? AppTheme.primary : .systemGray
    }

    // MARK: - Save
    @objc private func saveTapped() {
        guard
            let amount = Double(amountTextField.text ?? ""),
            let category = selectedCategory
        else { return }

        let expense = Expense(
            id: UUID(),
            category: category,
            amount: amount,
            note: noteTextField.text ?? "",
            date: datePicker.date
        )

        ExpenseRepository.shared.addExpense(expense)
        navigationController?.popViewController(animated: true)
    }
}
