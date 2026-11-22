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
        subtitle.text = "QuicKey 0.2.3 is an offline FAIREX command composer. It inserts text into other apps; it does not submit or execute commands."
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        content.addArrangedSubview(subtitle)

        let steps = UILabel()
        steps.numberOfLines = 0
        steps.font = .preferredFont(forTextStyle: .body)
        steps.text = "1. Settings > General > Keyboard > Keyboards > QuicKey.\n2. Leave Allow Full Access OFF.\n3. Select QuicKey using the globe key in a normal text field.\n4. Start: select a role and insert the complete new-chat setup in one tap.\n5. Handle: select PR/Issue, type the number, + Add for extra targets, and Insert.\n6. Quick: common command prefixes.\n7. Recent: reuse generated prompts without relying on the clipboard.\n8. More: single-role entry and additional commands."
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
        note.text = "Example: Start > CM1 > Start new chat. Or Handle > PR #160 > + Add > Issue #159 > + Add > Issue #6 > Insert. Templates are read-only text; sending the message is always your choice."
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
