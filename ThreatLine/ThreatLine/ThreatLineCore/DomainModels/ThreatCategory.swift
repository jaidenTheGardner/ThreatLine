import Foundation

// The kind of attack the security contact suspects this content represents.
public enum ThreatCategory: String, CaseIterable, Codable, Sendable {
    case phishingEmail
    case maliciousLink
    case impersonation
    case credentialHarvesting
    case other

    public var displayLabel: String {
        switch self {
        case .phishingEmail: return "Phishing Email"
        case .maliciousLink: return "Malicious Link"
        case .impersonation: return "Impersonation"
        case .credentialHarvesting: return "Credential Harvesting"
        case .other: return "Other"
        }
    }
}
