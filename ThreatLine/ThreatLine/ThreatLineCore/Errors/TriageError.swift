import Foundation

/// Errors the security contact can encounter while triaging (updating the
/// status of) an incident.
public enum TriageError: LocalizedError, Equatable {
    case incidentNotFound(id: UUID)
    case incidentAlreadyResolved
    case invalidStatusTransition(from: IncidentStatus, to: IncidentStatus)
    case resolutionNotesRequired
    case incidentStoreUnavailable(reason: String)

    public var errorDescription: String? {
        switch self {
        case .incidentNotFound:
            return "This incident could not be found — it may have been removed."
        case .incidentAlreadyResolved:
            return "This incident is already closed and can't be updated further."
        case .invalidStatusTransition(let from, let to):
            return "An incident can't move from \(from.displayLabel) straight to \(to.displayLabel)."
        case .resolutionNotesRequired:
            return "Add a resolution note before closing this incident."
        case .incidentStoreUnavailable:
            return "ThreatLine couldn't save this update right now."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .incidentNotFound:
            return "Return to Open Incidents and refresh the list."
        case .incidentAlreadyResolved:
            return "Open the incident from Resolved Archive if you need to review it."
        case .invalidStatusTransition:
            return "Move it through the normal review steps instead of skipping ahead."
        case .resolutionNotesRequired:
            return "Briefly describe what you found or did, then submit again."
        case .incidentStoreUnavailable:
            return "Try again in a moment. If this keeps happening, restart ThreatLine."
        }
    }
}
