import Capacitor
import UIKit
import WebKit

final class MainViewController: CAPBridgeViewController {
    private let launchFallbackView = LaunchFallbackView()
    private var estimatedProgressObserver: NSKeyValueObservation?
    private var isLaunchFallbackHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        installLaunchFallbackView()
        observeInitialWebViewLoad()
    }

    deinit {
        estimatedProgressObserver?.invalidate()
    }

    private func installLaunchFallbackView() {
        launchFallbackView.translatesAutoresizingMaskIntoConstraints = false
        launchFallbackView.onRetry = { [weak self] in
            self?.launchFallbackView.prepareForRetry()
            self?.loadWebView()
        }

        view.addSubview(launchFallbackView)
        NSLayoutConstraint.activate([
            launchFallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            launchFallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            launchFallbackView.topAnchor.constraint(equalTo: view.topAnchor),
            launchFallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self, !self.isLaunchFallbackHidden else { return }
            self.launchFallbackView.showRetryState()
        }
    }

    private func observeInitialWebViewLoad() {
        guard let webView else { return }

        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] observedWebView, _ in
            guard let self else { return }
            let hasLoadedInitialUrl = observedWebView.url != nil
            let hasMeaningfulProgress = observedWebView.estimatedProgress >= 0.6
            let finishedLoading = hasLoadedInitialUrl && !observedWebView.isLoading

            if hasMeaningfulProgress || finishedLoading {
                self.hideLaunchFallbackView()
            }
        }
    }

    private func hideLaunchFallbackView() {
        guard !isLaunchFallbackHidden else { return }
        isLaunchFallbackHidden = true

        UIView.animate(withDuration: 0.25, animations: {
            self.launchFallbackView.alpha = 0
        }, completion: { _ in
            self.launchFallbackView.removeFromSuperview()
        })
    }
}

private final class LaunchFallbackView: UIView {
    var onRetry: (() -> Void)?

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    func showRetryState() {
        subtitleLabel.text = "Se a tela inicial nao carregar em alguns segundos, toque em tentar novamente."
        retryButton.isHidden = false
    }

    func prepareForRetry() {
        subtitleLabel.text = "Carregando atendimento..."
        retryButton.isHidden = true
    }

    @objc private func handleRetryTap() {
        onRetry?()
    }

    private func configureView() {
        backgroundColor = UIColor(red: 7 / 255, green: 25 / 255, blue: 27 / 255, alpha: 1)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "ICA Telemedicina Humana"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 228 / 255, green: 247 / 255, blue: 245 / 255, alpha: 1)
        titleLabel.numberOfLines = 0

        subtitleLabel.text = "Carregando atendimento..."
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor(red: 155 / 255, green: 194 / 255, blue: 191 / 255, alpha: 1)
        subtitleLabel.numberOfLines = 0

        retryButton.setTitle("Tentar novamente", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        retryButton.backgroundColor = UIColor(red: 30 / 255, green: 155 / 255, blue: 146 / 255, alpha: 1)
        retryButton.tintColor = .white
        retryButton.layer.cornerRadius = 22
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(handleRetryTap), for: .touchUpInside)

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(retryButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
