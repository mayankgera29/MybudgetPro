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

    private let cardView = UIView()
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
        addDoneButtonToKeyboard()
        validateForm()
    }

    // MARK: - UI Setup (SIMPLE & SAFE)
    private func setupUI() {

        // CATEGORY
        categoryButton.setTitle("Select Category", for: .normal)
        categoryButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        categoryButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false

        // CARD (RECTANGLE)
        cardView.backgroundColor = UIColor.secondarySystemBackground
        cardView.layer.cornerRadius = 14
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // AMOUNT
        amountTextField.placeholder = "Amount"
        amountTextField.keyboardType = .decimalPad
        amountTextField.borderStyle = .none
        amountTextField.delegate = self

        // NOTE
        noteTextField.placeholder = "Note (optional)"
        noteTextField.borderStyle = .none
        noteTextField.delegate = self

        // STACK INSIDE CARD
        let cardStack = UIStackView(arrangedSubviews: [
            amountTextField,
            noteTextField
        ])
        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(cardStack)

        // DATE
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        // SAVE
        saveButton.setTitle("Save Expense", for: .normal)
        saveButton.backgroundColor = .systemGray
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // ADD TO VIEW
        view.addSubview(categoryButton)
        view.addSubview(cardView)
        view.addSubview(datePicker)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            // CATEGORY
            categoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // CARD
            cardView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // DATE
            datePicker.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // SAVE (JUST BELOW CATEGORY SECTION)
            saveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        ]
        amountTextField.inputAccessoryView = toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Category Picker
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
    private func validateForm() {
        let valid = Double(amountTextField.text ?? "") != nil && selectedCategory != nil
        saveButton.isEnabled = valid
        saveButton.backgroundColor = valid ? AppTheme.primary : .systemGray
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
