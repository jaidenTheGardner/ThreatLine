import SwiftUI

/// Screen 3 of 5. Items captured in a couple of taps via the Share Extension
/// — the security contact reviews each one here, assigns a real severity
/// and threat category, and promotes it into a tracked open incident (or
/// dismisses it as a false positive).
public struct PendingReportsView: View {
    @State private var viewModel: PendingReportsViewModel
    let currentUserName: String

    public init(repository: IncidentRepository, currentUserName: String) {
        self.currentUserName = currentUserName
        _viewModel = State(initialValue: PendingReportsViewModel(repository: repository))
    }

    public var body: some View {
        Group {
            if viewModel.pendingReports.isEmpty {
                ContentUnavailableView(
                    "No Pending Reports",
                    systemImage: "tray",
                    description: Text("Items you share into ThreatLine from Mail, Messages, or Safari will appear here first.")
                )
            } else {
                List(viewModel.pendingReports) { report in
                    PendingReportRow(report: report, viewModel: viewModel, currentUserName: currentUserName)
                }
            }
        }
        .navigationTitle("Pending Shared Reports")
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
        .safeAreaInset(edge: .bottom) {
            if let error = viewModel.presentedError {
                ErrorBanner(error: error).padding()
            }
        }
    }
}

private struct PendingReportRow: View {
    let report: SuspiciousIncident
    let viewModel: PendingReportsViewModel
    let currentUserName: String

    @State private var severity: IncidentSeverity = .medium
    @State private var threatCategory: ThreatCategory = .other
    @State private var showFalsePositiveSheet = false
    @State private var falsePositiveNotes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.contentSnippet).font(.body).lineLimit(3)
            Text("Captured \(report.reportedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2).foregroundStyle(.secondary)

            Picker("Severity", selection: $severity) {
                ForEach(IncidentSeverity.allCases, id: \.self) { Text($0.displayLabel).tag($0) }
            }
            Picker("Threat Type", selection: $threatCategory) {
                ForEach(ThreatCategory.allCases, id: \.self) { Text($0.displayLabel).tag($0) }
            }

            HStack {
                Button("Promote to Open Incident") {
                    Task {
                        await viewModel.promote(
                            incidentID: report.id,
                            severity: severity,
                            threatCategory: threatCategory,
                            performedBy: currentUserName
                        )
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Not a Threat", role: .destructive) { showFalsePositiveSheet = true }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $showFalsePositiveSheet) {
            NavigationStack {
                Form {
                    TextField("Why isn't this a threat?", text: $falsePositiveNotes, axis: .vertical)
                }
                .navigationTitle("Dismiss Report")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") {
                            Task {
                                await viewModel.dismissAsFalsePositive(
                                    incidentID: report.id,
                                    notes: falsePositiveNotes,
                                    performedBy: currentUserName
                                )
                                showFalsePositiveSheet = false
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showFalsePositiveSheet = false }
                    }
                }
            }
        }
    }
}
