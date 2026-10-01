import Foundation

/// A mock `IncidentRepository` backed by in-memory arrays, protected by an
/// actor so it's safe under Swift concurrency. Used by unit tests (per
/// Requirement 5: "Tests must use a mock repository — not the real Core Data
/// stack") and by SwiftUI previews.
public actor InMemoryIncidentRepository: IncidentRepository {
    public enum Mode: Sendable {
        case normal
        case failing(reason: String)
    }

    private var incidents: [UUID: SuspiciousIncident]
    private var triageActions: [TriageAction]
    private let mode: Mode

    public init(seedIncidents: [SuspiciousIncident] = [], mode: Mode = .normal) {
        self.incidents = Dictionary(uniqueKeysWithValues: seedIncidents.map { ($0.id, $0) })
        self.triageActions = []
        self.mode = mode
    }

    public func fetchOpenIncidents() async throws -> [SuspiciousIncident] {
        try checkFailure()
        return incidents.values.filter { $0.status.countsTowardSLA }.sorted { $0.reportedAt < $1.reportedAt }
    }

    public func fetchResolvedIncidents() async throws -> [SuspiciousIncident] {
        try checkFailure()
        return incidents.values
            .filter { $0.status == .resolved || $0.status == .falsePositive }
            .sorted { ($0.resolvedAt ?? .distantPast) > ($1.resolvedAt ?? .distantPast) }
    }

    public func fetchPendingReports() async throws -> [SuspiciousIncident] {
        try checkFailure()
        return incidents.values.filter { $0.status == .pendingReview }.sorted { $0.reportedAt < $1.reportedAt }
    }

    public func fetchIncident(id: UUID) async throws -> SuspiciousIncident? {
        try checkFailure()
        return incidents[id]
    }

    public func save(_ incident: SuspiciousIncident) async throws {
        try checkFailure()
        incidents[incident.id] = incident
    }

    public func fetchTriageActions(for incidentID: UUID) async throws -> [TriageAction] {
        try checkFailure()
        return triageActions.filter { $0.incidentID == incidentID }.sorted { $0.performedAt < $1.performedAt }
    }

    public func appendTriageAction(_ action: TriageAction) async throws {
        try checkFailure()
        triageActions.append(action)
    }

    private func checkFailure() throws {
        if case .failing(let reason) = mode {
            throw IncidentQueryError.incidentStoreUnavailable(reason: reason)
        }
    }
}

// MARK: - Fixtures shared by tests and previews

public extension SuspiciousIncident {
    static func fixture(
        id: UUID = UUID(),
        reportedAt: Date = Date(),
        sourceChannel: ReportSourceChannel = .email,
        threatCategory: ThreatCategory = .phishingEmail,
        contentSnippet: String = "\"Your payroll account needs verification\" — link to bit.ly/3xampl3",
        submitterNote: String? = "Forwarded by Dana in Accounts",
        severity: IncidentSeverity = .high,
        status: IncidentStatus = .open
    ) -> SuspiciousIncident {
        SuspiciousIncident(
            id: id,
            reportedAt: reportedAt,
            sourceChannel: sourceChannel,
            threatCategory: threatCategory,
            contentSnippet: contentSnippet,
            submitterNote: submitterNote,
            severity: severity,
            status: status
        )
    }
}
