import Foundation

/// Identifies which open incidents have breached their severity-based SLA
/// window — the query that powers both the widget's "SLA breach" badge and
/// an in-app dashboard alert.
///
/// Business operation, in plain English: out of everything still open, which
/// ones has the security contact now run out of time on? This is what turns
/// a passive list into something that tells them when they need to act.
public struct IdentifySLABreachedIncidentsUseCase {
    private let repository: IncidentRepository

    public init(repository: IncidentRepository) {
        self.repository = repository
    }

    /// - Throws: `IncidentQueryError.incidentStoreUnavailable` if the
    ///   incidents can't be read.
    public func execute(asOf now: Date = Date()) async throws -> [SuspiciousIncident] {
        let openIncidents: [SuspiciousIncident]
        do {
            openIncidents = try await repository.fetchOpenIncidents()
        } catch {
            throw IncidentQueryError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
        return openIncidents
            .filter { $0.slaStatus(asOf: now) == .breached }
            .sorted { $0.slaDeadline < $1.slaDeadline }
    }
}
