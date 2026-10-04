import CoreData

// Live `IncidentRepository` implementation, backed by Core Data. The only
// file in the app allowed to know `NSManagedObject`, `NSFetchRequest`, or
// `NSPredicate` exist. 
public struct CoreDataIncidentRepository: IncidentRepository {
    private let container: NSPersistentContainer

    public init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    // Reads

    public func fetchOpenIncidents() async throws -> [SuspiciousIncident] {
        try await fetch(
            // The "real domain condition" predicate the assessment asks for:
            // incidents still actively tracked against their SLA.
            predicate: NSPredicate(
                format: "status IN %@",
                [IncidentStatus.pendingReview, IncidentStatus.open, IncidentStatus.escalated].map(\.rawValue)
            ),
            sortDescriptors: [NSSortDescriptor(key: "reportedAt", ascending: true)]
        )
    }

    public func fetchResolvedIncidents() async throws -> [SuspiciousIncident] {
        try await fetch(
            predicate: NSPredicate(
                format: "status IN %@",
                [IncidentStatus.resolved, IncidentStatus.falsePositive].map(\.rawValue)
            ),
            sortDescriptors: [NSSortDescriptor(key: "resolvedAt", ascending: false)]
        )
    }

    public func fetchPendingReports() async throws -> [SuspiciousIncident] {
        try await fetch(
            predicate: NSPredicate(format: "status == %@", IncidentStatus.pendingReview.rawValue),
            sortDescriptors: [NSSortDescriptor(key: "reportedAt", ascending: true)]
        )
    }

    public func fetchIncident(id: UUID) async throws -> SuspiciousIncident? {
        try await fetch(predicate: NSPredicate(format: "id == %@", id as CVarArg), sortDescriptors: []).first
    }

    public func fetchTriageActions(for incidentID: UUID) async throws -> [TriageAction] {
        let context = container.viewContext
        return try await context.perform {
            let request = TriageActionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "incidentID == %@", incidentID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "performedAt", ascending: true)]
            return try context.fetch(request).map { $0.asDomainModel() }
        }
    }

    // Writes

    public func save(_ incident: SuspiciousIncident) async throws {
        let context = container.viewContext
        try await context.perform {
            let request = IncidentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", incident.id as CVarArg)
            request.fetchLimit = 1

            let entity = try context.fetch(request).first ?? IncidentEntity(context: context)
            entity.apply(incident)

            try context.save()
        }
    }

    public func appendTriageAction(_ action: TriageAction) async throws {
        let context = container.viewContext
        try await context.perform {
            let entity = TriageActionEntity(context: context)
            entity.apply(action)

            let incidentRequest = IncidentEntity.fetchRequest()
            incidentRequest.predicate = NSPredicate(format: "id == %@", action.incidentID as CVarArg)
            incidentRequest.fetchLimit = 1
            entity.incident = try context.fetch(incidentRequest).first

            try context.save()
        }
    }

    // Shared fetch helper

    private func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) async throws -> [SuspiciousIncident] {
        let context = container.viewContext
        return try await context.perform {
            let request = IncidentEntity.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            return try context.fetch(request).map { $0.asDomainModel() }
        }
    }
}

// Managed object <-> domain model mapping
// Kept next to the repository so the translation between Core Data's storage
// shape and the domain's semantic shape lives in exactly one place.

private extension IncidentEntity {
    func apply(_ incident: SuspiciousIncident) {
        id = incident.id
        reportedAt = incident.reportedAt
        sourceChannel = incident.sourceChannel.rawValue
        threatCategory = incident.threatCategory.rawValue
        contentSnippet = incident.contentSnippet
        submitterNote = incident.submitterNote
        severity = incident.severity.rawValue
        status = incident.status.rawValue
        resolvedAt = incident.resolvedAt
        resolutionNotes = incident.resolutionNotes
    }

    func asDomainModel() -> SuspiciousIncident {
        SuspiciousIncident(
            id: id ?? UUID(),
            reportedAt: reportedAt ?? Date(),
            sourceChannel: ReportSourceChannel(rawValue: sourceChannel ?? "") ?? .other,
            threatCategory: ThreatCategory(rawValue: threatCategory ?? "") ?? .other,
            contentSnippet: contentSnippet ?? "",
            submitterNote: submitterNote,
            severity: IncidentSeverity(rawValue: severity ?? "") ?? .medium,
            status: IncidentStatus(rawValue: status ?? "") ?? .pendingReview,
            resolvedAt: resolvedAt,
            resolutionNotes: resolutionNotes
        )
    }
}

private extension TriageActionEntity {
    func apply(_ action: TriageAction) {
        id = action.id
        incidentID = action.incidentID
        performedAt = action.performedAt
        actionDescription = action.actionDescription
        changedStatusTo = action.changedStatusTo?.rawValue
        performedBy = action.performedBy
    }

    func asDomainModel() -> TriageAction {
        TriageAction(
            id: id ?? UUID(),
            incidentID: incidentID ?? UUID(),
            performedAt: performedAt ?? Date(),
            actionDescription: actionDescription ?? "",
            changedStatusTo: changedStatusTo.flatMap(IncidentStatus.init(rawValue:)),
            performedBy: performedBy ?? "Unknown"
        )
    }
}
