import SwiftUI

struct RootView: View {
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
        .environmentObject(favoritesViewModel)
    }
}
