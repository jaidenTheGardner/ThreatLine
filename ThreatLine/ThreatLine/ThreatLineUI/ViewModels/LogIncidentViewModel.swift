import Foundation
import Observation
import WidgetKit

/// Drives the "Log New Incident" screen.
@Observable
@MainActor
public final class LogIncidentViewModel {
    public private(set) var presentedError: LocalizedError?
    public private(set) var didLogIncident = false
    public private(set) var isSubmitting = false

    private let logIncident: LogSuspiciousIncidentUseCase

    public init(repository: IncidentRepository) {
        self.logIncident = LogSuspiciousIncidentUseCase(repository: repository)
    }

    public func submit(
        contentSnippet: String,
        sourceChannel: ReportSourceChannel,
        threatCategory: ThreatCategory,
        severity: IncidentSeverity,
        submitterNote: String
    ) async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            _ = try await logIncident.execute(
                contentSnippet: contentSnippet,
                sourceChannel: sourceChannel,
                threatCategory: threatCategory,
                submitterNote: submitterNote.isEmpty ? nil : submitterNote,
                severity: severity,
                intakeStatus: .open
            )
            didLogIncident = true
            presentedError = nil
            // Requirement 2: "the main app calls the WidgetCenter reload API
            // after every relevant data change" — a newly logged incident can
            // change the widget's open-incident count and SLA badge.
            WidgetCenter.shared.reloadAllTimelines()
        } catch let error as IncidentLoggingError {
            presentedError = error
        } catch {
            presentedError = IncidentLoggingError.incidentStoreUnavailable(reason: error.localizedDescription)
        }
    }

    public func reset() {
        didLogIncident = false
        presentedError = nil
    }
}
