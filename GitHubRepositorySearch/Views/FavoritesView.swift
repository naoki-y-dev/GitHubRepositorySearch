import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favoritesVM: FavoritesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if favoritesVM.favorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart").font(.system(size: 64)).foregroundStyle(.secondary)
            Text("No liked repositories").foregroundStyle(.secondary)
        }
    }

    private var favoritesList: some View {
        List {
            ForEach(favoritesVM.favorites) { repo in
                NavigationLink(destination: RepositoryDetailView(repository: repo)) {
                    RepositoryRowView(
                        repository: repo,
                        isFavorite: true,
                        onToggleFavorite: { favoritesVM.toggle(repo) }
                    )
                }
            }
        }
        .listStyle(.plain)
    }
}
