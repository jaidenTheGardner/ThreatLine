import Foundation

/// A single recorded step in a `SuspiciousIncident`'s triage history — one
/// status change, made by the security contact at a point in time. The
/// related entity to `SuspiciousIncident` in the persistence schema
/// (one incident has many triage actions), giving the Incident Detail screen
/// a full audit trail of how an incident was handled, not just its current
/// state.
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

    // MARK: DomainAuditable

    public var recordedAt: Date { performedAt }
    public var recordedBy: String { performedBy }
    public func auditSummary() -> String { actionDescription }
}
