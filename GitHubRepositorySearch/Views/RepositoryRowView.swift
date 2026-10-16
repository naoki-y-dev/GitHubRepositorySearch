import SwiftUI

struct RepositoryRowView: View {
    let repository: Repository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(url: repository.avatarUrl, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(repository.fullName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onToggleFavorite()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .pink : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
