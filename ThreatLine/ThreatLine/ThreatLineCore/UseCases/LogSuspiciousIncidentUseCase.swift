import Foundation

// Logs a newly reported suspicious incident.
//
// Business operation: Whenever a possible threat comes to the security
// contact's attention, it must become a tracked record with a timestamp
// and the same content shouldn't get logged twice because it was forwarded
// to them through two different channels.
public struct LogSuspiciousIncidentUseCase {
    private let repository: IncidentRepository

    public init(repository: IncidentRepository) {
        self.repository = repository
    }

    // - Throws:
    //   - `IncidentLoggingError.emptyContentSubmitted` if there's no actual
    //     content to log.
    //   - `IncidentLoggingError.duplicateIncidentDetected` if the same
    //     content is already tracked as an open incident.
    //   - `IncidentLoggingError.incidentStoreUnavailable` if persistence fails.
    @discardableResult
    public func execute(
        contentSnippet: String,
        sourceChannel: ReportSourceChannel,
        threatCategory: ThreatCategory = .other,
        submitterNote: String? = nil,
        severity: IncidentSeverity = .medium,
        intakeStatus: IncidentIntakeStatus = .open,
        reportedAt: Date = Date()
    ) async throws -> SuspiciousIncident {
        let trimmed = contentSnippet.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw IncidentLoggingError.emptyContentSubmitted
        }

        let openIncidents: [SuspiciousIncident]
        do {
            openIncidents = try await repository.fetchOpenIncidents()
        } catch {
            throw IncidentLoggingError.incidentStoreUnavailable(reason: error.localizedDescription)
        }

        if let duplicate = openIncidents.first(where: { $0.contentSnippet.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            throw IncidentLoggingError.duplicateIncidentDetected(existingIncidentID: duplicate.id)
        }

        let incident = SuspiciousIncident(
            id: UUID(),
            reportedAt: reportedAt,
            sourceChannel: sourceChannel,
            threatCategory: threatCategory,
            contentSnippet: trimmed,
            submitterNote: submitterNote,
            severity: severity,
            status: intakeStatus.asIncidentStatus
        )

        do {
            try await repository.save(incident)
        } catch {
            throw IncidentLoggingError.incidentStoreUnavailable(reason: error.localizedDescription)
        }

        return incident
    }
}
