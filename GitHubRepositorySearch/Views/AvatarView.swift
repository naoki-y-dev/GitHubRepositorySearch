import SwiftUI

struct AvatarView: View {
    let url: String
    let size: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color(.systemGray5)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
