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
        ForEach([mockRSS]) { story in
            NavigationLink(destination: DigestView(category: "測試", story: story)) {
                ListCellView(story: story)
            }
        }
    }
}
