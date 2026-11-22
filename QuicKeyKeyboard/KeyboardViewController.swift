import UIKit

/// Offline FAIREX command keyboard. No network or Full Access is required.
/// Every control inserts text only; it never submits, executes, or grants authority.
final class KeyboardViewController: UIInputViewController {
    private enum Page: Int {
        case quick = 0, roles, compose, controls
        var title: String {
            switch self {
            case .quick: return "Quick"
            case .roles: return "Roles"
            case .compose: return "Build"
            case .controls: return "Controls"
            }
        }
    }

    private struct Shortcut {
        let title: String
        let value: String
    }

    private let quick: [Shortcut] = [
        Shortcut(title: "FAST+DEEP", value: CommandTemplates.fastDeepPrefix),
        Shortcut(title: "Deep task", value: "cmd.deep:\n"),
        Shortcut(title: "Batch ON", value: CommandTemplates.batchOn),
        Shortcut(title: "Handle PR", value: "git.handle PR #"),
        Shortcut(title: "Handle Issue", value: "git.handle Issue #"),
        Shortcut(title: "Refresh", value: "cmd.refresh system")
    ]

    private let controls: [Shortcut] = [
        Shortcut(title: "Help", value: "cmd.help"),
        Shortcut(title: "System", value: "cmd.refresh system"),
        Shortcut(title: "Role status", value: "cmd.refresh role"),
        Shortcut(title: "Nonstop ON", value: "cmd.nonstop ON"),
        Shortcut(title: "All-in-one ON", value: "all.in.one ON"),
        Shortcut(title: "Split task", value: "cmd.split: ")
    ]

    private let stack = UIStackView()
    private var keyboardHeight: NSLayoutConstraint?
    private var currentPage: Page = .quick
    private var selectedRole: CommandRole = .custodian
    private var selectedKind: HandleKind = .pr
    private var selectedStyle: HandleStyle = .fastDeep
    private var issueNumber = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 7),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -7),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -6)
        ])
        let height = view.heightAnchor.constraint(equalToConstant: 277)
        height.priority = .defaultHigh
        height.isActive = true
        keyboardHeight = height
        render()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
        view.backgroundColor = .secondarySystemBackground
    }

    private func button(_ text: String, id: String, selected: Bool = false,
                        fontSize: CGFloat = 15) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: selected ? .semibold : .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.75
        button.backgroundColor = selected ? .systemIndigo.withAlphaComponent(0.24) : .tertiarySystemBackground
        button.layer.cornerRadius = 9
        button.accessibilityIdentifier = id
        return button
    }

    private func label(_ text: String, fontSize: CGFloat = 12) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func row(_ views: [UIView], height: CGFloat, spacing: CGFloat = 5) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.spacing = spacing
        row.distribution = .fillEqually
        row.heightAnchor.constraint(equalToConstant: height).isActive = true
        return row
    }

    private func render() {
        for arranged in stack.arrangedSubviews {
            stack.removeArrangedSubview(arranged)
            arranged.removeFromSuperview()
        }

        let switchKey = button("🌐 Next", id: "quickey-next-keyboard", fontSize: 15)
        // Required Apple API for showing the standard input-mode switch list.
        switchKey.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        let title = label("QuicKey 0.2 • FAIREX", fontSize: 12)
        title.textAlignment = .center

        let backspace = button("⌫ Delete", id: "quickey-delete")
        backspace.addTarget(self, action: #selector(deleteCharacter), for: .touchUpInside)

        let toolbar = UIStackView(arrangedSubviews: [switchKey, title, backspace])
        toolbar.axis = .horizontal
        toolbar.alignment = .fill
        toolbar.spacing = 6
        toolbar.distribution = .fill
        switchKey.widthAnchor.constraint(equalToConstant: 103).isActive = true
        backspace.widthAnchor.constraint(equalToConstant: 103).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 37).isActive = true
        stack.addArrangedSubview(toolbar)

        var pages: [UIButton] = []
        for page in [Page.quick, .roles, .compose, .controls] {
            let tab = button(page.title, id: "quickey-tab-\(page.rawValue)",
                             selected: currentPage == page, fontSize: 13)
            tab.tag = page.rawValue
            tab.addTarget(self, action: #selector(changePage(_:)), for: .touchUpInside)
            pages.append(tab)
        }
        stack.addArrangedSubview(row(pages, height: 31))

        switch currentPage {
        case .quick:
            addShortcuts(quick, action: #selector(insertQuick(_:)), idPrefix: "quick")
            stack.addArrangedSubview(label("FAST+DEEP inserts a prefix. Finish its git.handle target before submitting."))
        case .roles:
            addRoles()
        case .compose:
            addComposer()
        case .controls:
            addShortcuts(controls, action: #selector(insertControl(_:)), idPrefix: "control")
            stack.addArrangedSubview(label("Buttons insert text, never run commands or approve effects."))
        }
        keyboardHeight?.constant = (currentPage == .compose) ? 455 : 277
    }

    private func addShortcuts(_ items: [Shortcut], action: Selector, idPrefix: String) {
        for rowIndex in 0..<3 {
            let firstIndex = 2 * rowIndex
            let keys = (0..<2).map { column -> UIButton in
                let index = firstIndex + column
                let value = items[index]
                let key = button(value.title, id: "quickey-\(idPrefix)-\(index)")
                key.tag = index
                key.addTarget(self, action: action, for: .touchUpInside)
                return key
            }
            stack.addArrangedSubview(row(keys, height: 50))
        }
    }

    private func addRoles() {
        stack.addArrangedSubview(label("Insert an exact FAIREX role entry."))
        let roles = CommandRole.allCases
        for index in stride(from: 0, to: roles.count, by: 2) {
            let first = roles[index]
            let firstButton = button(first.command, id: "quickey-role-\(index)", fontSize: 14)
            firstButton.tag = index
            firstButton.addTarget(self, action: #selector(insertRole(_:)), for: .touchUpInside)
            if index + 1 < roles.count {
                let second = roles[index + 1]
                let secondButton = button(second.command, id: "quickey-role-\(index+1)", fontSize: 14)
                secondButton.tag = index + 1
                secondButton.addTarget(self, action: #selector(insertRole(_:)), for: .touchUpInside)
                stack.addArrangedSubview(row([firstButton, secondButton], height: 47))
            } else {
                stack.addArrangedSubview(row([firstButton], height: 47))
            }
        }
    }

    private func addComposer() {
        let roles = CommandRole.allCases
        let roleButtons = roles.enumerated().map { index, role -> UIButton in
            let key = button(role.label, id: "quickey-build-role-\(role.rawValue)",
                             selected: role == selectedRole, fontSize: 12)
            key.tag = index
            key.addTarget(self, action: #selector(selectRole(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(roleButtons, height: 30, spacing: 3))

        let targetButtons = HandleKind.allCases.enumerated().map { index, kind -> UIButton in
            let key = button(kind.command, id: "quickey-kind-\(kind.rawValue)",
                             selected: kind == selectedKind, fontSize: 13)
            key.tag = index
            key.addTarget(self, action: #selector(selectKind(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(targetButtons, height: 30))

        let styleButtons = HandleStyle.allCases.enumerated().map { index, style -> UIButton in
            let key = button(style.label, id: "quickey-style-\(style.rawValue)",
                             selected: style == selectedStyle, fontSize: 12)
            key.tag = index
            key.addTarget(self, action: #selector(selectStyle(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(styleButtons, height: 30))

        let numberLabel = label("\(selectedKind.command) #\(issueNumber.isEmpty ? "…" : issueNumber)")
        numberLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)

        let removeNumber = button("⌫", id: "quickey-number-delete")
        removeNumber.addTarget(self, action: #selector(deleteNumber), for: .touchUpInside)
        let clearNumber = button("Clear", id: "quickey-number-clear", fontSize: 12)
        clearNumber.addTarget(self, action: #selector(clearNumber), for: .touchUpInside)

        let numberRow = UIStackView(arrangedSubviews: [numberLabel, removeNumber, clearNumber])
        numberRow.axis = .horizontal
        numberRow.spacing = 5
        numberRow.distribution = .fill
        removeNumber.widthAnchor.constraint(equalToConstant: 50).isActive = true
        clearNumber.widthAnchor.constraint(equalToConstant: 63).isActive = true
        numberRow.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stack.addArrangedSubview(numberRow)

        for digits in [[1,2,3,4,5], [6,7,8,9,0]] {
            let digitKeys = digits.map { digit -> UIButton in
                let key = button(String(digit), id: "quickey-digit-\(digit)", fontSize: 17)
                key.tag = digit
                key.addTarget(self, action: #selector(appendNumber(_:)), for: .touchUpInside)
                return key
            }
            stack.addArrangedSubview(row(digitKeys, height: 38, spacing: 4))
        }

        let previewText = CommandTemplates.compose(role: selectedRole, kind: selectedKind,
                                                    number: issueNumber, style: selectedStyle)
            ?? "\(selectedRole.command)\n\nSelect a valid positive \(selectedKind.command) number"
        let preview = label(previewText, fontSize: 12)
        preview.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        preview.textColor = .label
        preview.backgroundColor = .tertiarySystemBackground
        preview.layer.cornerRadius = 7
        preview.layer.masksToBounds = true
        preview.numberOfLines = 7
        preview.heightAnchor.constraint(equalToConstant: 80).isActive = true
        preview.accessibilityIdentifier = "quickey-command-preview"
        stack.addArrangedSubview(preview)

        let insert = button("Insert composed command", id: "quickey-insert-compose", selected: true)
        insert.isEnabled = CommandTemplates.compose(role: selectedRole, kind: selectedKind,
                                                     number: issueNumber, style: selectedStyle) != nil
        insert.addTarget(self, action: #selector(insertComposed), for: .touchUpInside)
        insert.heightAnchor.constraint(equalToConstant: 42).isActive = true
        stack.addArrangedSubview(insert)
    }

    @objc private func changePage(_ sender: UIButton) {
        guard let page = Page(rawValue: sender.tag) else { return }
        currentPage = page
        render()
    }

    @objc private func insertQuick(_ sender: UIButton) {
        guard quick.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(quick[sender.tag].value)
    }

    @objc private func insertControl(_ sender: UIButton) {
        guard controls.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(controls[sender.tag].value)
    }

    @objc private func insertRole(_ sender: UIButton) {
        let roles = CommandRole.allCases
        guard roles.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(roles[sender.tag].command)
    }

    @objc private func selectRole(_ sender: UIButton) {
        let roles = CommandRole.allCases
        guard roles.indices.contains(sender.tag) else { return }
        selectedRole = roles[sender.tag]
        render()
    }

    @objc private func selectKind(_ sender: UIButton) {
        let kinds = HandleKind.allCases
        guard kinds.indices.contains(sender.tag) else { return }
        selectedKind = kinds[sender.tag]
        render()
    }

    @objc private func selectStyle(_ sender: UIButton) {
        let styles = HandleStyle.allCases
        guard styles.indices.contains(sender.tag) else { return }
        selectedStyle = styles[sender.tag]
        render()
    }

    @objc private func appendNumber(_ sender: UIButton) {
        guard (0...9).contains(sender.tag), issueNumber.count < 8 else { return }
        if issueNumber.isEmpty && sender.tag == 0 { return }
        issueNumber += String(sender.tag)
        render()
    }

    @objc private func deleteNumber() {
        if !issueNumber.isEmpty { issueNumber.removeLast() }
        render()
    }

    @objc private func clearNumber() {
        issueNumber = ""
        render()
    }

    @objc private func insertComposed() {
        guard let text = CommandTemplates.compose(role: selectedRole, kind: selectedKind,
                                                  number: issueNumber, style: selectedStyle) else { return }
        textDocumentProxy.insertText(text)
    }

    @objc private func deleteCharacter() {
        textDocumentProxy.deleteBackward()
    }
}
