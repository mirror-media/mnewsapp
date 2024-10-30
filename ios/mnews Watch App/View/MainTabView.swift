import SwiftUI

struct MainTabView: View {
    @State private var rssItems: [RSSItem] = []
    @State private var isLoading = true

    let categoryOrder = ["影音", "政治", "國際", "財經", "社會", "生活", "內幕", "娛樂", "體育", "地方"]

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("正在載入新聞...")
            } else {
                TabView {
                    ForEach(categoryOrder, id: \.self) { category in
                        if let stories = stories(for: category) {
                            HomePageView(category: category, stories: stories)
                        }
                    }
                }
                .navigationTitle("鏡新聞")
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
                isLoading = false
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