import SwiftUI

struct ListCellView: View {

    let story: RSSItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(story.title ?? "")
                .font(.headline)
            if let date = story.date {
                Text(date)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    List {
        ForEach(mockRSS.categories, id: \.self) { category in
            Section(header: Text(category)) {
                NavigationLink(destination: DigestView(category: category, story: mockRSS)) {
                    ListCellView(story: mockRSS)
                }
            }
        }
    }
}
