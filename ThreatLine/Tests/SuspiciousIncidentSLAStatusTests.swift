
import XCTest
@testable import ThreatLine

final class SuspiciousIncidentSLAStatusTests: XCTestCase {

    func test_slaStatus_isOnTrack_wellWithinWindow() {
        let now = Date()
        let incident = SuspiciousIncident.fixture(reportedAt: now, severity: .high, status: .open) // 4h window

        XCTAssertEqual(incident.slaStatus(asOf: now.addingTimeInterval(60 * 60)), .onTrack) // 1h in
    }

    func test_slaStatus_isDueSoon_insideFinalQuarterOfWindow() {
        let now = Date()
        let incident = SuspiciousIncident.fixture(reportedAt: now, severity: .high, status: .open) // 4h window, last 1h is "due soon"

        XCTAssertEqual(incident.slaStatus(asOf: now.addingTimeInterval(3.5 * 60 * 60)), .dueSoon)
    }

    func test_slaStatus_isBreached_exactlyAtDeadline() {
        let now = Date()
        let incident = SuspiciousIncident.fixture(reportedAt: now, severity: .high, status: .open)

        XCTAssertEqual(incident.slaStatus(asOf: now.addingTimeInterval(4 * 60 * 60)), .breached)
    }

    func test_slaStatus_isOnTrack_forResolvedIncidents_regardlessOfAge() {
        let now = Date()
        let incident = SuspiciousIncident.fixture(
            reportedAt: now.addingTimeInterval(-100 * 60 * 60),
            severity: .critical,
            status: .resolved
        )

        XCTAssertEqual(incident.slaStatus(asOf: now), .onTrack)
    }

}
