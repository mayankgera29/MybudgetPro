//
//  AddSplitExpenseViewController.swift
//  MyBudget Pro
//

import UIKit

final class AddSplitExpenseViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Callback
    var onSave: (() -> Void)?

    // MARK: - Dependencies
    private let viewModel: SplitViewModel

    init(viewModel: SplitViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let scrollView       = UIScrollView()
    private let contentStack     = UIStackView()
    private let amountField      = UITextField()
    private let noteField        = UITextField()
    private let datePicker       = UIDatePicker()
    private let categoryButton   = UIButton(type: .system)
    private let categoryBar      = UIView()
    private let participantsStack = UIStackView()
    private let saveButton       = UIButton(type: .system)

    // Split type card buttons (4 options)
    private var splitTypeCards: [SplitTypeCard] = []
    private let splitTypeStack = UIStackView()

    // "Who paid?" row — shown for other-paid options
    private let whoPaidContainer = UIView()
    private var whoPaidPersonId: UUID? = nil

    // MARK: - State
    private var selectedCategory: CategoryType?
    private var selectedParticipants: Set<UUID> = []
    private var selectedSplitType: SplitType = .equal

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Split Expense"
        view.backgroundColor = AppTheme.background
        setupScrollView()
        buildForm()
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

    // MARK: - Scroll setup
    private func setupScrollView() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Save button pinned to bottom, outside scroll
        saveButton.setTitle("Save Split Expense", for: .normal)
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

    // MARK: - Build form
    private func buildForm() {
        contentStack.addArrangedSubview(sectionLabel("Category"))
        contentStack.addArrangedSubview(makeCategoryButton())
        contentStack.addArrangedSubview(sectionLabel("Total Amount"))
        contentStack.addArrangedSubview(makeAmountField())
        contentStack.addArrangedSubview(sectionLabel("Note"))
        contentStack.addArrangedSubview(makeNoteField())
        contentStack.addArrangedSubview(sectionLabel("Date"))
        contentStack.addArrangedSubview(makeDateRow())
        contentStack.addArrangedSubview(sectionLabel("Split Type"))
        contentStack.addArrangedSubview(makeSplitTypeCards())
        contentStack.addArrangedSubview(makeWhoPaidRow())
        contentStack.addArrangedSubview(sectionLabel("With"))
        contentStack.addArrangedSubview(makeParticipantsCard())
        contentStack.addArrangedSubview(makeSaveButton())

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Section label
    private func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    // MARK: - Category button
    private func makeCategoryButton() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        categoryBar.backgroundColor = .systemGray5
        categoryBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(categoryBar)

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
            categoryBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            categoryBar.topAnchor.constraint(equalTo: container.topAnchor),
            categoryBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            categoryBar.widthAnchor.constraint(equalToConstant: 5),
            categoryButton.leadingAnchor.constraint(equalTo: categoryBar.trailingAnchor, constant: 14),
            categoryButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])
        return container
    }

    // MARK: - Amount field
    private func makeAmountField() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let prefix = UILabel()
        prefix.text = "₹"
        prefix.font = .boldSystemFont(ofSize: 22)
        prefix.textColor = AppTheme.primary
        prefix.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(prefix)

        amountField.placeholder = "0.00"
        amountField.keyboardType = .decimalPad
        amountField.font = .boldSystemFont(ofSize: 22)
        amountField.delegate = self
        amountField.addTarget(self, action: #selector(formChanged), for: .editingChanged)
        amountField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(amountField)

        NSLayoutConstraint.activate([
            prefix.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            prefix.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            amountField.leadingAnchor.constraint(equalTo: prefix.trailingAnchor, constant: 8),
            amountField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            amountField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    // MARK: - Note field
    private func makeNoteField() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "pencil"))
        icon.tintColor = .tertiaryLabel
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        noteField.placeholder = "Add a note (optional)"
        noteField.font = .systemFont(ofSize: 16)
        noteField.delegate = self
        noteField.returnKeyType = .done
        noteField.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(noteField)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            noteField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            noteField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            noteField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    // MARK: - Date row
    private func makeDateRow() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.cardBackground
        container.layer.cornerRadius = 16
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

    // MARK: - Split type cards (4 options)
    private func makeSplitTypeCards() -> UIView {
        let options: [(SplitType, String, String, UIColor)] = [
            (.equal,           "Split Equally",          "You paid, split equally",          AppTheme.primary),
            (.paidByYou,       "Paid by You",             "You paid full for someone",         .systemGreen),
            (.equalPaidByOther,"Other Paid, Split Equal", "They paid, split equally",          .systemOrange),
            (.paidByOtherFull, "Other Paid, You Owe All", "They paid full for you",            .systemRed)
        ]

        splitTypeStack.axis = .vertical
        splitTypeStack.spacing = 8
        splitTypeStack.translatesAutoresizingMaskIntoConstraints = false

        // Two columns using two horizontal stacks
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        splitTypeCards = []
        for (index, (type, title, subtitle, color)) in options.enumerated() {
            let card = SplitTypeCard(splitType: type, title: title, subtitle: subtitle, accentColor: color)
            card.isSelected = (type == selectedSplitType)
            card.heightAnchor.constraint(equalToConstant: 76).isActive = true
            let tap = SplitTypeTapGesture(splitType: type, target: self, action: #selector(splitTypeCardTapped(_:)))
            card.addGestureRecognizer(tap)
            splitTypeCards.append(card)
            if index < 2 { row1.addArrangedSubview(card) } else { row2.addArrangedSubview(card) }
        }

        splitTypeStack.addArrangedSubview(row1)
        splitTypeStack.addArrangedSubview(row2)
        return splitTypeStack
    }

    // MARK: - Who paid row (shown for other-paid options)
    private func makeWhoPaidRow() -> UIView {
        whoPaidContainer.backgroundColor = AppTheme.cardBackground
        whoPaidContainer.layer.cornerRadius = 16
        whoPaidContainer.isHidden = true
        whoPaidContainer.translatesAutoresizingMaskIntoConstraints = false
        whoPaidContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "person.fill.questionmark"))
        icon.tintColor = .systemOrange
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        whoPaidContainer.addSubview(icon)

        let label = UILabel()
        label.text = "Who paid?"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.tag = 101
        label.translatesAutoresizingMaskIntoConstraints = false
        whoPaidContainer.addSubview(label)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.translatesAutoresizingMaskIntoConstraints = false
        whoPaidContainer.addSubview(chevron)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: whoPaidContainer.leadingAnchor, constant: 18),
            icon.centerYAnchor.constraint(equalTo: whoPaidContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: whoPaidContainer.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: whoPaidContainer.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: whoPaidContainer.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(whoPaidTapped))
        whoPaidContainer.addGestureRecognizer(tap)
        return whoPaidContainer
    }

    private func updateWhoPaidLabel() {
        guard let label = whoPaidContainer.viewWithTag(101) as? UILabel else { return }
        if let pid = whoPaidPersonId, let person = viewModel.person(for: pid) {
            label.text = person.name
            label.textColor = .label
        } else {
            label.text = "Who paid?"
            label.textColor = .secondaryLabel
        }
    }

    // MARK: - Participants card
    private func makeParticipantsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 16

        participantsStack.axis = .vertical
        participantsStack.spacing = 0
        participantsStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(participantsStack)

        NSLayoutConstraint.activate([
            participantsStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            participantsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            participantsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            participantsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])

        refreshParticipants()
        return card
    }

    private func refreshParticipants() {
        participantsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let addRow = makePersonRow(id: nil, name: "Add person…",
                                   avatarColor: AppTheme.primary, isSelected: false, isAddButton: true)
        participantsStack.addArrangedSubview(addRow)

        for person in viewModel.people {
            let row = makePersonRow(
                id: person.id,
                name: person.name,
                avatarColor: UIColor(hex: person.avatarColor) ?? AppTheme.primary,
                isSelected: selectedParticipants.contains(person.id),
                isAddButton: false
            )
            participantsStack.addArrangedSubview(row)
        }
    }

    private func makePersonRow(id: UUID?, name: String, avatarColor: UIColor, isSelected: Bool, isAddButton: Bool) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let avatar = UIView()
        avatar.backgroundColor = isAddButton ? AppTheme.primary.withAlphaComponent(0.12) : avatarColor.withAlphaComponent(0.2)
        avatar.layer.cornerRadius = 18
        avatar.translatesAutoresizingMaskIntoConstraints = false

        if isAddButton {
            let plusIcon = UIImageView(image: UIImage(systemName: "plus"))
            plusIcon.tintColor = AppTheme.primary
            plusIcon.contentMode = .scaleAspectFit
            plusIcon.translatesAutoresizingMaskIntoConstraints = false
            avatar.addSubview(plusIcon)
            NSLayoutConstraint.activate([
                plusIcon.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
                plusIcon.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
                plusIcon.widthAnchor.constraint(equalToConstant: 16),
                plusIcon.heightAnchor.constraint(equalToConstant: 16)
            ])
        } else {
            let initLabel = UILabel()
            initLabel.text = String(name.prefix(1)).uppercased()
            initLabel.font = .systemFont(ofSize: 14, weight: .bold)
            initLabel.textColor = avatarColor
            initLabel.textAlignment = .center
            initLabel.translatesAutoresizingMaskIntoConstraints = false
            avatar.addSubview(initLabel)
            NSLayoutConstraint.activate([
                initLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
                initLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
            ])
        }

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: isAddButton ? .medium : .semibold)
        nameLabel.textColor = isAddButton ? AppTheme.primary : .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImageView(image: UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle"))
        checkmark.tintColor = isSelected ? AppTheme.primary : .tertiaryLabel
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(avatar)
        row.addSubview(nameLabel)
        if !isAddButton { row.addSubview(checkmark) }

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        if !isAddButton {
            NSLayoutConstraint.activate([
                checkmark.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
                checkmark.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                checkmark.widthAnchor.constraint(equalToConstant: 22),
                checkmark.heightAnchor.constraint(equalToConstant: 22)
            ])
        }

        if isAddButton {
            let tap = UITapGestureRecognizer(target: self, action: #selector(addPersonTapped))
            row.addGestureRecognizer(tap)
        } else if let personId = id {
            let tap = PersonTapGesture(personId: personId, target: self, action: #selector(personRowTapped(_:)))
            row.addGestureRecognizer(tap)
        }
        return row
    }

    // MARK: - Save button
    private func makeSaveButton() -> UIView {
        let wrapper = UIView()
        wrapper.heightAnchor.constraint(equalToConstant: 80).isActive = true

        saveButton.setTitle("Save Split Expense", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = .systemGray3
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        wrapper.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            saveButton.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        return wrapper
    }

    // MARK: - Validation
    @objc private func formChanged() { validateForm() }

    private func validateForm() {
        let amount = Double(amountField.text ?? "") ?? 0
        let needsWhoPaid = (selectedSplitType == .equalPaidByOther || selectedSplitType == .paidByOtherFull)
        let whoPaidOk = !needsWhoPaid || whoPaidPersonId != nil
        let isValid = amount > 0 && selectedCategory != nil && !selectedParticipants.isEmpty && whoPaidOk
        saveButton.isEnabled = isValid
        UIView.animate(withDuration: 0.2) {
            self.saveButton.backgroundColor = isValid ? AppTheme.primary : .systemGray3
        }
    }

    // MARK: - Actions
    @objc private func selectCategory() {
        let picker = CategoryPickerViewController()
        picker.modalPresentationStyle = .pageSheet
        picker.onSelect = { [weak self] category in
            self?.selectedCategory = category
            self?.categoryBar.backgroundColor = category.color
            self?.categoryButton.setTitle("  \(category.emoji)  \(category.title)", for: .normal)
            self?.categoryButton.setTitleColor(.label, for: .normal)
            self?.validateForm()
        }
        present(picker, animated: true)
    }

    @objc private func splitTypeCardTapped(_ gesture: SplitTypeTapGesture) {
        selectedSplitType = gesture.splitType
        splitTypeCards.forEach { $0.isSelected = ($0.splitType == selectedSplitType) }

        let isOtherPaid = (selectedSplitType == .equalPaidByOther || selectedSplitType == .paidByOtherFull)
        UIView.animate(withDuration: 0.25) {
            self.whoPaidContainer.isHidden = !isOtherPaid
        }
        if !isOtherPaid { whoPaidPersonId = nil }
        validateForm()
    }

    @objc private func whoPaidTapped() {
        guard !viewModel.people.isEmpty else {
            let alert = UIAlertController(title: "No People", message: "Add people in the 'With' section first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let sheet = UIAlertController(title: "Who paid?", message: nil, preferredStyle: .actionSheet)
        for person in viewModel.people {
            sheet.addAction(UIAlertAction(title: person.name, style: .default) { [weak self] _ in
                self?.whoPaidPersonId = person.id
                self?.updateWhoPaidLabel()
                self?.validateForm()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func addPersonTapped() {
        let alert = UIAlertController(title: "Add Person", message: "Enter their name", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Name"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text,
                  !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            let person = self?.viewModel.addPerson(name: name)
            if let id = person?.id { self?.selectedParticipants.insert(id) }
            self?.refreshParticipants()
            self?.validateForm()
        })
        present(alert, animated: true)
    }

    @objc private func personRowTapped(_ gesture: PersonTapGesture) {
        let id = gesture.personId
        if selectedParticipants.contains(id) {
            selectedParticipants.remove(id)
        } else {
            selectedParticipants.insert(id)
        }
        refreshParticipants()
        validateForm()
    }

    @objc private func saveTapped() {
        guard let amount = Double(amountField.text ?? ""),
              let category = selectedCategory else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let meId = UserSession.meId
        var shares: [SplitShare] = []

        switch selectedSplitType {

        case .equal:
            // I paid, split equally among me + selected participants
            let allParticipants = selectedParticipants.union([meId])
            let perPerson = amount / Double(allParticipants.count)
            for pid in allParticipants {
                shares.append(SplitShare(personId: pid, amount: perPerson, isSettled: pid == meId))
            }
            let expense = SplitExpense(category: category, totalAmount: amount,
                                       note: noteField.text ?? "", date: datePicker.date,
                                       payerId: meId, splitType: .equal, shares: shares)
            viewModel.addExpense(expense)

        case .paidByYou:
            // I paid full for each selected person — they each owe me the full amount
            for pid in selectedParticipants {
                shares.append(SplitShare(personId: pid, amount: amount, isSettled: false))
            }
            shares.append(SplitShare(personId: meId, amount: 0, isSettled: true))
            let expense = SplitExpense(category: category, totalAmount: amount,
                                       note: noteField.text ?? "", date: datePicker.date,
                                       payerId: meId, splitType: .paidByYou, shares: shares)
            viewModel.addExpense(expense)

        case .equalPaidByOther:
            // Someone else paid, split equally — I owe my share
            guard let payerId = whoPaidPersonId else { return }
            let allParticipants = selectedParticipants.union([meId])
            let perPerson = amount / Double(allParticipants.count)
            for pid in allParticipants {
                shares.append(SplitShare(personId: pid, amount: perPerson, isSettled: pid == payerId))
            }
            let expense = SplitExpense(category: category, totalAmount: amount,
                                       note: noteField.text ?? "", date: datePicker.date,
                                       payerId: payerId, splitType: .equalPaidByOther, shares: shares)
            viewModel.addExpense(expense)

        case .paidByOtherFull:
            // Someone else paid full for me — I owe them the full amount
            guard let payerId = whoPaidPersonId else { return }
            shares.append(SplitShare(personId: meId, amount: amount, isSettled: false))
            shares.append(SplitShare(personId: payerId, amount: 0, isSettled: true))
            let expense = SplitExpense(category: category, totalAmount: amount,
                                       note: noteField.text ?? "", date: datePicker.date,
                                       payerId: payerId, splitType: .paidByOtherFull, shares: shares)
            viewModel.addExpense(expense)
        }

        onSave?()
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - SplitTypeCard
private final class SplitTypeCard: UIView {
    let splitType: SplitType
    private let titleLabel   = UILabel()
    private let subtitleLabel = UILabel()
    private let iconView     = UIImageView()
    private let accentColor: UIColor

    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    init(splitType: SplitType, title: String, subtitle: String, accentColor: UIColor) {
        self.splitType   = splitType
        self.accentColor = accentColor
        super.init(frame: .zero)
        layer.cornerRadius = 14
        layer.borderWidth  = 1.5

        let iconName: String
        switch splitType {
        case .equal:           iconName = "person.2.fill"
        case .paidByYou:       iconName = "arrow.up.circle.fill"
        case .equalPaidByOther: iconName = "arrow.down.circle.fill"
        case .paidByOtherFull: iconName = "person.fill.checkmark"
        }

        iconView.image = UIImage(systemName: iconName)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])

        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func updateAppearance() {
        if isSelected {
            backgroundColor = accentColor.withAlphaComponent(0.15)
            layer.borderColor = accentColor.cgColor
            titleLabel.textColor = accentColor
            subtitleLabel.textColor = accentColor.withAlphaComponent(0.7)
            iconView.tintColor = accentColor
        } else {
            backgroundColor = AppTheme.cardBackground
            layer.borderColor = UIColor.separator.cgColor
            titleLabel.textColor = .label
            subtitleLabel.textColor = .secondaryLabel
            iconView.tintColor = .tertiaryLabel
        }
    }
}

// MARK: - Gesture helpers
private final class PersonTapGesture: UITapGestureRecognizer {
    let personId: UUID
    init(personId: UUID, target: Any?, action: Selector?) {
        self.personId = personId
        super.init(target: target, action: action)
    }
}

private final class SplitTypeTapGesture: UITapGestureRecognizer {
    let splitType: SplitType
    init(splitType: SplitType, target: Any?, action: Selector?) {
        self.splitType = splitType
        super.init(target: target, action: action)
    }
}

// MARK: - UIColor hex init
extension UIColor {
    convenience init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   CGFloat((val >> 16) & 0xFF) / 255,
            green: CGFloat((val >> 8)  & 0xFF) / 255,
            blue:  CGFloat( val        & 0xFF) / 255,
            alpha: 1
        )
    }
}
