import SwiftUI

/// Screen 1 of 5. The security contact's home screen: every incident still
/// being actively tracked against its SLA, most urgent first. This is what
/// they check first thing, and what the widget mirrors a summary of.
public struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    let repository: IncidentRepository
    let currentUserName: String

    public init(repository: IncidentRepository, currentUserName: String) {
        self.repository = repository
        self.currentUserName = currentUserName
        _viewModel = State(initialValue: DashboardViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.openIncidents.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Open Incidents",
                        systemImage: "checkmark.shield",
                        description: Text("Nothing is currently being tracked. New reports will appear here.")
                    )
                } else {
                    List(viewModel.openIncidents) { incident in
                        NavigationLink {
                            IncidentDetailView(
                                viewModel: IncidentDetailViewModel(incident: incident, repository: repository),
                                currentUserName: currentUserName
                            )
                        } label: {
                            row(for: incident)
                        }
                    }
                }
            }
            .navigationTitle("Open Incidents")
            .toolbar {
                ToolbarItem() {
                    Menu {
                        NavigationLink("Log New Incident") {
                            LogIncidentView(repository: repository)
                        }
                        NavigationLink("Pending Shared Reports") {
                            PendingReportsView(repository: repository, currentUserName: currentUserName)
                        }
                        NavigationLink("Resolved Archive") {
                            ResolvedArchiveView(repository: repository)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .task { await viewModel.refresh() }
            .refreshable { await viewModel.refresh() }
            .safeAreaInset(edge: .bottom) {
                if let error = viewModel.presentedError {
                    ErrorBanner(error: error).padding()
                }
            }
        }
    }

    @ViewBuilder
    private func row(for incident: SuspiciousIncident) -> some View {
        let isBreached = viewModel.breachedIncidentIDs.contains(incident.id)
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                SeverityBadge(severity: incident.severity)
                Text(incident.threatCategory.displayLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if isBreached {
                    Label("SLA Breached", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }
            Text(incident.contentSnippet)
                .font(.body)
                .lineLimit(2)
            Text("via \(incident.sourceChannel.displayLabel) · \(incident.reportedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
