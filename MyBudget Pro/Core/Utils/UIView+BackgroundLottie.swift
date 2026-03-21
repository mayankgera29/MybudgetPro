import UIKit

extension UIView {

    /// Adds a classy animated orb background — subtle floating gradient circles.
    func addBackgroundLottie(named name: String) {
        addClassyOrbBackground()
    }

    func addClassyOrbBackground() {
        // Remove any existing orb layer
        subviews.filter { $0.accessibilityIdentifier == "OrbBackground" }.forEach { $0.removeFromSuperview() }

        let container = UIView()
        container.accessibilityIdentifier = "OrbBackground"
        container.isUserInteractionEnabled = false
        container.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(container, at: 0)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Define orbs: (color, size, startX, startY)
        let orbs: [(UIColor, CGFloat, CGFloat, CGFloat)] = [
            (UIColor(red: 99/255,  green: 102/255, blue: 241/255, alpha: 1), 280, 0.15, 0.10),  // indigo top-left
            (UIColor(red: 139/255, green: 92/255,  blue: 246/255, alpha: 1), 220, 0.80, 0.25),  // violet top-right
            (UIColor(red: 99/255,  green: 102/255, blue: 241/255, alpha: 1), 200, 0.60, 0.70),  // indigo bottom-mid
            (UIColor(red: 167/255, green: 139/255, blue: 250/255, alpha: 1), 160, 0.10, 0.80),  // lavender bottom-left
        ]

        for (index, orb) in orbs.enumerated() {
            let (color, size, relX, relY) = orb
            let orbView = makeOrb(color: color, size: size)
            container.addSubview(orbView)

            orbView.translatesAutoresizingMaskIntoConstraints = false

            // Width/height fixed, but centerX/Y are proportional to container
            // so they reposition correctly on every rotation
            let cx = NSLayoutConstraint(item: orbView, attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: container, attribute: .trailing,
                                        multiplier: relX, constant: 0)
            let cy = NSLayoutConstraint(item: orbView, attribute: .centerY,
                                        relatedBy: .equal,
                                        toItem: container, attribute: .bottom,
                                        multiplier: relY, constant: 0)
            NSLayoutConstraint.activate([
                orbView.widthAnchor.constraint(equalToConstant: size),
                orbView.heightAnchor.constraint(equalToConstant: size),
                cx, cy
            ])

            animateOrb(orbView, delay: Double(index) * 0.8)
        }
    }

    private func makeOrb(color: UIColor, size: CGFloat) -> UIView {
        let orb = UIView()
        orb.layer.cornerRadius = size / 2
        orb.isUserInteractionEnabled = false
        orb.isOpaque = false
        orb.backgroundColor = .clear

        let gradient = CARadialGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        gradient.cornerRadius = size / 2
        gradient.masksToBounds = true
        gradient.colors = [
            color.withAlphaComponent(0.30).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ]
        orb.layer.addSublayer(gradient)
        return orb
    }

    private func animateOrb(_ orb: UIView, delay: Double) {
        let dx = CGFloat.random(in: -30...30)
        let dy = CGFloat.random(in: -40...40)
        let duration = Double.random(in: 5.0...8.0)

        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: {
                orb.transform = CGAffineTransform(translationX: dx, y: dy)
            }
        )
    }
}

// MARK: - CARadialGradientLayer
private final class CARadialGradientLayer: CALayer {
    var colors: [CGColor] = [] {
        didSet { setNeedsDisplay() }
    }

    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
        setNeedsDisplay()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(in ctx: CGContext) {
        guard colors.count >= 2 else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: colors as CFArray,
                                        locations: locations) else { return }
        ctx.drawRadialGradient(gradient,
                               startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: radius,
                               options: [])
    }
}
