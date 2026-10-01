import Foundation

// Identifies which open incidents have breached their severity-based SLA
// window.
//
// Business operation: Turns a passive list into an active list that details
// where action is needed.
public struct IdentifySLABreachedIncidentsUseCase {
    private let repository: IncidentRepository

    public init(repository: IncidentRepository) {
        self.repository = repository
    }

    // - Throws: `IncidentQueryError.incidentStoreUnavailable` if the
    //   incidents can't be read.
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
