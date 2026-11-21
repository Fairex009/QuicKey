import UIKit

final class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "QuicKey"
        view.backgroundColor = .systemBackground

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let header = UILabel()
        header.text = "Your six-button command keyboard"
        header.font = .preferredFont(forTextStyle: .title2)
        header.numberOfLines = 0
        content.addArrangedSubview(header)

        let subtitle = UILabel()
        subtitle.text = "Version 0.1 is an offline proof of concept. Snippets are fixed for now, and Full Access is not required."
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        content.addArrangedSubview(subtitle)

        let steps = UILabel()
        steps.numberOfLines = 0
        steps.font = .preferredFont(forTextStyle: .body)
        steps.text = "1. Open Settings > General > Keyboard > Keyboards.\n2. Tap Add New Keyboard and choose QuicKey.\n3. Leave Allow Full Access disabled.\n4. Tap the test field below and switch keyboards using the globe key.\n5. Tap a QuicKey button to insert its saved text."
        content.addArrangedSubview(steps)

        let label = UILabel()
        label.text = "Test text field"
        label.font = .preferredFont(forTextStyle: .headline)
        content.addArrangedSubview(label)

        let input = UITextView()
        input.font = .preferredFont(forTextStyle: .body)
        input.isScrollEnabled = false
        input.backgroundColor = .secondarySystemBackground
        input.layer.cornerRadius = 12
        input.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        input.accessibilityIdentifier = "quickey-test-text-input"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        content.addArrangedSubview(input)

        let note = UILabel()
        note.text = "Next test: open Safari > google.com, select the search box, switch to QuicKey, then tap Search."
        note.numberOfLines = 0
        note.textColor = .secondaryLabel
        note.font = .preferredFont(forTextStyle: .footnote)
        content.addArrangedSubview(note)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }
}
