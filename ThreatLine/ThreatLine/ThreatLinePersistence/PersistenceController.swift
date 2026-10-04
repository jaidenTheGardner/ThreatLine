import CoreData

// Owns the `NSPersistentContainer` , which theoretically lets the 
// share-sheet capture show up instantly in the main app's lists and in the
// widget's next refresh, without any networking or manual hand-off file.
public final class PersistenceController {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    // - Parameter inMemory: `true` for SwiftUI previews/unit tests that want
    //   a real Core Data stack without touching disk. Production code (app,
    //   widget, share extension) always uses `false`.
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ThreatLine")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } /*else if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier) {
            let storeURL = appGroupURL.appendingPathComponent("ThreatLine.sqlite")
            container.persistentStoreDescriptions.first?.url = storeURL
        } else {
            // Falls back to the default (non-shared) location. If this ever
            // happens in production it means the App Group capability isn't
            // configured on this target. The app still works for that target
            // alone; it just won't share data with the widget/share extension
            // until the capability is fixed.
            assertionFailure("App Group container unavailable — check the App Group capability on this target.")
        }

        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
*/
        container.loadPersistentStores { _, error in
            if let error {
                // A launch-time failure here is unrecoverable for this session
                fatalError("ThreatLine could not load its incident store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
