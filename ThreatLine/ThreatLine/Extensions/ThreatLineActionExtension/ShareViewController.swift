/* import UIKit
import UniformTypeIdentifiers
import WidgetKit
 
 NOTE: I do not posses my own personal Apple device, and as such I do not have
 my own apple ID. This prevented me from implementing the Extensions as they require
 an account to code sign. I attempted to create an account but the university MAC computers
 prevented me from doing this due to the organisation settings. I have attempted my best to
 provide working code but have no means of actually testing it, so the Extension code has
 been commented out. Apologies for this inconvenience.

// User scenario this solves: The security contact is reading a phishing
// email in Mail; logging it means alt-tabbing to a notes app and typing it up from
// memory, leading to lapses in memory. This is friction at the wrong moment.
// This extension lets them tap Share → ThreatLine and have it logged with
// the actual content, in two taps, without leaving the app they're already in.
//
// Writes straight into the App Group-shared Core Data store via the same
// `LogSuspiciousIncidentUseCase` and `IncidentRepository` the main app uses.
// Since the extension has no UI of its own to ask for severity/threat category; the
// security contact fills that in on the "Pending Shared Reports" screen.
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        handleSharedItem()
    }

    private func handleSharedItem() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            completeRequest()
            return
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                let text = (data as? URL)?.absoluteString ?? ""
                self?.logIncident(from: text)
            }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                let text = (data as? String) ?? ""
                self?.logIncident(from: text)
            }
        } else {
            completeRequest()
        }
    }

    private func logIncident(from content: String) {
        Task {
            let repository = CoreDataIncidentRepository(container: PersistenceController.shared.container)
            let logIncident = LogSuspiciousIncidentUseCase(repository: repository)
            do {
                _ = try await logIncident.execute(
                    contentSnippet: content,
                    sourceChannel: .other,
                    submitterNote: "Captured via Share Sheet",
                    intakeStatus: .pendingReview
                )
                // So the widget and dashboard reflect this the moment the
                // security contact next glances at either. A duplicate is
                // treated the same way as success here.
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                // Deliberately swallowed: A share extension has no good place
                // to show the domain-facing error banner the main app would.
            }
            await MainActor.run { self.completeRequest() }
        }
    }

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
*/
