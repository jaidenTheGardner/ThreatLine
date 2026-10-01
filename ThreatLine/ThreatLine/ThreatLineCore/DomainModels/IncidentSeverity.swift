import Foundation

// How urgently a `SuspiciousIncident` needs the security contact's attention.
//
// Business Rule: Severity determines the SLA response window. The informal
// deadlines many small organisations' single security point-of-contact
// processes adopt in place of a formal SOC's ticketing SLAs.
public enum IncidentSeverity: String, CaseIterable, Codable, Sendable {
    case critical
    case high
    case medium
    case low

    public var displayLabel: String { rawValue.capitalized }

    // Maximum time this incident may remain open before it counts
    // as an SLA breach.
    public var responseWindow: TimeInterval {
        switch self {
        case .critical: return 60 * 60        // 1 hour
        case .high: return 4 * 60 * 60        // 4 hours
        case .medium: return 24 * 60 * 60     // 24 hours
        case .low: return 72 * 60 * 60        // 72 hours
        }
    }
}
