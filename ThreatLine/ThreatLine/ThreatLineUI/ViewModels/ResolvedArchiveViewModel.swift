import Foundation
import Observation

/// Drives the Resolved Archive screen — the security contact's closed-out
/// incident history, for audit and pattern-spotting (e.g. "has this sender
/// tried this before?").
@Observable
@MainActor
public final class ResolvedArchiveViewModel {
    public private(set) var resolvedIncidents: [SuspiciousIncident] = []
    public private(set) var presentedError: LocalizedError?

    private let repository: IncidentRepository

    public init(repository: IncidentRepository) {
        self.repository = repository
    }

    public func refresh() async {
        do {
            resolvedIncidents = try await repository.fetchResolvedIncidents()
            presentedError = nil
        } catch {
            presentedError = IncidentQueryError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }
}
