import SwiftUI

/// Screen 5 of 5. Closed-out incidents — an audit trail the security contact
/// can check against ("has this sender tried this before, and what did we
/// do last time?").
public struct ResolvedArchiveView: View {
    @State private var viewModel: ResolvedArchiveViewModel

    public init(repository: IncidentRepository) {
        _viewModel = State(initialValue: ResolvedArchiveViewModel(repository: repository))
    }

    public var body: some View {
        Group {
            if viewModel.resolvedIncidents.isEmpty {
                ContentUnavailableView(
                    "No Resolved Incidents Yet",
                    systemImage: "archivebox",
                    description: Text("Incidents you close out will be archived here.")
                )
            } else {
                List(viewModel.resolvedIncidents) { incident in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            SeverityBadge(severity: incident.severity)
                            Text(incident.status.displayLabel).font(.caption).foregroundStyle(.secondary)
                        }
                        Text(incident.contentSnippet).font(.body).lineLimit(2)
                        if let notes = incident.resolutionNotes {
                            Text(notes).font(.footnote).foregroundStyle(.secondary)
                        }
                        if let resolvedAt = incident.resolvedAt {
                            Text("Resolved \(resolvedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Resolved Archive")
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
        .safeAreaInset(edge: .bottom) {
            if let error = viewModel.presentedError {
                ErrorBanner(error: error).padding()
            }
        }
    }
}
