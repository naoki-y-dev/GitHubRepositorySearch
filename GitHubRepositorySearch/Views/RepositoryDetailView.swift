import SwiftUI

struct RepositoryDetailView: View {
    @StateObject private var viewModel: RepositoryDetailViewModel
    @EnvironmentObject private var favoritesVM: FavoritesViewModel
    @Environment(\.openURL) private var openURL
    @State private var likeScale: CGFloat = 1.0

    private var isFavorite: Bool { favoritesVM.isFavorite(viewModel.displayRepo) }

    init(repository: Repository) {
        _viewModel = StateObject(wrappedValue: RepositoryDetailViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AvatarView(url: viewModel.displayRepo.avatarUrl, size: 96)
                    .padding(.top, 24)

                Text(viewModel.displayRepo.fullName)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let description = viewModel.displayRepo.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    statsGrid
                }

                if let url = URL(string: viewModel.displayRepo.htmlUrl) {
                    Button(action: { openURL(url) }) {
                        Label("View on GitHub", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(viewModel.displayRepo.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: handleLike) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .pink : .primary)
                        .scaleEffect(likeScale)
                }
            }
        }
        .task { await viewModel.load() }
    }

    private func handleLike() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        favoritesVM.toggle(viewModel.displayRepo)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            likeScale = 1.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                likeScale = 1.0
            }
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 0) {
            statCell(value: viewModel.displayRepo.stargazersCount.formatted(),
                     label: "Stars", icon: "star.fill", color: .yellow)
            Divider().frame(height: 40)
            statCell(value: viewModel.displayRepo.subscribersCount?.formatted() ?? "-",
                     label: "Subscribers", icon: "eye.fill", color: .blue)
            if let language = viewModel.displayRepo.language {
                Divider().frame(height: 40)
                statCell(value: language, label: "Language",
                         icon: "chevron.left.forwardslash.chevron.right", color: .green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.subheadline.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
