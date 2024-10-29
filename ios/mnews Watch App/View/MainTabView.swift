import SwiftUI

struct MainTabView: View {
    @State private var rssItems: [RSSItem] = []

    let categoryOrder = ["影音", "政治", "國際", "財經", "社會", "生活", "內幕", "娛樂", "體育", "地方"]

    var body: some View {
        TabView {
            ForEach(categoryOrder, id: \.self) { category in
                if let item = firstArticle(for: category) {
                    VStack {
                        Text(item.title ?? "No Title")
                            .font(.headline)
                            .padding()

                        Text(item.category ?? "No Category")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .tag(category)
                }
            }
        }
        .onAppear(perform: loadRSS)
    }

    func loadRSS() {
        guard let storyURL = URL(string: Bundle.main.infoDictionary?["storyURL"] as! String) else { return }

        let parser = RSSParser()
        parser.parse(from: storyURL) { items in
            DispatchQueue.main.async {
                self.rssItems = items
            }
        }
    }

    func firstArticle(for category: String) -> RSSItem? {
        return rssItems.first { $0.category == category }
    }
}
#Preview {
    MainTabView()
}
