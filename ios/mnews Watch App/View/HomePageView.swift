import SwiftUI
import CachedImage

struct HomePageView: View {
    let category: String
    let stories: [RSSItem]
    @State private var backgroundImage: Image? = nil

    var body: some View {
        ZStack {
            CachedImage(
                url: URL(string: stories.first?.imageUrl ?? ""),
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
            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                Text(category)
                    .font(.headline)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(Color.mnewsBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(stories.first?.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                if let date = stories.first?.date {
                    Text(date)
                        .foregroundStyle(Color.mnewsYellow)
                }
                NavigationLink {
                    ListView(category: category, stories: stories)
                        .navigationTitle(category)
                } label: {
                    Text("更多" + category)
                }
                .controlSize(.small)
                .buttonStyle(BorderedProminentButtonStyle())
                .buttonBorderShape(.roundedRectangle(radius: 13.0))
                .tint(Color.mnewsBlue)
            }
            .padding(4)
        }
    }
}

#Preview {
    TabView {
        HomePageView(category: "測試", stories: [mockRSS])
    }
    .navigationTitle("鏡新聞")
}
