import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    // MARK: - Properties
    private var webView: WKWebView!
    private var setupView: SetupView!
    private let defaults = UserDefaults.standard
    private var reconnectTimer: Timer?

    private var serverURL: String {
        get { defaults.string(forKey: "server_url") ?? "" }
        set { defaults.set(newValue, forKey: "server_url") }
    }
    private var screenCode: String {
        get { defaults.string(forKey: "screen_code") ?? "" }
        set { defaults.set(newValue, forKey: "screen_code") }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        if serverURL.isEmpty || screenCode.isEmpty {
            showSetup()
        } else {
            loadPlayer()
        }
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    // MARK: - Setup Screen
    private func showSetup() {
        setupView = SetupView()
        setupView.frame = view.bounds
        setupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupView.onConnect = { [weak self] url, code in
            self?.serverURL = url
            self?.screenCode = code
            self?.setupView.removeFromSuperview()
            self?.loadPlayer()
        }
        view.addSubview(setupView)
    }

    // MARK: - WebView Player
    private func loadPlayer() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Bridge: JS → Swift messages
        let controller = config.userContentController
        controller.add(self, name: "nativeBridge")

        // Inject native info into every page
        let script = WKUserScript(
            source: """
                window.SIGNAGE_NATIVE = {
                    platform: 'ios',
                    version:  '\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")',
                    screenCode: '\(screenCode)'
                };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        controller.addUserScript(script)

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        view.addSubview(webView)

        let playerURL = "\(serverURL)/player?code=\(screenCode)"
        if let url = URL(string: playerURL) {
            webView.load(URLRequest(url: url))
        } else {
            showSetup()
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        scheduleReconnect()
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.loadPlayer()
        }
    }

    // MARK: - JS → Swift Bridge
    func userContentController(_ userContentController: WKUserContentController,
                                didReceive message: WKScriptMessage) {
        guard message.name == "nativeBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }

        switch action {
        case "resetSetup":
            serverURL = ""
            screenCode = ""
            webView.removeFromSuperview()
            showSetup()
        case "reload":
            webView.reload()
        default:
            break
        }
    }
}

// MARK: - SetupView
class SetupView: UIView {

    var onConnect: ((String, String) -> Void)?

    private let titleLabel  = UILabel()
    private let urlField    = UITextField()
    private let codeField   = UITextField()
    private let connectBtn  = UIButton(type: .system)
    private let statusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        titleLabel.text = "SignageCMS"
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        let subtitle = UILabel()
        subtitle.text = "Digital Signage Player"
        subtitle.font = .systemFont(ofSize: 16)
        subtitle.textColor = UIColor(white: 0.6, alpha: 1)
        subtitle.textAlignment = .center

        urlField.placeholder = "Server URL (e.g. http://192.168.1.10)"
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no

        codeField.placeholder = "Screen activation code"
        codeField.keyboardType = .numberPad

        [urlField, codeField].forEach { f in
            f.backgroundColor = UIColor(white: 0.12, alpha: 1)
            f.textColor = .white
            f.tintColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
            f.layer.cornerRadius = 10
            f.layer.borderWidth = 1
            f.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
            f.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            f.leftViewMode = .always
        }

        connectBtn.setTitle("Connect to Server", for: .normal)
        connectBtn.backgroundColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
        connectBtn.setTitleColor(.white, for: .normal)
        connectBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        connectBtn.layer.cornerRadius = 12
        connectBtn.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)

        statusLabel.text = ""
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(red: 0.96, green: 0.34, blue: 0.44, alpha: 1)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitle, urlField, codeField, connectBtn, statusLabel])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        [urlField, codeField, connectBtn].forEach { $0.heightAnchor.constraint(equalToConstant: 50).isActive = true }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: 360),
        ])
    }

    @objc private func connectTapped() {
        let url  = urlField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let code = codeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !url.isEmpty, URL(string: url) != nil else {
            statusLabel.text = "Invalid server URL"; return
        }
        guard !code.isEmpty else {
            statusLabel.text = "Enter activation code"; return
        }
        statusLabel.text = ""
        onConnect?(url, code)
    }
}
