import SwiftUI
import CachedImage

struct DigestView: View {

    let category: String
    let story: RSSItem

    var body: some View {
        ZStack {
            // background image
            CachedImage(
                url: URL(string: story.imageUrl ?? ""),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .clipped()
                        .overlay {
                            LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                        .opacity(0.4)
                }, placeholder: {
                    ProgressView()
                }
            )

            // foreground
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text(category)
                        .font(.headline)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color.mnewsBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text(story.title ?? "")
                        .font(.headline)
                    if let date = story.date {
                        Text(date)
                            .foregroundStyle(Color.mnewsBlue)
                    }
                    Text(story.digest ?? "")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 5)
            .navigationTitle(category)
        }
    }
}

#Preview {
    DigestView(category: "政治", story: mockRSS)
}
