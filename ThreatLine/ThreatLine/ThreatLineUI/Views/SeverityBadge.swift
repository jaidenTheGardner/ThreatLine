import SwiftUI

extension IncidentSeverity {
    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

extension SLAStatus {
    var color: Color {
        switch self {
        case .onTrack: return .green
        case .dueSoon: return .orange
        case .breached: return .red
        }
    }
}

/// A small pill showing an incident's severity — reused across the
/// dashboard, pending reports, and detail screens so severity always reads
/// the same way.
struct SeverityBadge: View {
    let severity: IncidentSeverity

    var body: some View {
        Text(severity.displayLabel)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(severity.color.opacity(0.18), in: Capsule())
            .foregroundStyle(severity.color)
    }
}
