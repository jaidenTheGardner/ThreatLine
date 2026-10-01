
import XCTest
@testable import ThreatLine

final class IdentifySLABreachedIncidentsUseCaseTests: XCTestCase {

    func test_identifyBreaches_returnsOnlyIncidentsPastTheirSeverityWindow() async throws {
        let now = Date()
        let breachedCritical = SuspiciousIncident.fixture(
            reportedAt: now.addingTimeInterval(-2 * 60 * 60), // 2h old
            severity: .critical,                               // 1h window -> breached
            status: .open
        )
        let healthyLow = SuspiciousIncident.fixture(
            reportedAt: now.addingTimeInterval(-2 * 60 * 60),  // 2h old
            severity: .low,                                    // 72h window -> fine
            status: .open
        )
        let repository = InMemoryIncidentRepository(seedIncidents: [breachedCritical, healthyLow])
        let useCase = IdentifySLABreachedIncidentsUseCase(repository: repository)

        let breaches = try await useCase.execute(asOf: now)

        XCTAssertEqual(breaches.map(\.id), [breachedCritical.id])
    }

    func test_identifyBreaches_excludesResolvedIncidents_evenIfPastWhatWouldHaveBeenTheirWindow() async throws {
        let now = Date()
        let resolvedButOld = SuspiciousIncident.fixture(
            reportedAt: now.addingTimeInterval(-10 * 60 * 60),
            severity: .critical,
            status: .resolved
        )
        let repository = InMemoryIncidentRepository(seedIncidents: [resolvedButOld])
        let useCase = IdentifySLABreachedIncidentsUseCase(repository: repository)

        let breaches = try await useCase.execute(asOf: now)

        XCTAssertTrue(breaches.isEmpty)
    }

    func test_identifyBreaches_throwsIncidentStoreUnavailable_whenRepositoryFails() async {
        let repository = InMemoryIncidentRepository(mode: .failing(reason: "store locked"))
        let useCase = IdentifySLABreachedIncidentsUseCase(repository: repository)

        do {
            _ = try await useCase.execute()
            XCTFail("Expected incidentStoreUnavailable to be thrown")
        } catch {
            guard case .incidentStoreUnavailable = error as? IncidentQueryError else {
                return XCTFail("Expected incidentStoreUnavailable, got \(error)")
            }
        }
    }
}
