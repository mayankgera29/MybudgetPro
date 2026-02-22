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

    func configure(with slices: [Slice]) {
        self.slices = slices
        layer.sublayers?.removeAll()
        sliceLayers.removeAll()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawChart()
        animate()
    }

    private func drawChart() {

        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let radius = min(bounds.width, bounds.height) * 0.35
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        var startAngle = -CGFloat.pi / 2

        for slice in slices {
            let endAngle = startAngle + CGFloat(slice.value / total) * 2 * .pi

            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.strokeColor = slice.color.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = radius
            layer.strokeEnd = 0

            self.layer.addSublayer(layer)
            sliceLayers.append(layer)

            startAngle = endAngle
        }
    }

    private func animate() {
        for (i, layer) in sliceLayers.enumerated() {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 0.6
            anim.beginTime = CACurrentMediaTime() + Double(i) * 0.05
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = false
            layer.add(anim, forKey: "draw")
        }
    }
}
