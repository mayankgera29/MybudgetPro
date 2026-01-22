//
//  PieChartView.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//
import UIKit

final class PieChartView: UIView {

    struct Slice {
        let value: Double
        let color: UIColor
    }

    private var slices: [Slice] = []
    private var sliceLayers: [CAShapeLayer] = []
    private var hasDrawn = false

    // MARK: - Public
    func configure(with slices: [Slice]) {
        self.slices = slices
        hasDrawn = false
        setNeedsLayout()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        guard !hasDrawn, bounds.width > 0 else { return }
        hasDrawn = true

        drawChart()
        apply3DEffect()
        animateCircularDraw()
    }

    // MARK: - Draw Chart
    private func drawChart() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        sliceLayers.removeAll()

        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let size = min(bounds.width, bounds.height)
        let outerRadius = size * 0.40      // 🔥 smaller, prevents overlap
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        var startAngle = -CGFloat.pi / 2

        for slice in slices {
            let endAngle = startAngle + CGFloat(slice.value / total) * 2 * .pi

            let path = UIBezierPath(
                arcCenter: center,
                radius: outerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            let shape = CAShapeLayer()
            shape.path = path.cgPath
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeColor = slice.color.cgColor
            shape.lineWidth = outerRadius
            shape.strokeEnd = 0
            shape.lineCap = .butt

            // Subtle shadow for depth
            shape.shadowColor = UIColor.black.cgColor
            shape.shadowOpacity = 0.18
            shape.shadowRadius = 4
            shape.shadowOffset = CGSize(width: 0, height: 2)

            layer.addSublayer(shape)
            sliceLayers.append(shape)

            startAngle = endAngle
        }
    }

    // MARK: - Circular Animation
    private func animateCircularDraw() {
        for (index, layer) in sliceLayers.enumerated() {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.6
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.05
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            layer.add(animation, forKey: "draw")
        }
    }

    // MARK: - Subtle 3D Effect
    private func apply3DEffect() {
        var t = CATransform3DIdentity
        t.m34 = -1.0 / 900
        t = CATransform3DRotate(t, .pi / 16, 1, 0, 0)
        layer.transform = t
    }
}
