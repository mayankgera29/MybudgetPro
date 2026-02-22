import UIKit
import Lottie

extension UIView {

    func addBackgroundLottie(named name: String) {

        let animationView = LottieAnimationView(
            animation: LottieAnimation.named(name)
        )

        animationView.frame = bounds
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.alpha = 0.12   // 🔥 VERY IMPORTANT
        animationView.translatesAutoresizingMaskIntoConstraints = false

        insertSubview(animationView, at: 0)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        animationView.play()
    }
}

