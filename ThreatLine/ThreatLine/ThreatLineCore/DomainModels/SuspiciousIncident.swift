import Foundation

// The SLA state of a `SuspiciousIncident` at a given moment.
public enum SLAStatus: String, Sendable {
    case onTrack
    case dueSoon
    case breached
}

// Represents one suspected security threat reported to the security contact
// and its full triage lifecycle.
//
// Business Rule: Only `.pendingReview` or `.open` are valid starting statuses
// From there, `TriageIncidentUseCase` is the only path that may change `status`,
// so every transition passes through one place that can enforce the lifecycle rules.
//
// Modelled as a `struct`: each incident is persisted via `IncidentRepository.
public struct SuspiciousIncident: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let reportedAt: Date
    public let sourceChannel: ReportSourceChannel
    public var threatCategory: ThreatCategory
    public var contentSnippet: String
    public var submitterNote: String?
    public var severity: IncidentSeverity
    public var status: IncidentStatus
    public var resolvedAt: Date?
    public var resolutionNotes: String?

    public init(
        id: UUID,
        reportedAt: Date,
        sourceChannel: ReportSourceChannel,
        threatCategory: ThreatCategory,
        contentSnippet: String,
        submitterNote: String?,
        severity: IncidentSeverity,
        status: IncidentStatus,
        resolvedAt: Date? = nil,
        resolutionNotes: String? = nil
    ) {
        self.id = id
        self.reportedAt = reportedAt
        self.sourceChannel = sourceChannel
        self.threatCategory = threatCategory
        self.contentSnippet = contentSnippet
        self.submitterNote = submitterNote
        self.severity = severity
        self.status = status
        self.resolvedAt = resolvedAt
        self.resolutionNotes = resolutionNotes
    }

    // The point at which this incident's severity-based response window
    // expires, per `IncidentSeverity.responseWindow`.
    public var slaDeadline: Date { reportedAt.addingTimeInterval(severity.responseWindow) }

    // Evaluates SLA state at a given moment. Takes `now` as a parameter
    // (rather than reading `Date()` internally) so this pure domain rule is
    // unit-testable at exact boundary conditions.
    public func slaStatus(asOf now: Date = Date()) -> SLAStatus {
        guard status.countsTowardSLA else { return .onTrack }
        let remaining = slaDeadline.timeIntervalSince(now)
        if remaining <= 0 { return .breached }
        if remaining < severity.responseWindow * 0.25 { return .dueSoon }
        return .onTrack
    }
}
