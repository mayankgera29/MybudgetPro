//
//  NameEntryViewController.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 30/01/26.
//


import UIKit

final class NameEntryViewController: UIViewController {

    // MARK: - UI
    private let gradientLayer = CAGradientLayer()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let button = UIButton(type: .system)

    // MARK: - Layout
    private var cardCenterYConstraint: NSLayoutConstraint!

    // MARK: - Callback
    var onFinish: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupUI()
        registerForKeyboardNotifications()
        setupDismissKeyboardTap()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = AppTheme.background

        let topColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.13, blue: 0.20, alpha: 1)
            : UIColor(red: 0.92, green: 0.95, blue: 1.00, alpha: 1)
        }

        let bottomColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.06, blue: 0.10, alpha: 1)
            : UIColor(red: 0.85, green: 0.90, blue: 0.98, alpha: 1)
        }

        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - UI Setup
    private func setupUI() {

        // Card
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = "Welcome 👋"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center

        // TextField
        textField.placeholder = "Enter your name"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(12)
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textField.returnKeyType = .done
        textField.delegate = self

        // Button
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = AppTheme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        // Stack
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            textField,
            button
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(stack)
        view.addSubview(cardView)

        // Constraints
        cardCenterYConstraint = cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardCenterYConstraint,
            cardView.widthAnchor.constraint(equalToConstant: 300),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Keyboard Handling
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        cardCenterYConstraint.constant = -keyboardFrame.height / 3

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        cardCenterYConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc private func continueTapped() {
        guard
            let name = textField.text?.trimmingCharacters(in: .whitespaces),
            !name.isEmpty
        else { return }

        UserSession.userName = name
        onFinish?()
    }

    private func setupDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension NameEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueTapped()
        return true
    }
}

// MARK: - Padding Helper
private extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}
