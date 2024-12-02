import SwiftUI

struct MainTabView: View {
    @State private var rssItems: [RSSItem] = []
    @State private var isLoading = true
    @State private var uniqueStoriesByCategory: [String: RSSItem] = [:]

    let categoryOrder = ["影音", "政治", "國際", "財經", "社會", "生活", "內幕", "娛樂", "體育", "地方"]

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("正在載入新聞...")
            } else {
                TabView {
                    ForEach(categoryOrder, id: \.self) { category in
                        let allStories = stories(for: category)
                        if let firstStory = uniqueStoriesByCategory[category] {
                            HomePageView(category: category, stories: allStories, highlightedStory: firstStory)
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
                self.uniqueStoriesByCategory = getUniqueStoriesByCategory()
            }
        }
    }

    // 避免首頁不同類別顯示重複文章
    func getUniqueStoriesByCategory() -> [String: RSSItem] {
        var uniqueStories: [String: RSSItem] = [:]
        var displayedStoryIDs = Set<String>()

        for category in categoryOrder {
            let categoryStories = rssItems.filter { $0.categories.contains(category) }
            for story in categoryStories {
                if let id = story.id, !displayedStoryIDs.contains(id) {
                    uniqueStories[category] = story
                    displayedStoryIDs.insert(id)
                    break
                }
            }
        }

        return uniqueStories
    }

    func stories(for category: String) -> [RSSItem] {
        return rssItems.filter { $0.categories.contains(category) }
    }
}

#Preview {
    MainTabView()
}
