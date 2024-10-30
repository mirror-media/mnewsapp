import SwiftUI

struct MainTabView: View {
    @State private var rssItems: [RSSItem] = []

    let categoryOrder = ["影音", "政治", "國際", "財經", "社會", "生活", "內幕", "娛樂", "體育", "地方"]

    var body: some View {
        TabView {
            ForEach(categoryOrder, id: \.self) { category in
                if let stories = stories(for: category) {
                    HomePageView(category: category, stories: stories)
                        .tabItem {
                            Text(category)
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

    func stories(for category: String) -> [RSSItem]? {
        let filteredStories = rssItems.filter { $0.category == category }
        return filteredStories.isEmpty ? nil : filteredStories
    }
}
#Preview {
    MainTabView()
}
