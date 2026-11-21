import UIKit

/// Offline, fixed-snippet keyboard. No network, Full Access, or clipboard required.
final class KeyboardViewController: UIInputViewController {
    private struct Snippet {
        let title: String
        let text: String
    }

    private let snippets: [Snippet] = [
        Snippet(title: "Hello", text: "Hello from QuicKey!"),
        Snippet(title: "Search", text: "warehouse automation"),
        Snippet(title: "Translate", text: "Translate the following into English: "),
        Snippet(title: "Review", text: "Please review and improve this text: "),
        Snippet(title: "Summarize", text: "Summarize this in three bullet points: "),
        Snippet(title: "Sign-off", text: "Best regards,\n")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        buildKeyboard()
    }

    private func buildKeyboard() {
        view.backgroundColor = .secondarySystemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let toolbar = UIStackView()
        toolbar.axis = .horizontal
        toolbar.alignment = .center
        toolbar.spacing = 10

        let globe = makeButton("🌐 Next", accessibilityID: "quickey-next-keyboard")
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        toolbar.addArrangedSubview(globe)
        globe.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let label = UILabel()
        label.text = "QuicKey 0.1"
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        toolbar.addArrangedSubview(label)

        let backspace = makeButton("⌫ Delete", accessibilityID: "quickey-delete")
        backspace.addTarget(self, action: #selector(deleteCharacter), for: .touchUpInside)
        toolbar.addArrangedSubview(backspace)
        backspace.widthAnchor.constraint(equalToConstant: 110).isActive = true

        stack.addArrangedSubview(toolbar)
        toolbar.heightAnchor.constraint(equalToConstant: 48).isActive = true

        for row in 0..<3 {
            let buttonRow = UIStackView()
            buttonRow.axis = .horizontal
            buttonRow.distribution = .fillEqually
            buttonRow.spacing = 8
            for column in 0..<2 {
                let index = row * 2 + column
                let button = makeButton(snippets[index].title, accessibilityID: "quickey-snippet-\(index)")
                button.tag = index
                button.addTarget(self, action: #selector(insertSnippet(_:)), for: .touchUpInside)
                buttonRow.addArrangedSubview(button)
            }
            stack.addArrangedSubview(buttonRow)
            buttonRow.heightAnchor.constraint(equalToConstant: 53).isActive = true
        }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8)
        ])

        let height = view.heightAnchor.constraint(equalToConstant: 245)
        height.priority = .defaultHigh
        height.isActive = true
    }

    private func makeButton(_ title: String, accessibilityID: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 10
        button.accessibilityIdentifier = accessibilityID
        return button
    }

    @objc private func insertSnippet(_ sender: UIButton) {
        guard snippets.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(snippets[sender.tag].text)
    }

    @objc private func deleteCharacter() {
        textDocumentProxy.deleteBackward()
    }
}
