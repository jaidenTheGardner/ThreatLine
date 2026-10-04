import Foundation
import Observation
import WidgetKit

/// Drives the "Pending Shared Reports" inbox — items captured quickly via
/// the Share Extension that still need the security contact to assign a
/// severity and threat category before they become fully-tracked incidents.
@Observable
@MainActor
public final class PendingReportsViewModel {
    public private(set) var pendingReports: [SuspiciousIncident] = []
    public private(set) var presentedError: LocalizedError?
    public private(set) var isLoading = false

    private let repository: IncidentRepository
    private let triageIncident: TriageIncidentUseCase

    public init(repository: IncidentRepository) {
        self.repository = repository
        self.triageIncident = TriageIncidentUseCase(repository: repository)
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            pendingReports = try await repository.fetchPendingReports()
            presentedError = nil
        } catch {
            presentedError = IncidentQueryError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }

    /// Promotes a pending report into a fully-tracked open incident.
    public func promote(
        incidentID: UUID,
        severity: IncidentSeverity,
        threatCategory: ThreatCategory,
        performedBy: String
    ) async {
        do {
            _ = try await triageIncident.execute(
                incidentID: incidentID,
                newStatus: .open,
                updatedSeverity: severity,
                updatedThreatCategory: threatCategory,
                performedBy: performedBy
            )
            WidgetCenter.shared.reloadAllTimelines()
            await refresh()
        } catch let error as TriageError {
            presentedError = error
        } catch {
            presentedError = TriageError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }

    /// Dismisses a pending report that turns out not to be worth tracking.
    public func dismissAsFalsePositive(incidentID: UUID, notes: String, performedBy: String) async {
        do {
            _ = try await triageIncident.execute(
                incidentID: incidentID,
                newStatus: .falsePositive,
                resolutionNotes: notes,
                performedBy: performedBy
            )
            WidgetCenter.shared.reloadAllTimelines()
            await refresh()
        } catch let error as TriageError {
            presentedError = error
        } catch {
            presentedError = TriageError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }
}
