import UIKit

/// Offline FAIREX text keyboard. Full Access, network access and App Groups are not required.
/// UI is kept deliberately small: Start, Handle, Quick, More.
final class KeyboardViewController: UIInputViewController {
    private enum Page: Int {
        case start, handle, quick, more
        var title: String {
            switch self {
            case .start: return "Start"
            case .handle: return "Handle"
            case .quick: return "Quick"
            case .more: return "More"
            }
        }
    }

    private struct Shortcut {
        let title: String
        let text: String
    }

    private let shortcuts = [
        Shortcut(title: "FAST+DEEP", text: CommandTemplates.fastDeepPrefix),
        Shortcut(title: "Deep task", text: "cmd.deep:\n"),
        Shortcut(title: "Batch ON", text: CommandTemplates.batchOn),
        Shortcut(title: "Handle PR", text: "git.handle PR #"),
        Shortcut(title: "Handle Issue", text: "git.handle Issue #"),
        Shortcut(title: "Refresh", text: "cmd.refresh system")
    ]
    private let controls = [
        Shortcut(title: "Help", text: "cmd.help"),
        Shortcut(title: "System", text: "cmd.refresh system"),
        Shortcut(title: "Role status", text: "cmd.refresh role"),
        Shortcut(title: "Nonstop ON", text: "cmd.nonstop ON"),
        Shortcut(title: "All-in-one ON", text: "all.in.one ON"),
        Shortcut(title: "Split task", text: "cmd.split: ")
    ]

    private let stack = UIStackView()
    private var heightConstraint: NSLayoutConstraint?
    private var page: Page = .start
    private var selectedRole: CommandRole = .custodian
    private var selectedKind: HandleKind = .pr
    private var selectedStyle: HandleStyle = .fastDeep
    private var includeRole = true
    private var committedTargets: [HandleTarget] = []
    private var digits = ""
    private weak var numberLabel: UILabel?
    private weak var previewLabel: UILabel?
    private weak var insertButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let saved = UserDefaults.standard.string(forKey: "QuicKeyLastRole"),
           let role = CommandRole(rawValue: saved) {
            selectedRole = role
        }
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
        let height = view.heightAnchor.constraint(equalToConstant: 294)
        height.priority = .defaultHigh
        height.isActive = true
        heightConstraint = height
        render()
    }

    private func button(_ text: String, id: String, selected: Bool = false,
                        fontSize: CGFloat = 14) -> UIButton {
        let key = UIButton(type: .system)
        key.setTitle(text, for: .normal)
        key.titleLabel?.font = .systemFont(ofSize: fontSize,
                                          weight: selected ? .semibold : .medium)
        key.titleLabel?.adjustsFontSizeToFitWidth = true
        key.titleLabel?.minimumScaleFactor = 0.73
        key.backgroundColor = selected ? UIColor.systemIndigo.withAlphaComponent(0.2)
                                       : .tertiarySystemBackground
        key.layer.cornerRadius = 8
        key.accessibilityIdentifier = id
        return key
    }

    private func label(_ text: String, size: CGFloat = 12) -> UILabel {
        let element = UILabel()
        element.text = text
        element.font = .systemFont(ofSize: size)
        element.textColor = .secondaryLabel
        element.numberOfLines = 0
        return element
    }

    private func row(_ views: [UIView], height: CGFloat, spacing: CGFloat = 4) -> UIStackView {
        let line = UIStackView(arrangedSubviews: views)
        line.axis = .horizontal
        line.spacing = spacing
        line.distribution = .fillEqually
        line.heightAnchor.constraint(equalToConstant: height).isActive = true
        return line
    }

    private func appendButton(_ title: String, id: String, action: Selector,
                              height: CGFloat = 40, selected: Bool = false) {
        let key = button(title, id: id, selected: selected)
        key.addTarget(self, action: action, for: .touchUpInside)
        key.heightAnchor.constraint(equalToConstant: height).isActive = true
        stack.addArrangedSubview(key)
    }

    private func render() {
        numberLabel = nil
        previewLabel = nil
        insertButton = nil
        for item in stack.arrangedSubviews {
            stack.removeArrangedSubview(item)
            item.removeFromSuperview()
        }

        let next = button("🌐 Next", id: "quickey-next", fontSize: 13)
        next.addTarget(self, action: #selector(handleInputModeList(from:with:)),
                       for: .allTouchEvents)
        let heading = label("QuicKey 0.2.1", size: 12)
        heading.textAlignment = .center
        let delete = button("⌫ Delete", id: "quickey-delete", fontSize: 13)
        delete.addTarget(self, action: #selector(deleteCharacter), for: .touchUpInside)

        let toolbar = UIStackView(arrangedSubviews: [next, heading, delete])
        toolbar.axis = .horizontal
        toolbar.spacing = 4
        toolbar.distribution = .fill
        next.widthAnchor.constraint(equalToConstant: 100).isActive = true
        delete.widthAnchor.constraint(equalToConstant: 100).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 33).isActive = true
        stack.addArrangedSubview(toolbar)

        let tabs = [Page.start, .handle, .quick, .more].map { tab -> UIButton in
            let key = button(tab.title, id: "quickey-page-\(tab.rawValue)",
                             selected: page == tab, fontSize: 13)
            key.tag = tab.rawValue
            key.addTarget(self, action: #selector(selectPage(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(tabs, height: 29))

        switch page {
        case .start: buildStartPage()
        case .handle: buildHandlePage()
        case .quick: addShortcuts(shortcuts, prefix: "quick", action: #selector(insertQuick(_:)))
        case .more: buildMorePage()
        }
        heightConstraint?.constant = page == .handle ? 434 : (page == .more ? 353 : 294)
    }

    private func roleSelector() {
        let keys = CommandRole.allCases.enumerated().map { index, role -> UIButton in
            let key = button(role.label, id: "quickey-role-\(role.rawValue)",
                             selected: selectedRole == role, fontSize: 12)
            key.tag = index
            key.addTarget(self, action: #selector(selectRole(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(keys, height: 33))
    }

    private func buildStartPage() {
        stack.addArrangedSubview(label("Choose role (remembered):"))
        roleSelector()
        appendButton("Start new chat • \(selectedRole.command)", id: "quickey-start-chat",
                     action: #selector(insertNewChat), height: 46, selected: true)
        let fast = button("FAST+DEEP", id: "quickey-start-fast")
        fast.addTarget(self, action: #selector(insertFastDeep), for: .touchUpInside)
        let refresh = button("Refresh system", id: "quickey-start-refresh")
        refresh.addTarget(self, action: #selector(insertRefresh), for: .touchUpInside)
        stack.addArrangedSubview(row([fast, refresh], height: 39))
        let pr = button("git.handle PR #", id: "quickey-start-pr")
        pr.addTarget(self, action: #selector(insertPRPrefix), for: .touchUpInside)
        let issue = button("git.handle Issue #", id: "quickey-start-issue")
        issue.addTarget(self, action: #selector(insertIssuePrefix), for: .touchUpInside)
        stack.addArrangedSubview(row([pr, issue], height: 39))
        stack.addArrangedSubview(label("Start inserts your complete new-chat setup. No automatic submit."))
    }

    private func addShortcuts(_ items: [Shortcut], prefix: String, action: Selector) {
        for line in 0..<3 {
            let keys = (0..<2).map { column -> UIButton in
                let index = line * 2 + column
                let key = button(items[index].title, id: "quickey-\(prefix)-\(index)")
                key.tag = index
                key.addTarget(self, action: action, for: .touchUpInside)
                return key
            }
            stack.addArrangedSubview(row(keys, height: 48))
        }
        stack.addArrangedSubview(label("Text insertion only. Complete any placeholder before submitting."))
    }

    private func buildMorePage() {
        stack.addArrangedSubview(label("Select a role, then insert its entry command:"))
        roleSelector()
        appendButton("Insert \(selectedRole.command)", id: "quickey-more-insert-role",
                     action: #selector(insertSelectedRole), height: 37)
        addShortcuts(controls, prefix: "control", action: #selector(insertControl(_:)))
    }

    private func buildHandlePage() {
        roleSelector()
        let styleButtons = HandleStyle.allCases.enumerated().map { index, style -> UIButton in
            let key = button(style.label, id: "quickey-style-\(style.rawValue)",
                             selected: selectedStyle == style, fontSize: 12)
            key.tag = index
            key.addTarget(self, action: #selector(selectStyle(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(styleButtons, height: 28))

        let withRole = button(includeRole ? "Role ✓" : "No role", id: "quickey-with-role",
                              selected: includeRole, fontSize: 12)
        withRole.addTarget(self, action: #selector(toggleRole), for: .touchUpInside)
        let kindButtons = HandleKind.allCases.enumerated().map { index, kind -> UIButton in
            let key = button(kind.command, id: "quickey-kind-\(kind.rawValue)",
                             selected: selectedKind == kind, fontSize: 13)
            key.tag = index
            key.addTarget(self, action: #selector(selectKind(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row([withRole] + kindButtons, height: 30))

        let number = label("", size: 14)
        number.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        numberLabel = number
        let deleteDigit = button("⌫", id: "quickey-digit-delete")
        deleteDigit.addTarget(self, action: #selector(backspaceDigit), for: .touchUpInside)
        let clear = button("Clear", id: "quickey-clear-current", fontSize: 12)
        clear.addTarget(self, action: #selector(clearCurrent), for: .touchUpInside)
        let numberLine = UIStackView(arrangedSubviews: [number, deleteDigit, clear])
        numberLine.axis = .horizontal
        numberLine.distribution = .fill
        numberLine.spacing = 4
        deleteDigit.widthAnchor.constraint(equalToConstant: 45).isActive = true
        clear.widthAnchor.constraint(equalToConstant: 57).isActive = true
        numberLine.heightAnchor.constraint(equalToConstant: 29).isActive = true
        stack.addArrangedSubview(numberLine)

        for group in [[1,2,3,4,5], [6,7,8,9,0]] {
            let keys = group.map { digit -> UIButton in
                let key = button(String(digit), id: "quickey-digit-\(digit)", fontSize: 17)
                key.tag = digit
                key.addTarget(self, action: #selector(enterDigit(_:)), for: .touchUpInside)
                return key
            }
            stack.addArrangedSubview(row(keys, height: 37))
        }

        let preview = label("", size: 11)
        preview.textColor = .label
        preview.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        preview.numberOfLines = 5
        preview.lineBreakMode = .byTruncatingTail
        preview.accessibilityIdentifier = "quickey-handle-preview"
        preview.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stack.addArrangedSubview(preview)
        previewLabel = preview

        let undo = button("↶ Undo", id: "quickey-target-undo", fontSize: 12)
        undo.addTarget(self, action: #selector(undoTarget), for: .touchUpInside)
        let add = button("+ Add", id: "quickey-target-add", fontSize: 12)
        add.addTarget(self, action: #selector(addTarget), for: .touchUpInside)
        let insert = button("Insert", id: "quickey-target-insert", selected: true)
        insert.addTarget(self, action: #selector(insertHandle), for: .touchUpInside)
        insertButton = insert
        stack.addArrangedSubview(row([undo, add, insert], height: 40))
        stack.addArrangedSubview(label("PR/Issue → digits → + Add → next target → Insert.", size: 11))
        refreshHandlePreview()
    }

    private func pendingTargets() -> [HandleTarget]? {
        if digits.isEmpty { return committedTargets }
        guard CommandTemplates.isValidNumber(digits) else { return nil }
        return committedTargets + [HandleTarget(kind: selectedKind, number: digits)]
    }

    private func refreshHandlePreview() {
        numberLabel?.text = "\(selectedKind.command) #\(digits.isEmpty ? "…" : digits)"
        let targets = pendingTargets() ?? []
        let text = CommandTemplates.composeMulti(role: selectedRole, targets: targets,
                                                 style: selectedStyle, includeRole: includeRole)
        previewLabel?.text = text ?? "Select PR or Issue and enter a positive number."
        insertButton?.isEnabled = text != nil
    }

    @objc private func selectPage(_ sender: UIButton) {
        guard let selected = Page(rawValue: sender.tag) else { return }
        page = selected
        render()
    }

    @objc private func selectRole(_ sender: UIButton) {
        let roles = CommandRole.allCases
        guard roles.indices.contains(sender.tag) else { return }
        selectedRole = roles[sender.tag]
        UserDefaults.standard.set(selectedRole.rawValue, forKey: "QuicKeyLastRole")
        render()
    }

    @objc private func selectStyle(_ sender: UIButton) {
        let options = HandleStyle.allCases
        guard options.indices.contains(sender.tag) else { return }
        selectedStyle = options[sender.tag]
        render()
    }

    @objc private func selectKind(_ sender: UIButton) {
        let options = HandleKind.allCases
        guard options.indices.contains(sender.tag) else { return }
        selectedKind = options[sender.tag]
        render()
    }

    @objc private func toggleRole() {
        includeRole.toggle()
        render()
    }

    @objc private func enterDigit(_ sender: UIButton) {
        guard (0...9).contains(sender.tag) else { return }
        if digits.isEmpty && sender.tag == 0 { return }
        digits.append(String(sender.tag))
        refreshHandlePreview()
    }

    @objc private func backspaceDigit() {
        if !digits.isEmpty { digits.removeLast() }
        refreshHandlePreview()
    }

    @objc private func clearCurrent() {
        digits = ""
        refreshHandlePreview()
    }

    @objc private func addTarget() {
        guard CommandTemplates.isValidNumber(digits) else { return }
        committedTargets.append(HandleTarget(kind: selectedKind, number: digits))
        digits = ""
        refreshHandlePreview()
    }

    @objc private func undoTarget() {
        if !digits.isEmpty {
            digits = ""
        } else if !committedTargets.isEmpty {
            let last = committedTargets.removeLast()
            selectedKind = last.kind
            digits = last.number
        }
        render()
    }

    @objc private func insertHandle() {
        guard let targets = pendingTargets(),
              let text = CommandTemplates.composeMulti(role: selectedRole, targets: targets,
                                                       style: selectedStyle,
                                                       includeRole: includeRole) else { return }
        textDocumentProxy.insertText(text)
    }

    @objc private func insertNewChat() {
        textDocumentProxy.insertText(CommandTemplates.newChat(role: selectedRole))
    }

    @objc private func insertFastDeep() {
        textDocumentProxy.insertText(CommandTemplates.fastDeepPrefix)
    }

    @objc private func insertRefresh() {
        textDocumentProxy.insertText("cmd.refresh system")
    }

    @objc private func insertPRPrefix() {
        textDocumentProxy.insertText("git.handle PR #")
    }

    @objc private func insertIssuePrefix() {
        textDocumentProxy.insertText("git.handle Issue #")
    }

    @objc private func insertSelectedRole() {
        textDocumentProxy.insertText(selectedRole.command)
    }

    @objc private func insertQuick(_ sender: UIButton) {
        guard shortcuts.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(shortcuts[sender.tag].text)
    }

    @objc private func insertControl(_ sender: UIButton) {
        guard controls.indices.contains(sender.tag) else { return }
        textDocumentProxy.insertText(controls[sender.tag].text)
    }

    @objc private func deleteCharacter() {
        textDocumentProxy.deleteBackward()
    }
}
