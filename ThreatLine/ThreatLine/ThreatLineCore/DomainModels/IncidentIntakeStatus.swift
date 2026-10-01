import Foundation

// The only two statuses a `SuspiciousIncident` is allowed to start its life
// in. 
public enum IncidentIntakeStatus: Sendable {
    // Captured quickly via the Share Extension — needs the security contact
    // to add a severity and threat category before it's fully tracked.
    case pendingReview
    // Logged manually with severity/category already known.
    case open

    var asIncidentStatus: IncidentStatus {
        switch self {
        case .pendingReview: return .pendingReview
        case .open: return .open
        }
    }
}
