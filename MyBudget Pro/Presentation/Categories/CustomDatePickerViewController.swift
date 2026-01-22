//
//  CustomDatePickerViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 21/01/26.
//


import UIKit

final class CustomDatePickerViewController: UIViewController {

    var onApply: ((Date, Date) -> Void)?

    private let fromPicker = UIDatePicker()
    private let toPicker = UIDatePicker()
    private let applyButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPickers()
        setupButton()
    }

    private func setupPickers() {
        fromPicker.datePickerMode = .date
        toPicker.datePickerMode = .date

        fromPicker.translatesAutoresizingMaskIntoConstraints = false
        toPicker.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fromPicker)
        view.addSubview(toPicker)

        NSLayoutConstraint.activate([
            fromPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fromPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            toPicker.topAnchor.constraint(equalTo: fromPicker.bottomAnchor, constant: 20),
            toPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupButton() {
        applyButton.setTitle("Apply", for: .normal)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 12
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        view.addSubview(applyButton)

        NSLayoutConstraint.activate([
            applyButton.topAnchor.constraint(equalTo: toPicker.bottomAnchor, constant: 30),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func applyTapped() {
        onApply?(fromPicker.date, toPicker.date)
        dismiss(animated: true)
    }
}
