
import XCTest
@testable import ThreatLine

final class TriageIncidentUseCaseTests: XCTestCase {

    func test_triageIncident_resolvesSuccessfully_whenResolutionNotesProvided() async throws {
        let incident = SuspiciousIncident.fixture(status: .open)
        let repository = InMemoryIncidentRepository(seedIncidents: [incident])
        let useCase = TriageIncidentUseCase(repository: repository)

        let updated = try await useCase.execute(
            incidentID: incident.id,
            newStatus: .resolved,
            resolutionNotes: "Confirmed with IT provider — domain blocked, no further action needed.",
            performedBy: "Jaiden (Security Contact)"
        )

        XCTAssertEqual(updated.status, .resolved)
        XCTAssertNotNil(updated.resolvedAt)
        let history = try await repository.fetchTriageActions(for: incident.id)
        XCTAssertEqual(history.count, 1)
    }

    func test_triageIncident_promotesPendingReviewToOpen_withUpdatedSeverity() async throws {
        let incident = SuspiciousIncident.fixture(severity: .low, status: .pendingReview)
        let repository = InMemoryIncidentRepository(seedIncidents: [incident])
        let useCase = TriageIncidentUseCase(repository: repository)

        let updated = try await useCase.execute(
            incidentID: incident.id,
            newStatus: .open,
            updatedSeverity: .critical,
            updatedThreatCategory: .credentialHarvesting,
            performedBy: "Jaiden (Security Contact)"
        )

        XCTAssertEqual(updated.status, .open)
        XCTAssertEqual(updated.severity, .critical)
        XCTAssertEqual(updated.threatCategory, .credentialHarvesting)
    }

    func test_triageIncident_throwsResolutionNotesRequired_whenClosingWithoutNotes() async throws {
        let incident = SuspiciousIncident.fixture(status: .open)
        let repository = InMemoryIncidentRepository(seedIncidents: [incident])
        let useCase = TriageIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(incidentID: incident.id, newStatus: .resolved, performedBy: "Jaiden")
            XCTFail("Expected resolutionNotesRequired to be thrown")
        } catch {
            XCTAssertEqual(error as? TriageError, .resolutionNotesRequired)
        }
    }

    func test_triageIncident_throwsInvalidStatusTransition_whenSkippingReviewStep() async throws {
        let incident = SuspiciousIncident.fixture(status: .pendingReview)
        let repository = InMemoryIncidentRepository(seedIncidents: [incident])
        let useCase = TriageIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                incidentID: incident.id,
                newStatus: .resolved,
                resolutionNotes: "Skipping ahead",
                performedBy: "Jaiden"
            )
            XCTFail("Expected invalidStatusTransition to be thrown")
        } catch {
            XCTAssertEqual(error as? TriageError, .invalidStatusTransition(from: .pendingReview, to: .resolved))
        }
    }

    func test_triageIncident_throwsIncidentAlreadyResolved_whenRetriagingAClosedIncident() async throws {
        let incident = SuspiciousIncident.fixture(submitterNote: "Closed previously", status: .resolved)
        let repository = InMemoryIncidentRepository(seedIncidents: [incident])
        let useCase = TriageIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(incidentID: incident.id, newStatus: .open, performedBy: "Jaiden")
            XCTFail("Expected incidentAlreadyResolved to be thrown")
        } catch {
            XCTAssertEqual(error as? TriageError, .incidentAlreadyResolved)
        }
    }

    func test_triageIncident_throwsIncidentNotFound_whenIDDoesNotExist() async {
        let repository = InMemoryIncidentRepository()
        let useCase = TriageIncidentUseCase(repository: repository)
        let missingID = UUID()

        do {
            _ = try await useCase.execute(incidentID: missingID, newStatus: .open, performedBy: "Jaiden")
            XCTFail("Expected incidentNotFound to be thrown")
        } catch {
            XCTAssertEqual(error as? TriageError, .incidentNotFound(id: missingID))
        }
    }
}
