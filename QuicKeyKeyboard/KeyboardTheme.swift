import UIKit

/// Visual semantic coding. Never uses color alone to determine command behavior.
/// Uses contrast-adjusted hues for light/dark mode, and no external assets.
enum KeyboardTone {
    case neutral, navigation, role, pr, issue, workflow, action, history, danger
}

struct KeyboardTheme {
    struct Colors {
        let background: UIColor
        let foreground: UIColor
        let border: UIColor
    }

    private static func rgb(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255,
                blue: CGFloat(b) / 255, alpha: 1)
    }

    static func colors(for tone: KeyboardTone, selected: Bool,
                       traits: UITraitCollection) -> Colors {
        let dark = traits.userInterfaceStyle == .dark
        switch tone {
        case .neutral:
            return Colors(background: .tertiarySystemBackground,
                          foreground: .label, border: .separator)
        case .navigation:
            if !selected {
                return Colors(background: .tertiarySystemBackground,
                              foreground: .secondaryLabel, border: .separator)
            }
            return dark
                ? Colors(background: rgb(36, 52, 81), foreground: rgb(219, 234, 254), border: rgb(96, 165, 250))
                : Colors(background: rgb(220, 232, 255), foreground: rgb(29, 78, 216), border: rgb(59, 130, 246))
        case .role:
            return dark
                ? Colors(background: selected ? rgb(36, 65, 105) : rgb(27, 44, 67),
                         foreground: rgb(191, 219, 254), border: rgb(96, 165, 250))
                : Colors(background: selected ? rgb(204, 225, 255) : rgb(234, 244, 255),
                         foreground: rgb(30, 70, 158), border: rgb(59, 130, 246))
        case .pr:
            return dark
                ? Colors(background: selected ? rgb(22, 80, 69) : rgb(20, 57, 51),
                         foreground: rgb(167, 243, 208), border: rgb(52, 211, 153))
                : Colors(background: selected ? rgb(191, 240, 222) : rgb(224, 248, 240),
                         foreground: rgb(6, 95, 83), border: rgb(16, 185, 129))
        case .issue:
            return dark
                ? Colors(background: selected ? rgb(86, 62, 24) : rgb(69, 48, 21),
                         foreground: rgb(253, 230, 138), border: rgb(251, 191, 36))
                : Colors(background: selected ? rgb(255, 224, 161) : rgb(255, 241, 214),
                         foreground: rgb(146, 64, 14), border: rgb(245, 158, 11))
        case .workflow:
            return dark
                ? Colors(background: selected ? rgb(77, 52, 112) : rgb(53, 38, 78),
                         foreground: rgb(221, 214, 254), border: rgb(167, 139, 250))
                : Colors(background: selected ? rgb(222, 210, 255) : rgb(238, 232, 255),
                         foreground: rgb(91, 33, 182), border: rgb(139, 92, 246))
        case .action:
            return dark
                ? Colors(background: rgb(47, 205, 153), foreground: rgb(5, 36, 27), border: rgb(47, 205, 153))
                : Colors(background: rgb(21, 113, 77), foreground: .white, border: rgb(21, 113, 77))
        case .history:
            return dark
                ? Colors(background: selected ? rgb(79, 45, 97) : rgb(52, 33, 68),
                         foreground: rgb(233, 213, 255), border: rgb(192, 132, 252))
                : Colors(background: selected ? rgb(230, 203, 255) : rgb(245, 234, 255),
                         foreground: rgb(107, 33, 168), border: rgb(168, 85, 247))
        case .danger:
            return dark
                ? Colors(background: rgb(74, 33, 39), foreground: rgb(254, 202, 202), border: rgb(248, 113, 113))
                : Colors(background: rgb(254, 226, 226), foreground: rgb(153, 27, 27), border: rgb(248, 113, 113))
        }
    }
}
