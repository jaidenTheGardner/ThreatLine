/*
import WidgetKit
import SwiftUI

NOTE: I do not posses my own personal Apple device, and as such I do not have
my own apple ID. This prevented me from implementing the Extensions as they require
an account to code sign. I attempted to create an account but the university MAC computers
prevented me from doing this due to the organisation settings. I have attempted my best to
provide working code but have no means of actually testing it, so the Extension code has
been commented out. Apologies for this inconvenience.

// User scenario this solves: the security contact is mid-meeting and needs
// to know, at a glance and without unlocking their phone, whether
// anything needs urgent attention.
//
// Reads directly from the same App Group-shared Core Data store the main
// app and Share Extension write to. So a report captured on the go shows
// up here on the widget's next refresh. Which the main app and Share
// Extension both trigger explicitly via `WidgetCenter.shared.reloadAllTimelines()`
// after any incident change.
struct IncidentStatusEntry: TimelineEntry {
    let date: Date
    let openIncidentCount: Int
    let breachedCount: Int
    let mostUrgentSnippet: String?
}

struct IncidentStatusProvider: TimelineProvider {
    private var repository: IncidentRepository {
        CoreDataIncidentRepository(container: PersistenceController.shared.container)
    }

    func placeholder(in context: Context) -> IncidentStatusEntry {
        IncidentStatusEntry(date: Date(), openIncidentCount: 2, breachedCount: 1, mostUrgentSnippet: "Suspicious payroll verification email")
    }

    func getSnapshot(in context: Context, completion: @escaping (IncidentStatusEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IncidentStatusEntry>) -> Void) {
        Task {
            let repo = repository
            let identifySLABreaches = IdentifySLABreachedIncidentsUseCase(repository: repo)
            let open = (try? await repo.fetchOpenIncidents()) ?? []
            let breached = (try? await identifySLABreaches.execute()) ?? []
            let mostUrgent = open.min(by: { $0.slaDeadline < $1.slaDeadline })

            let entry = IncidentStatusEntry(
                date: Date(),
                openIncidentCount: open.count,
                breachedCount: breached.count,
                mostUrgentSnippet: mostUrgent?.contentSnippet
            )
            // Refresh again in 15 minutes even with no user action, so SLA
            // countdowns visually age even if nothing new is reported.
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
            completion(timeline)
        }
    }
}

struct ThreatLineWidgetEntryView: View {
    var entry: IncidentStatusProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("\(entry.openIncidentCount)").font(.title3.bold())
                    Text("open").font(.system(size: 9))
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.openIncidentCount) Open Incident\(entry.openIncidentCount == 1 ? "" : "s")")
                    .font(.headline)
                if entry.breachedCount > 0 {
                    Text("\(entry.breachedCount) past SLA").font(.caption).foregroundStyle(.red)
                } else {
                    Text("All within SLA").font(.caption).foregroundStyle(.secondary)
                }
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text("ThreatLine").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text("\(entry.openIncidentCount)").font(.system(size: 34, weight: .bold))
                Text("open incidents").font(.caption)
                if entry.breachedCount > 0 {
                    Label("\(entry.breachedCount) SLA breach\(entry.breachedCount == 1 ? "" : "es")", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                }
                if let snippet = entry.mostUrgentSnippet {
                    Text(snippet).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            .padding()
        }
    }
}

struct ThreatLineWidget: Widget {
    let kind = "ThreatLineIncidentStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IncidentStatusProvider()) { entry in
            ThreatLineWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Incident Status")
        .description("Shows open security incidents and SLA status at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
*/
