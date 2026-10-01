import Foundation

/// The lifecycle state of a `SuspiciousIncident`.
///
/// Business Rule: transitions are restricted — see
/// `TriageIncidentUseCase.allowedTransitions` — so an incident can't jump from
/// `.pendingReview` straight to `.resolved` without first being reviewed as
/// `.open`, and nothing can leave `.resolved`/`.falsePositive` once it lands
/// there (a finished triage record shouldn't silently reopen).
public enum IncidentStatus: String, CaseIterable, Codable, Sendable {
    /// Captured (usually via the Share Extension) but not yet given a severity
    /// or threat category by the security contact.
    case pendingReview
    /// Reviewed and actively being tracked against its SLA.
    case open
    /// Handed off to an external party (e.g. IT provider, platform abuse team).
    case escalated
    /// Confirmed genuine and closed out, with a documented resolution.
    case resolved
    /// Confirmed not a real threat and closed out, with a documented reason.
    case falsePositive

    public var displayLabel: String {
        switch self {
        case .pendingReview: return "Pending Review"
        case .open: return "Open"
        case .escalated: return "Escalated"
        case .resolved: return "Resolved"
        case .falsePositive: return "False Positive"
        }
    }

    /// Whether an incident in this status still counts toward SLA tracking.
    public var countsTowardSLA: Bool {
        self == .pendingReview || self == .open || self == .escalated
    }
}
