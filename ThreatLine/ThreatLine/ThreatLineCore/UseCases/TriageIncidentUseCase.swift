import Foundation

// Moves an incident through its triage lifecycle: promoting a pending
// shared report into a fully-tracked open incident, escalating it, or
// closing it out as resolved or a false positive.
//
// Business operation: Whenever the security contact decides the incident's
// situation has changed, that decision must be valid for where the incident
// currently is  and it must leave a timestamped record of what changed.
public struct TriageIncidentUseCase {
    private let repository: IncidentRepository

    // Business Rule: the only status changes permitted from each starting
    // status — a `.pendingReview` report must become `.open` (or be
    // dismissed as `.falsePositive`) before it can ever be `.escalated` or
    // `.resolved`.
    private static let allowedTransitions: [IncidentStatus: Set<IncidentStatus>] = [
        .pendingReview: [.open, .falsePositive],
        .open: [.escalated, .resolved, .falsePositive],
        .escalated: [.resolved, .falsePositive]
    ]

    public init(repository: IncidentRepository) {
        self.repository = repository
    }

    // - Parameters:
    //   - updatedSeverity/updatedThreatCategory: optional corrections applied
    //     at the same time as the status change. Primarily used when
    //     promoting a `.pendingReview` report into a fully triaged `.open`
    //     incident.
    //   - resolutionNotes: required when `newStatus` is `.resolved` or
    //     `.falsePositive`.
    // - Throws: `TriageError` for any invalid request
    @discardableResult
    public func execute(
        incidentID: UUID,
        newStatus: IncidentStatus,
        updatedSeverity: IncidentSeverity? = nil,
        updatedThreatCategory: ThreatCategory? = nil,
        resolutionNotes: String? = nil,
        performedBy: String,
        now: Date = Date()
    ) async throws -> SuspiciousIncident {
        let existing: SuspiciousIncident?
        do {
            existing = try await repository.fetchIncident(id: incidentID)
        } catch {
            throw TriageError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
        guard var incident = existing else {
            throw TriageError.incidentNotFound(id: incidentID)
        }

        guard incident.status != .resolved && incident.status != .falsePositive else {
            throw TriageError.incidentAlreadyResolved
        }
        guard Self.allowedTransitions[incident.status]?.contains(newStatus) == true else {
            throw TriageError.invalidStatusTransition(from: incident.status, to: newStatus)
        }

        if newStatus == .resolved || newStatus == .falsePositive {
            guard let notes = resolutionNotes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty else {
                throw TriageError.resolutionNotesRequired
            }
            incident.resolutionNotes = notes
            incident.resolvedAt = now
        }

        if let updatedSeverity { incident.severity = updatedSeverity }
        if let updatedThreatCategory { incident.threatCategory = updatedThreatCategory }
        incident.status = newStatus

        do {
            try await repository.save(incident)
            try await repository.appendTriageAction(
                TriageAction(
                    id: UUID(),
                    incidentID: incidentID,
                    performedAt: now,
                    actionDescription: "Status changed to \(newStatus.displayLabel)",
                    changedStatusTo: newStatus,
                    performedBy: performedBy
                )
            )
        } catch {
            throw TriageError.incidentStoreUnavailable(reason: error.localizedDescription)
        }

        return incident
    }
}
