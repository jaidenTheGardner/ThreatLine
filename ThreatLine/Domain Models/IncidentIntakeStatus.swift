import Foundation

/// The only two statuses a `SuspiciousIncident` is allowed to start its life
/// in. Deliberately a separate, smaller type from `IncidentStatus` rather than
/// accepting any `IncidentStatus` at creation time — this is the type system
/// enforcing a business rule (a brand-new incident can never be created
/// already `.resolved` or `.escalated`; those states must be earned through
/// `TriageIncidentUseCase`), rather than relying on every caller remembering
/// to pass the right case.
public enum IncidentIntakeStatus: Sendable {
    /// Captured quickly via the Share Extension — needs the security contact
    /// to add a severity and threat category before it's fully tracked.
    case pendingReview
    /// Logged manually with severity/category already known.
    case open

    var asIncidentStatus: IncidentStatus {
        switch self {
        case .pendingReview: return .pendingReview
        case .open: return .open
        }
    }
}
