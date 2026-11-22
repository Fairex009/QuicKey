import UIKit

/// Offline FAIREX text keyboard. Full Access, network access and App Groups are not required.
/// UI: Start, Handle, Quick, Recent, More. Recent is keyboard-private.
final class KeyboardViewController: UIInputViewController {
    private enum Page: Int {
        case start, handle, quick, recent, more
        var title: String {
            switch self {
            case .start: return "Start"
            case .handle: return "Handle"
            case .quick: return "Quick"
            case .recent: return "Recent"
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
    private let promptHistory = PromptHistory()
    // Current insertion chain is guarded by the host text document identifier
    // and its available context before any destructive edit.
    private var activeGenerated = ""
    private var activeDocumentID: UUID?
    private var clearArmed = false
    private enum DeleteKind { case character, unit }
    private var repeatKind: DeleteKind = .unit
    private var repeatDelayTimer: Timer?
    private var repeatTimer: Timer?
    private var recentItems: [RecentPrompt] = []
    private var confirmClearHistory = false
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
                        fontSize: CGFloat = 14, tone: KeyboardTone = .neutral) -> UIButton {
        let key = UIButton(type: .system)
        key.setTitle(text, for: .normal)
        key.titleLabel?.font = .systemFont(ofSize: fontSize,
                                          weight: selected ? .semibold : .medium)
        key.titleLabel?.adjustsFontSizeToFitWidth = true
        key.titleLabel?.minimumScaleFactor = 0.73
        let colors = KeyboardTheme.colors(for: tone, selected: selected, traits: traitCollection)
        key.backgroundColor = colors.background
        key.setTitleColor(colors.foreground, for: .normal)
        key.tintColor = colors.foreground
        key.layer.borderWidth = selected ? 1.4 : (tone == .neutral ? 0.35 : 0.8)
        key.layer.borderColor = colors.border.withAlphaComponent(selected ? 1 : 0.65).cgColor
        key.layer.cornerRadius = 9
        key.accessibilityIdentifier = id
        if selected { key.accessibilityTraits.insert(.selected) }
        return key
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.backgroundColor = .secondarySystemBackground
            render()
        }
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
                              height: CGFloat = 40, selected: Bool = false,
                              tone: KeyboardTone = .neutral) {
        let key = button(title, id: id, selected: selected, tone: tone)
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
        let heading = label("QuicKey 0.2.4", size: 12)
        heading.textAlignment = .center

        let character = topIcon("delete.left", id: "quickey-delete-character",
                                help: "Delete one character. Hold to repeat.")
        let word = topIcon("text.badge.minus", id: "quickey-delete-unit",
                           help: "Delete last word or FAIREX command line. Hold to repeat.")
        let clear = topIcon("trash", id: "quickey-clear-generated",
                            help: clearArmed ? "Confirm clear generated text" :
                                               "Clear text generated by QuicKey",
                            tone: .danger, selected: clearArmed)
        let letterHold = UILongPressGestureRecognizer(target: self,
                              action: #selector(handleDeletePress(_:)))
        letterHold.minimumPressDuration = 0
        character.addGestureRecognizer(letterHold)
        let wordHold = UILongPressGestureRecognizer(target: self,
                              action: #selector(handleDeletePress(_:)))
        wordHold.minimumPressDuration = 0
        word.addGestureRecognizer(wordHold)
        clear.addTarget(self, action: #selector(clearGeneratedText), for: .touchUpInside)

        let tools = UIStackView(arrangedSubviews: [character, word, clear])
        tools.axis = .horizontal
        tools.spacing = 4
        tools.distribution = .fillEqually
        tools.widthAnchor.constraint(equalToConstant: 118).isActive = true

        let toolbar = UIStackView(arrangedSubviews: [next, heading, tools])
        toolbar.axis = .horizontal
        toolbar.spacing = 4
        toolbar.distribution = .fill
        next.widthAnchor.constraint(equalToConstant: 90).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        stack.addArrangedSubview(toolbar)

        let tabs = [Page.start, .handle, .quick, .recent, .more].map { tab -> UIButton in
            let key = button(tab.title, id: "quickey-page-\(tab.rawValue)",
                             selected: page == tab, fontSize: 13, tone: .navigation)
            key.tag = tab.rawValue
            key.addTarget(self, action: #selector(selectPage(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(tabs, height: 29))

        switch page {
        case .start: buildStartPage()
        case .handle: buildHandlePage()
        case .quick: addShortcuts(shortcuts, prefix: "quick", action: #selector(insertQuick(_:)))
        case .recent: buildRecentPage()
        case .more: buildMorePage()
        }
        heightConstraint?.constant = page == .handle ? 434 : (page == .more ? 353 : (page == .recent ? 365 : 294))
    }

    private func topIcon(_ symbol: String, id: String, help: String,
                         tone: KeyboardTone = .neutral, selected: Bool = false) -> UIButton {
        let key = button("", id: id, selected: selected, tone: tone)
        let image = UIImage(systemName: symbol) ?? UIImage(systemName: "delete.left")
        key.setImage(image, for: .normal)
        key.imageView?.contentMode = .scaleAspectFit
        key.accessibilityLabel = help
        key.accessibilityHint = help
        return key
    }

    /// Saves every generated insertion immediately, not only the Handle button.
    /// When the cursor still follows our previous generated text, the saved
    /// prompt is updated to the complete combined value instead of duplicating.
    private func insertTracked(_ text: String) {
        guard !text.isEmpty else { return }
        let proxy = textDocumentProxy
        let sameContext = activeDocumentID == proxy.documentIdentifier &&
            DeletePlanner.matchesGeneratedSuffix(generated: activeGenerated,
                                                  beforeCursor: proxy.documentContextBeforeInput)
        let prior = sameContext ? activeGenerated : ""
        proxy.insertText(text)
        activeDocumentID = proxy.documentIdentifier
        activeGenerated = prior + text
        promptHistory.saveReplacing(previous: sameContext ? prior : nil,
                                    with: activeGenerated)
        if clearArmed {
            clearArmed = false
            render()
        }
    }

    private func performDeletion(_ mode: DeleteKind) {
        let proxy = textDocumentProxy
        guard proxy.hasText else { return }
        let context = proxy.documentContextBeforeInput ?? ""
        let tracked = activeDocumentID == proxy.documentIdentifier &&
            DeletePlanner.matchesGeneratedSuffix(generated: activeGenerated,
                                                  beforeCursor: proxy.documentContextBeforeInput)
        let count: Int
        switch mode {
        case .character: count = 1
        case .unit: count = DeletePlanner.previousUnitLength(in: context)
        }
        guard count > 0 else { return }

        // Do not delete beyond the context iOS actually exposes.
        let bounded = min(count, max(Array(context).count, 1))
        for _ in 0..<bounded {
            proxy.deleteBackward()
        }

        if tracked {
            activeGenerated = String(activeGenerated.dropLast(min(bounded, activeGenerated.count)))
            // Recent archives already-inserted generated text. Deleting from
            // the host field must never silently destroy that saved history.
        } else {
            activeGenerated = ""
            activeDocumentID = nil
        }
        clearArmed = false
    }

    /// Starts on finger-down, repeats after a deliberate 350ms hold.
    /// This avoids a duplicate TouchUpInside deletion after long pressing.
    @objc private func handleDeletePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            repeatDelayTimer?.invalidate()
            repeatTimer?.invalidate()
            repeatKind = gesture.view?.accessibilityIdentifier == "quickey-delete-unit"
                ? .unit : .character
            performDeletion(repeatKind)
            repeatDelayTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self,
                selector: #selector(startDeleteRepeat), userInfo: nil, repeats: false)
        case .ended, .cancelled, .failed:
            repeatDelayTimer?.invalidate()
            repeatTimer?.invalidate()
            repeatDelayTimer = nil
            repeatTimer = nil
        default: break
        }
    }

    @objc private func startDeleteRepeat() {
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self,
            selector: #selector(repeatDelete), userInfo: nil, repeats: true)
    }

    @objc private func repeatDelete() {
        performDeletion(repeatKind)
    }

    /// Two taps are required. Only delete text QuicKey knows it inserted
    /// at the active cursor. Never clear unknown surrounding host text.
    @objc private func clearGeneratedText() {
        if !clearArmed {
            clearArmed = true
            render()
            return
        }
        clearArmed = false
        let proxy = textDocumentProxy
        guard activeDocumentID == proxy.documentIdentifier,
              (proxy.selectedText ?? "").isEmpty else {
            render()
            return
        }
        let count = DeletePlanner.safeClearLength(generated: activeGenerated,
                                                  beforeCursor: proxy.documentContextBeforeInput)
        guard count > 0 else {
            render()
            return
        }
        for _ in 0..<count { proxy.deleteBackward() }
        // Keep the saved Recent entry, even after the current field is cleared.
        activeGenerated = ""
        activeDocumentID = nil
        render()
    }

    private func roleSelector() {
        let keys = CommandRole.allCases.enumerated().map { index, role -> UIButton in
            let key = button(role.label, id: "quickey-role-\(role.rawValue)",
                             selected: selectedRole == role, fontSize: 12, tone: .role)
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
                     action: #selector(insertNewChat), height: 46, selected: true, tone: .action)
        let fast = button("FAST+DEEP", id: "quickey-start-fast", tone: .workflow)
        fast.addTarget(self, action: #selector(insertFastDeep), for: .touchUpInside)
        let refresh = button("Refresh system", id: "quickey-start-refresh", tone: .navigation)
        refresh.addTarget(self, action: #selector(insertRefresh), for: .touchUpInside)
        stack.addArrangedSubview(row([fast, refresh], height: 39))
        let pr = button("git.handle PR #", id: "quickey-start-pr", tone: .pr)
        pr.addTarget(self, action: #selector(insertPRPrefix), for: .touchUpInside)
        let issue = button("git.handle Issue #", id: "quickey-start-issue", tone: .issue)
        issue.addTarget(self, action: #selector(insertIssuePrefix), for: .touchUpInside)
        stack.addArrangedSubview(row([pr, issue], height: 39))
        stack.addArrangedSubview(label("Start inserts your complete new-chat setup. No automatic submit."))
    }

    private func addShortcuts(_ items: [Shortcut], prefix: String, action: Selector) {
        for line in 0..<3 {
            let keys = (0..<2).map { column -> UIButton in
                let index = line * 2 + column
                let tone: KeyboardTone
                if items[index].title.contains("PR") {
                    tone = .pr
                } else if items[index].title.contains("Issue") {
                    tone = .issue
                } else if items[index].title.contains("DEEP") ||
                          items[index].title.contains("Deep") ||
                          items[index].title.contains("Batch") ||
                          items[index].title.contains("Nonstop") ||
                          items[index].title.contains("All-in-one") {
                    tone = .workflow
                } else {
                    tone = .navigation
                }
                let key = button(items[index].title, id: "quickey-\(prefix)-\(index)", tone: tone)
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
                     action: #selector(insertSelectedRole), height: 37, tone: .role)
        addShortcuts(controls, prefix: "control", action: #selector(insertControl(_:)))
    }

    /// Only explicitly generated QuicKey prompts are stored in private defaults.
    private func buildRecentPage() {
        recentItems = promptHistory.all()
        stack.addArrangedSubview(label("Last generated prompts · \(recentItems.count)/10", size: 11))

        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 4
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        NSLayoutConstraint.activate([
            list.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
        scroll.heightAnchor.constraint(equalToConstant: 209).isActive = true

        if recentItems.isEmpty {
            list.addArrangedSubview(label("No complete prompts yet. Insert a Git Handle or Start Chat then Handle.", size: 12))
        }

        for (index, entry) in recentItems.enumerated() {
            let summary = label(entry.text.replacingOccurrences(of: "\n", with: " · "), size: 11)
            summary.numberOfLines = 2
            summary.lineBreakMode = .byTruncatingTail
            summary.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let paste = button("Paste", id: "quickey-recent-paste-\(index)", selected: index == 0, fontSize: 12, tone: .history)
            paste.tag = index
            paste.addTarget(self, action: #selector(pasteRecent(_:)), for: .touchUpInside)
            paste.widthAnchor.constraint(equalToConstant: 65).isActive = true

            let remove = button("✕", id: "quickey-recent-remove-\(index)", fontSize: 15, tone: .danger)
            remove.tag = index
            remove.accessibilityLabel = "Delete saved prompt \(index + 1)"
            remove.addTarget(self, action: #selector(removeRecent(_:)), for: .touchUpInside)
            remove.widthAnchor.constraint(equalToConstant: 34).isActive = true

            let line = UIStackView(arrangedSubviews: [summary, paste, remove])
            line.axis = .horizontal
            line.spacing = 5
            line.distribution = .fill
            line.heightAnchor.constraint(equalToConstant: 55).isActive = true
            list.addArrangedSubview(line)
        }
        stack.addArrangedSubview(scroll)

        let caption = confirmClearHistory ? "Confirm deleting all saved prompts" : "Clear all history"
        let clear = button(caption, id: "quickey-recent-clear", fontSize: 12, tone: .danger)
        clear.addTarget(self, action: #selector(clearRecent), for: .touchUpInside)
        clear.isEnabled = !recentItems.isEmpty
        clear.heightAnchor.constraint(equalToConstant: 31).isActive = true
        stack.addArrangedSubview(clear)
        stack.addArrangedSubview(label("History is separate from iPhone clipboard. Full Access stays OFF.", size: 11))
    }

    @objc private func pasteRecent(_ sender: UIButton) {
        guard recentItems.indices.contains(sender.tag) else { return }
        let text = recentItems[sender.tag].text
        insertTracked(text)
        confirmClearHistory = false
        render()
    }

    @objc private func removeRecent(_ sender: UIButton) {
        guard recentItems.indices.contains(sender.tag) else { return }
        promptHistory.remove(id: recentItems[sender.tag].id)
        confirmClearHistory = false
        render()
    }

    @objc private func clearRecent() {
        if confirmClearHistory {
            promptHistory.clear()
            confirmClearHistory = false
        } else {
            confirmClearHistory = true
        }
        render()
    }

    private func buildHandlePage() {
        roleSelector()
        let styleButtons = HandleStyle.allCases.enumerated().map { index, style -> UIButton in
            let key = button(style.label, id: "quickey-style-\(style.rawValue)",
                             selected: selectedStyle == style, fontSize: 12, tone: .workflow)
            key.tag = index
            key.addTarget(self, action: #selector(selectStyle(_:)), for: .touchUpInside)
            return key
        }
        stack.addArrangedSubview(row(styleButtons, height: 28))

        let withRole = button(includeRole ? "Role ✓" : "No role", id: "quickey-with-role",
                              selected: includeRole, fontSize: 12, tone: .role)
        withRole.addTarget(self, action: #selector(toggleRole), for: .touchUpInside)
        let kindButtons = HandleKind.allCases.enumerated().map { index, kind -> UIButton in
            let key = button(kind.command, id: "quickey-kind-\(kind.rawValue)",
                             selected: selectedKind == kind, fontSize: 13, tone: kind == .pr ? .pr : .issue)
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
        preview.backgroundColor = .tertiarySystemBackground
        preview.layer.cornerRadius = 8
        preview.clipsToBounds = true
        preview.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        preview.numberOfLines = 5
        preview.lineBreakMode = .byTruncatingTail
        preview.accessibilityIdentifier = "quickey-handle-preview"
        preview.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stack.addArrangedSubview(preview)
        previewLabel = preview

        let undo = button("↶ Undo", id: "quickey-target-undo", fontSize: 12)
        undo.addTarget(self, action: #selector(undoTarget), for: .touchUpInside)
        let add = button("+ Add", id: "quickey-target-add", fontSize: 12, tone: .pr)
        add.addTarget(self, action: #selector(addTarget), for: .touchUpInside)
        let insert = button("Insert", id: "quickey-target-insert", selected: true, tone: .action)
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
        insertButton?.alpha = text != nil ? 1.0 : 0.45
    }

    @objc private func selectPage(_ sender: UIButton) {
        guard let selected = Page(rawValue: sender.tag) else { return }
        page = selected
        clearArmed = false
        confirmClearHistory = false
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
        insertTracked(text)
    }

    @objc private func insertNewChat() {
        let prefix = CommandTemplates.newChat(role: selectedRole)
        insertTracked(prefix)
        // Start Chat already contains the role and cmd.deep: prefix. When the
        // operator next opens Handle, generate only "git.handle ..." targets.
        selectedStyle = .direct
        includeRole = false
        committedTargets = []
        digits = ""
    }

    @objc private func insertFastDeep() {
        insertTracked(CommandTemplates.fastDeepPrefix)
    }

    @objc private func insertRefresh() {
        insertTracked("cmd.refresh system")
    }

    @objc private func insertPRPrefix() {
        insertTracked("git.handle PR #")
    }

    @objc private func insertIssuePrefix() {
        insertTracked("git.handle Issue #")
    }

    @objc private func insertSelectedRole() {
        insertTracked(selectedRole.command)
    }

    @objc private func insertQuick(_ sender: UIButton) {
        guard shortcuts.indices.contains(sender.tag) else { return }
        insertTracked(shortcuts[sender.tag].text)
    }

    @objc private func insertControl(_ sender: UIButton) {
        guard controls.indices.contains(sender.tag) else { return }
        insertTracked(controls[sender.tag].text)
    }

    deinit {
        repeatDelayTimer?.invalidate()
        repeatTimer?.invalidate()
    }
}
