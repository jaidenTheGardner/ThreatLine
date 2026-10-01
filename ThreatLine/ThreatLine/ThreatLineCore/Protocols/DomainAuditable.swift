import Foundation

/// Describes any domain entity that represents a recorded, attributable event
/// in ThreatLine — used by `TriageAction` so the Incident Detail screen's
/// timeline can render a mixed history purely through this protocol, without
/// knowing the concrete type behind each entry.
public protocol DomainAuditable {
    /// When this event occurred.
    var recordedAt: Date { get }
    /// Who performed it — the security contact's name/handle, since ThreatLine
    /// is a single-person tool and a full identifier type would model a
    /// multi-user need this domain doesn't actually have yet.
    var recordedBy: String { get }
    /// A short, human-readable summary for the triage timeline.
    func auditSummary() -> String
}
