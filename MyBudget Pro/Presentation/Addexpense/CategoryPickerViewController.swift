//
//  CategoryPickerViewController.swift
//  MyBudget Pro
//

import UIKit

final class CategoryPickerViewController: UIViewController,
                                          UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {

    var onSelect: ((CategoryType) -> Void)?

    private let categories = CategoryType.allCases
    private var collectionView: UICollectionView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        setupSheet()
        setupHeader()
        setupCollectionView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        view.backgroundColor = AppTheme.background
        collectionView.reloadData()
    }

    // MARK: - Sheet
    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }

    // MARK: - Header
    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text = "Select Category"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose what this expense is for"
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Collection View
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 76),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.configure(with: categories[indexPath.item])
        return cell
    }

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16 + 16 + 12
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 110)
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let category = categories[indexPath.item]
        // Dismiss first, then notify — caller handles presentation after dismiss
        dismiss(animated: true) { [weak self] in
            self?.onSelect?(category)
        }
    }
}

// MARK: - CategoryCell
private final class CategoryCell: UICollectionViewCell {

    private let colorBar   = UIView()
    private let iconCircle = UIView()
    private let iconImage  = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentView.backgroundColor = AppTheme.cardBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.clipsToBounds = false

        // Left color accent bar (clipped to card corners)
        let innerClip = UIView()
        innerClip.layer.cornerRadius = 18
        innerClip.clipsToBounds = true
        innerClip.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(innerClip)
        colorBar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(colorBar)

        // Colored circle background for icon
        iconCircle.layer.cornerRadius = 24
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconCircle)

        // SF Symbol icon
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconImage.preferredSymbolConfiguration = config
        iconImage.contentMode = .scaleAspectFit
        iconImage.tintColor = .white
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconImage)

        // Title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            innerClip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 5),

            colorBar.leadingAnchor.constraint(equalTo: innerClip.leadingAnchor),
            colorBar.topAnchor.constraint(equalTo: innerClip.topAnchor),
            colorBar.bottomAnchor.constraint(equalTo: innerClip.bottomAnchor),
            colorBar.trailingAnchor.constraint(equalTo: innerClip.trailingAnchor),

            iconCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconCircle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconCircle.widthAnchor.constraint(equalToConstant: 48),
            iconCircle.heightAnchor.constraint(equalToConstant: 48),

            iconImage.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 24),
            iconImage.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with category: CategoryType) {
        titleLabel.text = category.title
        colorBar.backgroundColor = category.color
        contentView.backgroundColor = AppTheme.cardBackground
        iconCircle.backgroundColor = category.color
        iconImage.image = UIImage(systemName: category.sfSymbol)
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.contentView.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
                self.contentView.alpha = self.isHighlighted ? 0.75 : 1.0
            }
        }
    }
}
