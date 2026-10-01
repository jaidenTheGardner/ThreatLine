import Foundation

// Where the suspicious content was encountered. This matters because different
// channels carry different real-world risk profiles.
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
