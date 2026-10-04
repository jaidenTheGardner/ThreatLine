import Foundation
import Observation

/// Drives the Open Incidents dashboard — the security contact's home screen.
/// Like every ViewModel here, it holds no business logic itself: each action
/// is delegated straight to a Use Case, keeping the MVVM → Use Case →
/// Repository layering the assessment requires.
@Observable
@MainActor
public final class DashboardViewModel {
    public private(set) var openIncidents: [SuspiciousIncident] = []
    public private(set) var breachedIncidentIDs: Set<UUID> = []
    public private(set) var presentedError: LocalizedError?
    public private(set) var isLoading = false

    private let repository: IncidentRepository
    private let identifySLABreaches: IdentifySLABreachedIncidentsUseCase

    public init(repository: IncidentRepository) {
        self.repository = repository
        self.identifySLABreaches = IdentifySLABreachedIncidentsUseCase(repository: repository)
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let open = repository.fetchOpenIncidents()
            async let breaches = identifySLABreaches.execute()
            openIncidents = try await open
            breachedIncidentIDs = Set(try await breaches.map(\.id))
            presentedError = nil
        } catch let error as IncidentQueryError {
            presentedError = error
        } catch {
            presentedError = IncidentQueryError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }
}
