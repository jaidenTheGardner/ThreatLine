import Foundation

// Abstracts where `SuspiciousIncident` and `TriageAction` data lives.
//
// Views and ViewModels never see this protocol's concrete implementation —
// only Use Cases hold a reference to it — so Core Data never leaks above the
// Use Case layer, and unit tests can swap in `InMemoryIncidentRepository`
// without touching a real persistent store.
public protocol IncidentRepository: Sendable {
    // Incidents whose status still counts toward SLA tracking are the
    // most urgent first. The concrete Core Data implementation expresses
    // this as a fetch request predicate over the `status` attribute.
    func fetchOpenIncidents() async throws -> [SuspiciousIncident]

    // Incidents that have reached `.resolved` or `.falsePositive`, most
    // recently resolved first.
    func fetchResolvedIncidents() async throws -> [SuspiciousIncident]

    // Incidents still awaiting the security contact's initial triage
    func fetchPendingReports() async throws -> [SuspiciousIncident]

    func fetchIncident(id: UUID) async throws -> SuspiciousIncident?

    // Inserts or updates an incident (matched by `id`).
    func save(_ incident: SuspiciousIncident) async throws

    func fetchTriageActions(for incidentID: UUID) async throws -> [TriageAction]

    func appendTriageAction(_ action: TriageAction) async throws
}
