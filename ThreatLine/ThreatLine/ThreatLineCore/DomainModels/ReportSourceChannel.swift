import Foundation

/// Where the security contact (or a colleague who forwarded it to them)
/// encountered the suspicious content — matters because different channels
/// carry different real-world risk profiles (a spoofed SMS vs. a spoofed
/// internal Slack message imply different response playbooks).
public enum ReportSourceChannel: String, CaseIterable, Codable, Sendable {
    case email
    case textMessage
    case teamsOrSlack
    case phoneCall
    case other

    public var displayLabel: String {
        switch self {
        case .email: return "Email"
        case .textMessage: return "Text Message"
        case .teamsOrSlack: return "Teams / Slack"
        case .phoneCall: return "Phone Call"
        case .other: return "Other"
        }
    }
}
