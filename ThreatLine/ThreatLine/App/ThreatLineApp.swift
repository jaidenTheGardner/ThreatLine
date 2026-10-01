import SwiftUI

// App entry point. This is the only place that knows the live app uses
// `CoreDataIncidentRepository` pointed at the App Group-shared
// `PersistenceController'.
@main
public struct ThreatLineApp: App {
    private let repository: IncidentRepository = CoreDataIncidentRepository(container: PersistenceController.shared.container)

    // MVP: single stakeholder, so their display name is a fixed setting
    // rather than a full account system.
    private let currentUserName = "Security Contact"

    public init() {}

    public var body: some Scene {
        WindowGroup {
            DashboardView(repository: repository, currentUserName: currentUserName)
        }
    }
}
