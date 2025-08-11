import SwiftUI

struct ListView: View {

    let category: String
    let stories: [RSSItem]

    var body: some View {
        List {
            Section(header: Text(category)
                .font(.headline)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(Color.mnewsBlue)
                .clipShape(RoundedRectangle(cornerRadius: 6))) {
                    ForEach(stories.filter { $0.categories.contains(category) }) { story in
                        NavigationLink(destination: DigestView(category: category, story: story)) {
                            ListCellView(story: story)
                        }
                    }
                }
        }
    }
}
#Preview {
    ListView(category: "測試", stories: [mockRSS, mockRSS, mockRSS])
}
