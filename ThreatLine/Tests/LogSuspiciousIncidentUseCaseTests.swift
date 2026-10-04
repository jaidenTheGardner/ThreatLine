
import XCTest
@testable import ThreatLine

final class LogSuspiciousIncidentUseCaseTests: XCTestCase {

    func test_logIncident_succeeds_andStartsOpen_whenIntakeStatusIsOpen() async throws {
        let repository = InMemoryIncidentRepository()
        let useCase = LogSuspiciousIncidentUseCase(repository: repository)

        let incident = try await useCase.execute(
            contentSnippet: "Urgent: verify your payroll details at bit.ly/3xampl3",
            sourceChannel: .email,
            threatCategory: .phishingEmail,
            severity: .high,
            intakeStatus: .open
        )

        XCTAssertEqual(incident.status, .open)
        XCTAssertEqual(incident.severity, .high)
    }

    func test_logIncident_startsPendingReview_whenCapturedViaShareExtension() async throws {
        let repository = InMemoryIncidentRepository()
        let useCase = LogSuspiciousIncidentUseCase(repository: repository)

        let incident = try await useCase.execute(
            contentSnippet: "http://suspicious-login-portal.example",
            sourceChannel: .other,
            submitterNote: "Captured via Share Sheet",
            intakeStatus: .pendingReview
        )

        XCTAssertEqual(incident.status, .pendingReview)
    }

    func test_logIncident_throwsEmptyContentSubmitted_whenSnippetIsBlank() async {
        let repository = InMemoryIncidentRepository()
        let useCase = LogSuspiciousIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(contentSnippet: "   ", sourceChannel: .email)
            XCTFail("Expected emptyContentSubmitted to be thrown")
        } catch {
            XCTAssertEqual(error as? IncidentLoggingError, .emptyContentSubmitted)
        }
    }

    func test_logIncident_throwsDuplicateIncidentDetected_whenSameContentAlreadyOpen() async throws {
        let existing = SuspiciousIncident.fixture(contentSnippet: "Reset your password now: bit.ly/reset")
        let repository = InMemoryIncidentRepository(seedIncidents: [existing])
        let useCase = LogSuspiciousIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(contentSnippet: "  RESET your PASSWORD now: bit.ly/reset  ", sourceChannel: .email)
            XCTFail("Expected duplicateIncidentDetected to be thrown")
        } catch {
            XCTAssertEqual(error as? IncidentLoggingError, .duplicateIncidentDetected(existingIncidentID: existing.id))
        }
    }

    func test_logIncident_throwsIncidentStoreUnavailable_whenRepositoryFails() async {
        let repository = InMemoryIncidentRepository(mode: .failing(reason: "disk full"))
        let useCase = LogSuspiciousIncidentUseCase(repository: repository)

        do {
            _ = try await useCase.execute(contentSnippet: "Some phishing text", sourceChannel: .email)
            XCTFail("Expected incidentStoreUnavailable to be thrown")
        } catch let error as IncidentLoggingError {
            guard case .incidentStoreUnavailable = error else {
                return XCTFail("Expected incidentStoreUnavailable, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
