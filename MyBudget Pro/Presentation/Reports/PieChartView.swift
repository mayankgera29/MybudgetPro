//
//  PieChartView.swift
//  MyBudget Pro
//

import UIKit

final class PieChartView: UIView {

    struct Slice {
        let value: Double
        let color: UIColor
    }

    // MARK: - State
    private var slices: [Slice] = []

    // Center label — added once, always present
    private let holeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(holeLabel)
        NSLayoutConstraint.activate([
            holeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            holeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            holeLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.4)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public API
    func configure(with slices: [Slice]) {
        self.slices = slices
        holeLabel.text = slices.isEmpty ? "" : "\(slices.count)\ncategories"
        // Remove only shape layers, not subviews
        layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        // Trigger redraw — safe because draw(_:) doesn't touch the view hierarchy
        setNeedsDisplay()
        // Animate after a brief layout pass so bounds are valid
        DispatchQueue.main.async { [weak self] in
            self?.animateArcs()
        }
    }

    // MARK: - Drawing (no subview/constraint mutations here)
    override func draw(_ rect: CGRect) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        // Remove stale shape layers before redrawing
        layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }

        let total = slices.reduce(0) { $0 + $1.value }
        let radius = min(bounds.width, bounds.height) * 0.38
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        if total <= 0 {
            drawEmpty(center: center, radius: radius)
            return
        }

        var startAngle = -CGFloat.pi / 2
        for slice in slices {
            let fraction = CGFloat(slice.value / total)
            let endAngle = startAngle + fraction * 2 * .pi
            addArc(center: center, radius: radius,
                   start: startAngle, end: endAngle,
                   color: slice.color, animated: false)
            startAngle = endAngle
        }
    }

    // MARK: - Animation (called after layout, safe to add layers)
    private func animateArcs() {
        guard bounds.width > 0 else { return }
        layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }

        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let radius = min(bounds.width, bounds.height) * 0.38
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        var startAngle = -CGFloat.pi / 2
        var delay: Double = 0

        for slice in slices {
            let fraction = CGFloat(slice.value / total)
            let endAngle = startAngle + fraction * 2 * .pi
            addArc(center: center, radius: radius,
                   start: startAngle, end: endAngle,
                   color: slice.color, animated: true, delay: delay)
            delay += 0.04
            startAngle = endAngle
        }
    }

    // MARK: - Helpers
    private func addArc(center: CGPoint, radius: CGFloat,
                        start: CGFloat, end: CGFloat,
                        color: UIColor, animated: Bool, delay: Double = 0) {
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: start, endAngle: end, clockwise: true)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = color.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = radius * 0.55
        shape.strokeEnd = animated ? 0 : 1
        layer.insertSublayer(shape, below: holeLabel.layer)

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 0.5
            anim.beginTime = CACurrentMediaTime() + delay
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = false
            shape.add(anim, forKey: "draw")
        }
    }

    private func drawEmpty(center: CGPoint, radius: CGFloat) {
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.systemGray5.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = radius * 0.55
        layer.insertSublayer(shape, below: holeLabel.layer)
    }
}
