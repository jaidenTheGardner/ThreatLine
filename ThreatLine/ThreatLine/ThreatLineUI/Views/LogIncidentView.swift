import SwiftUI

/// Screen 2 of 5. Manual incident logging — for when the security contact
/// hears about something over a phone call, in person, or wants to add
/// detail beyond what a quick Share Extension capture provides.
public struct LogIncidentView: View {
    @State private var viewModel: LogIncidentViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var contentSnippet = ""
    @State private var sourceChannel: ReportSourceChannel = .email
    @State private var threatCategory: ThreatCategory = .phishingEmail
    @State private var severity: IncidentSeverity = .medium
    @State private var submitterNote = ""

    public init(repository: IncidentRepository) {
        _viewModel = State(initialValue: LogIncidentViewModel(repository: repository))
    }

    public var body: some View {
        Form {
            Section("What was reported?") {
                TextField("Paste the suspicious message or link", text: $contentSnippet, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Details") {
                Picker("Reported Via", selection: $sourceChannel) {
                    ForEach(ReportSourceChannel.allCases, id: \.self) { Text($0.displayLabel).tag($0) }
                }
                Picker("Suspected Threat", selection: $threatCategory) {
                    ForEach(ThreatCategory.allCases, id: \.self) { Text($0.displayLabel).tag($0) }
                }
                Picker("Severity", selection: $severity) {
                    ForEach(IncidentSeverity.allCases, id: \.self) { Text($0.displayLabel).tag($0) }
                }
                TextField("Who flagged this? (optional)", text: $submitterNote)
            }

            if let error = viewModel.presentedError {
                Section { ErrorBanner(error: error) }
            }

            Section {
                Button {
                    Task {
                        await viewModel.submit(
                            contentSnippet: contentSnippet,
                            sourceChannel: sourceChannel,
                            threatCategory: threatCategory,
                            severity: severity,
                            submitterNote: submitterNote
                        )
                    }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Log Incident").frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isSubmitting)
            }
        }
        .navigationTitle("Log New Incident")
        .onChange(of: viewModel.didLogIncident) { _, didLog in
            if didLog { dismiss() }
        }
    }
}
