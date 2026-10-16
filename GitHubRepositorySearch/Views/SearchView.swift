import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var favoritesVM: FavoritesViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                if !viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
                    queryBanner
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }

                contentArea
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)

            TextField("Search GitHub repositories...", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { Task { await viewModel.search() } }

            if !viewModel.query.isEmpty {
                Button { viewModel.clearSearch() } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Query Banner

    private var queryBanner: some View {
        HStack {
            Text("Query: ").font(.caption).foregroundColor(.secondary)
            + Text(viewModel.query.trimmingCharacters(in: .whitespaces)).font(.caption.bold())
            Spacer()
            if viewModel.totalCount > 0 {
                Text("\(viewModel.totalCount.formatted()) results")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView("Searching...")
            Spacer()
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if viewModel.repositories.isEmpty && !viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
            emptyResultView
        } else if viewModel.repositories.isEmpty {
            homeContent
        } else {
            repositoryList
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle").font(.system(size: 48)).foregroundStyle(.orange)
            Text(message).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button("Retry") { Task { await viewModel.search() } }.buttonStyle(.bordered)
            Spacer()
        }
        .padding()
    }

    private var emptyResultView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass").font(.system(size: 48)).foregroundStyle(.secondary)
            Text("No results for \"\(viewModel.query)\"").foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Home Content

    private var homeContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "network").font(.system(size: 64)).foregroundColor(.accentColor)
                    Text("GitHub Repo Explorer").font(.title2.bold())
                    Text("Search and like GitHub repositories")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Get started").font(.headline)
                    tipCard(icon: "magnifyingglass", title: "Search repositories",
                            description: "Type a keyword to find repositories on GitHub.",
                            color: Color.accentColor.opacity(0.12))
                    tipCard(icon: "heart", title: "Like your favorites",
                            description: "Tap the heart on any repository to save it.",
                            color: Color.pink.opacity(0.15))
                    tipCard(icon: "info.circle", title: "View details",
                            description: "Tap a repository to see its details and subscriber count.",
                            color: Color.green.opacity(0.12))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
    }

    private func tipCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.title2).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Repository List

    private var repositoryList: some View {
        List {
            ForEach(viewModel.repositories) { repo in
                NavigationLink(destination: RepositoryDetailView(repository: repo)) {
                    RepositoryRowView(
                        repository: repo,
                        isFavorite: favoritesVM.isFavorite(repo),
                        onToggleFavorite: { favoritesVM.toggle(repo) }
                    )
                }
                .onAppear {
                    if repo.id == viewModel.repositories.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .listRowSeparator(.hidden)
            }

            if viewModel.loadMoreFailed {
                HStack {
                    Spacer()
                    Button(action: { Task { await viewModel.loadMore() } }) {
                        Label("読み込み失敗 - 再試行", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
