//
//  NameEntryViewController.swift
//  MyBudget Pro
//

import UIKit

final class NameEntryViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: NameEntryViewModel

    // MARK: - Init
    init(viewModel: NameEntryViewModel = NameEntryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let gradientLayer    = CAGradientLayer()
    private let cardView         = UIView()
    private let iconCircle       = UIView()
    private let iconImageView    = UIImageView()
    private let titleLabel       = UILabel()
    private let subtitleLabel    = UILabel()
    private let fieldContainer   = UIView()
    private let textField        = UITextField()
    private let fieldFocusRing   = UIView()
    private let continueButton   = UIButton(type: .system)

    private var cardCenterYConstraint: NSLayoutConstraint!
    var onFinish: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupOrbs()
        setupCard()
        registerForKeyboardNotifications()
        setupDismissKeyboardTap()
        animateIn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        gradientLayer.colors = AppTheme.splashGradient(for: traitCollection)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = AppTheme.background
        gradientLayer.colors = AppTheme.splashGradient(for: traitCollection)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupOrbs() {
        let orb1 = makeOrb(color: AppTheme.primary, size: 260, alpha: 0.09)
        let orb2 = makeOrb(color: AppTheme.secondary, size: 180, alpha: 0.07)
        view.addSubview(orb1)
        view.addSubview(orb2)
        NSLayoutConstraint.activate([
            orb1.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            orb1.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            orb2.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            orb2.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -140)
        ])
    }

    private func makeOrb(color: UIColor, size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: size).isActive = true
        v.heightAnchor.constraint(equalToConstant: size).isActive = true
        return v
    }

    // MARK: - Card
    private func setupCard() {
        // Card
        cardView.backgroundColor = AppTheme.cardBackground
        cardView.layer.cornerRadius = 28
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 28
        cardView.layer.shadowOffset = CGSize(width: 0, height: 12)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Top accent strip
        let accentStrip = UIView()
        accentStrip.backgroundColor = AppTheme.primary
        accentStrip.layer.cornerRadius = 3
        accentStrip.translatesAutoresizingMaskIntoConstraints = false

        // Icon circle
        iconCircle.backgroundColor = AppTheme.primary
        iconCircle.layer.cornerRadius = 30
        iconCircle.layer.shadowColor = AppTheme.primary.cgColor
        iconCircle.layer.shadowOpacity = 0.4
        iconCircle.layer.shadowRadius = 12
        iconCircle.layer.shadowOffset = .zero
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconImageView.image = UIImage(systemName: "person.fill", withConfiguration: cfg)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = "Welcome"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle
        subtitleLabel.text = "What should we call you?"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Field container (for focus ring effect)
        fieldContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.06)
        fieldContainer.layer.cornerRadius = 14
        fieldContainer.layer.borderWidth = 1.5
        fieldContainer.layer.borderColor = AppTheme.primary.withAlphaComponent(0.2).cgColor
        fieldContainer.translatesAutoresizingMaskIntoConstraints = false

        // TextField
        textField.placeholder = "Your name"
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .label
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(fieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(fieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(fieldDidEndEditing), for: .editingDidEnd)

        // Continue button
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        continueButton.backgroundColor = AppTheme.primary
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 16
        continueButton.layer.shadowColor = AppTheme.primary.cgColor
        continueButton.layer.shadowOpacity = 0.35
        continueButton.layer.shadowRadius = 10
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        continueButton.alpha = 0.5
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        // Assemble
        fieldContainer.addSubview(textField)
        cardView.addSubview(accentStrip)
        cardView.addSubview(iconCircle)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(fieldContainer)
        cardView.addSubview(continueButton)
        view.addSubview(cardView)

        cardCenterYConstraint = cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardCenterYConstraint,
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),

            accentStrip.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            accentStrip.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            accentStrip.widthAnchor.constraint(equalToConstant: 36),
            accentStrip.heightAnchor.constraint(equalToConstant: 4),

            iconCircle.topAnchor.constraint(equalTo: accentStrip.bottomAnchor, constant: 20),
            iconCircle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 60),
            iconCircle.heightAnchor.constraint(equalToConstant: 60),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),

            titleLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            fieldContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            fieldContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            fieldContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            fieldContainer.heightAnchor.constraint(equalToConstant: 52),

            textField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: fieldContainer.centerYAnchor),

            continueButton.topAnchor.constraint(equalTo: fieldContainer.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 52),
            continueButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28)
        ])
    }

    // MARK: - Entrance animation
    private func animateIn() {
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(translationX: 0, y: 40)
        UIView.animate(withDuration: 0.6, delay: 0.15, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    // MARK: - Field focus ring
    @objc private func fieldDidBeginEditing() {
        UIView.animate(withDuration: 0.2) {
            self.fieldContainer.layer.borderColor = AppTheme.primary.cgColor
            self.fieldContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.08)
        }
    }

    @objc private func fieldDidEndEditing() {
        UIView.animate(withDuration: 0.2) {
            self.fieldContainer.layer.borderColor = AppTheme.primary.withAlphaComponent(0.2).cgColor
            self.fieldContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.06)
        }
    }

    @objc private func fieldEditingChanged() {
        let valid = viewModel.isValid(name: textField.text)
        UIView.animate(withDuration: 0.2) {
            self.continueButton.alpha = valid ? 1.0 : 0.5
        }
    }

    // MARK: - Keyboard
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        cardCenterYConstraint.constant = -frame.height / 3
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        cardCenterYConstraint.constant = 0
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    // MARK: - Actions
    @objc private func continueTapped() {
        guard viewModel.isValid(name: textField.text) else {
            shakeField()
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.saveName(textField.text ?? "")
        onFinish?()
    }

    private func shakeField() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values = [-8, 8, -6, 6, -4, 4, 0]
        anim.duration = 0.35
        fieldContainer.layer.add(anim, forKey: "shake")
    }

    private func setupDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate
extension NameEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueTapped()
        return true
    }
}
