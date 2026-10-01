import Foundation

/// Errors the security contact can encounter while logging a new suspicious
/// incident — whether typed manually or captured via the Share Extension.
public enum IncidentLoggingError: LocalizedError, Equatable {
    /// The content field was left blank.
    case emptyContentSubmitted

    /// The same content was already logged as an open incident — protects
    /// against the same forwarded phishing email being logged twice by
    /// accident (e.g. shared once from Mail, then again from a Slack
    /// forward of the same email).
    case duplicateIncidentDetected(existingIncidentID: UUID)

    /// The underlying store could not be reached or written to.
    case incidentStoreUnavailable(reason: String)

    public var errorDescription: String? {
        switch self {
        case .emptyContentSubmitted:
            return "Add the suspicious message or link before logging it."
        case .duplicateIncidentDetected:
            return "This content is already logged as an open incident."
        case .incidentStoreUnavailable:
            return "ThreatLine couldn't save this incident right now."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .emptyContentSubmitted:
            return "Paste the email text, message, or link, then try again."
        case .duplicateIncidentDetected:
            return "Check the existing incident in your Open Incidents list instead of logging a new one."
        case .incidentStoreUnavailable:
            return "Try again in a moment. If this keeps happening, restart ThreatLine."
        }
    }
}
