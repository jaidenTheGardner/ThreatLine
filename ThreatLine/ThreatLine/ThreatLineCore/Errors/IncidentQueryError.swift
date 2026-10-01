import Foundation

/// Errors that can occur while querying incidents (e.g. checking for SLA
/// breaches for the widget). Kept separate from `TriageError`/
/// `IncidentLoggingError` because a failed read is a different situation for
/// the security contact than a failed write — nothing they entered is at risk
/// of being lost.
public enum IncidentQueryError: LocalizedError, Equatable {
    case incidentStoreUnavailable(reason: String)

    public var errorDescription: String? {
        "ThreatLine couldn't load your incidents right now."
    }

    public var recoverySuggestion: String? {
        "Pull to refresh, or reopen the app in a moment."
    }
}
