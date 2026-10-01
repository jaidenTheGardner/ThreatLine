import SwiftUI

/// App entry point. This is the one place that knows the live app uses
/// `CoreDataIncidentRepository` pointed at the App Group-shared
/// `PersistenceController` — every layer beneath it only ever sees the
/// `IncidentRepository` protocol.
@main
public struct ThreatLineApp: App {
    private let repository: IncidentRepository = CoreDataIncidentRepository(container: PersistenceController.shared.container)

    // MVP: single stakeholder, so their display name is a fixed setting
    // rather than a full account system — matches the "don't model a
    // multi-user need this domain doesn't have" principle from the domain
    // layer's `DomainAuditable` docs.
    private let currentUserName = "Security Contact"

    public init() {}

    public var body: some Scene {
        WindowGroup {
            DashboardView(repository: repository, currentUserName: currentUserName)
        }
    }
}
