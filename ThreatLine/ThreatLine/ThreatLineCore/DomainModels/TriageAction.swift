import Foundation

// A singular recorded step in a `SuspiciousIncident`'s triage history.
// The related entity to `SuspiciousIncident` in the persistence schema
// (one incident has many triage actions), giving the Incident Detail screen
// a full audit trail of how an incident was handled.
public struct TriageAction: Identifiable, Hashable, Codable, Sendable, DomainAuditable {
    public let id: UUID
    public let incidentID: UUID
    public let performedAt: Date
    public let actionDescription: String
    public let changedStatusTo: IncidentStatus?
    public let performedBy: String

    public init(
        id: UUID,
        incidentID: UUID,
        performedAt: Date,
        actionDescription: String,
        changedStatusTo: IncidentStatus?,
        performedBy: String
    ) {
        self.id = id
        self.incidentID = incidentID
        self.performedAt = performedAt
        self.actionDescription = actionDescription
        self.changedStatusTo = changedStatusTo
        self.performedBy = performedBy
    }

    // DomainAuditable

    public var recordedAt: Date { performedAt }
    public var recordedBy: String { performedBy }
    public func auditSummary() -> String { actionDescription }
}
