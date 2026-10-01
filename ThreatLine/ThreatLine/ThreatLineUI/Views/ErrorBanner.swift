import SwiftUI

/// Renders a `LocalizedError`'s message and recovery suggestion in a calm,
/// domain-appropriate banner — never a raw technical error to the security
/// contact.
struct ErrorBanner: View {
    let error: LocalizedError

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(error.errorDescription ?? "Something needs your attention.", systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline.weight(.semibold))
            if let recovery = error.recoverySuggestion {
                Text(recovery)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
    }
}
