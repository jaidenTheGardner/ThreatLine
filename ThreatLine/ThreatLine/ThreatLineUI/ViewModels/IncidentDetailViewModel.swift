import Foundation
import Observation
import WidgetKit

/// Drives the Incident Detail & Triage screen — the security contact's main
/// workspace for a single incident: reviewing content, changing status, and
/// seeing the full triage timeline via `DomainAuditable`.
@Observable
@MainActor
public final class IncidentDetailViewModel {
    public private(set) var incident: SuspiciousIncident
    public private(set) var timeline: [any DomainAuditable] = []
    public private(set) var presentedError: LocalizedError?

    private let repository: IncidentRepository
    private let triageIncident: TriageIncidentUseCase

    public init(incident: SuspiciousIncident, repository: IncidentRepository) {
        self.incident = incident
        self.repository = repository
        self.triageIncident = TriageIncidentUseCase(repository: repository)
    }

    public func loadTimeline() async {
        do {
            timeline = try await repository.fetchTriageActions(for: incident.id)
        } catch {
            presentedError = IncidentQueryError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }

    public func updateStatus(to newStatus: IncidentStatus, resolutionNotes: String?, performedBy: String) async {
        do {
            incident = try await triageIncident.execute(
                incidentID: incident.id,
                newStatus: newStatus,
                resolutionNotes: resolutionNotes,
                performedBy: performedBy
            )
            await loadTimeline()
            presentedError = nil
            WidgetCenter.shared.reloadAllTimelines()
        } catch let error as TriageError {
            presentedError = error
        } catch {
            presentedError = TriageError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }
}
