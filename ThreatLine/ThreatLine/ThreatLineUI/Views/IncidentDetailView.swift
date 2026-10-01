import SwiftUI

/// Screen 4 of 5. Full detail for one incident plus its triage timeline
/// (rendered purely through `DomainAuditable`), and the actions available
/// from its current status.
public struct IncidentDetailView: View {
    @Bindable var viewModel: IncidentDetailViewModel
    let currentUserName: String

    @State private var showResolutionSheet = false
    @State private var pendingStatus: IncidentStatus?
    @State private var resolutionNotes = ""

    public init(viewModel: IncidentDetailViewModel, currentUserName: String) {
        self.viewModel = viewModel
        self.currentUserName = currentUserName
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SeverityBadge(severity: viewModel.incident.severity)
                    Text(viewModel.incident.status.displayLabel)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.secondary.opacity(0.15), in: Capsule())
                }

                Text(viewModel.incident.contentSnippet)
                    .font(.body)
                    .textSelection(.enabled)

                if let note = viewModel.incident.submitterNote {
                    Text(note).font(.footnote).foregroundStyle(.secondary)
                }

                Divider()

                Text("Triage Timeline").font(.headline)
                if viewModel.timeline.isEmpty {
                    Text("No triage actions recorded yet.").font(.footnote).foregroundStyle(.secondary)
                } else {
                    ForEach(Array(viewModel.timeline.enumerated()), id: \.offset) { _, entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.auditSummary()).font(.subheadline)
                            Text("\(entry.recordedBy) · \(entry.recordedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = viewModel.presentedError {
                    ErrorBanner(error: error)
                }

                actionButtons
            }
            .padding()
        }
        .navigationTitle("Incident Detail")
        .task { await viewModel.loadTimeline() }
        .sheet(isPresented: $showResolutionSheet) {
            NavigationStack {
                Form {
                    TextField("What happened / how was this handled?", text: $resolutionNotes, axis: .vertical)
                }
                .navigationTitle(pendingStatus == .falsePositive ? "Mark False Positive" : "Resolve Incident")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") {
                            guard let status = pendingStatus else { return }
                            Task {
                                await viewModel.updateStatus(to: status, resolutionNotes: resolutionNotes, performedBy: currentUserName)
                                showResolutionSheet = false
                                resolutionNotes = ""
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showResolutionSheet = false }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        switch viewModel.incident.status {
        case .pendingReview:
            Text("Promote this from the Pending Shared Reports screen before it can be escalated or resolved.")
                .font(.footnote).foregroundStyle(.secondary)
        case .open:
            Button("Escalate") {
                Task { await viewModel.updateStatus(to: .escalated, resolutionNotes: nil, performedBy: currentUserName) }
            }
            .buttonStyle(.bordered)
            Button("Resolve") { pendingStatus = .resolved; showResolutionSheet = true }
                .buttonStyle(.borderedProminent)
        case .escalated:
            Button("Resolve") { pendingStatus = .resolved; showResolutionSheet = true }
                .buttonStyle(.borderedProminent)
        case .resolved, .falsePositive:
            Text("This incident is closed.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}
