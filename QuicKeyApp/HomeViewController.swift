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
        header.text = "FAIREX command keyboard"
        header.font = .preferredFont(forTextStyle: .title2)
        header.numberOfLines = 0
        content.addArrangedSubview(header)

        let subtitle = UILabel()
        subtitle.text = "QuicKey v0.2 inserts commands into text fields. It never executes them. The keyboard runs offline without Full Access."
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        content.addArrangedSubview(subtitle)

        let steps = UILabel()
        steps.numberOfLines = 0
        steps.font = .preferredFont(forTextStyle: .body)
        steps.text = "1. Settings > General > Keyboard > Keyboards > QuicKey.\n2. Leave Allow Full Access OFF.\n3. Focus the field below and select QuicKey using the globe key.\n4. Quick: insert FAST+DEEP and other ready prefixes.\n5. Roles: insert role entry.\n6. Build: select role, PR/Issue, style, enter digits, then Insert.\n7. Controls: insert verified helper commands."
        content.addArrangedSubview(steps)

        let label = UILabel()
        label.text = "Try a command here"
        label.font = .preferredFont(forTextStyle: .headline)
        content.addArrangedSubview(label)

        let input = UITextView()
        input.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        input.isScrollEnabled = false
        input.backgroundColor = .secondarySystemBackground
        input.layer.cornerRadius = 12
        input.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        input.accessibilityIdentifier = "quickey-test-text-input"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        content.addArrangedSubview(input)

        let note = UILabel()
        note.text = "Example: Build > ENG > PR > Fast+Deep > 160 > Insert. The resulting text can be copied into a FAIREX chat and submitted manually. No commands are run automatically."
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
