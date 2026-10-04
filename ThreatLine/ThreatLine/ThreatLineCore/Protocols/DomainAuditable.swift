import Foundation

// Describes any domain entity that represents a recorded, attributable event.
// Used by `TriageAction` so the Incident Detail screen's timeline can render
// a mixed history purely through this protocol, without knowing the concrete
// type behind each entry.
public protocol DomainAuditable {
    // When this event occurred.
    var recordedAt: Date { get }
    // Who performed it
    var recordedBy: String { get }
    // A short, human-readable summary for the triage timeline.
    func auditSummary() -> String
}
