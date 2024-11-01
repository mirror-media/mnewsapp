import Foundation

struct RSSItem: Decodable, Identifiable {
    var id: String?
    var title: String?
    var description: String?
    var category: String?
    var pubDate: String?
    var imageUrl: String?

    var date: String? {
        if let pubDate = pubDate {
            return formatDate(dateString: pubDate)
        } else {
            return nil
        }
    }

    var digest: String? {
        guard let description = description else { return nil }

        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
            let range = NSRange(location: 0, length: description.utf16.count)
            let cleanedDescription = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "")

            return cleanedDescription.isEmpty ? nil : cleanedDescription
        } catch {
            print("Error parsing description: \(error)")
            return nil
        }
    }
}

class RSSParser: NSObject, XMLParserDelegate {

    var items: [RSSItem] = []
    var currentItem: RSSItem?
    var currentElement: String?
    var currentContent: String = ""

    func parse(from url: URL, completion: @escaping ([RSSItem]) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion([])
                return
            }

            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            completion(self.items)
        }.resume()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentItem = RSSItem()
        }
        if (elementName == "media:content" || elementName == "enclosure"), let url = attributeDict["url"] {
            currentItem?.imageUrl = url
        }
        currentContent = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if ["title", "description", "category", "pubDate"].contains(currentElement) {
            currentContent += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item", let currentItem = currentItem {
            let uuid = UUID().uuidString
            self.items.append(RSSItem(id: uuid, title: currentItem.title, description: currentItem.description, category: currentItem.category, pubDate: currentItem.pubDate, imageUrl: currentItem.imageUrl))
            self.currentItem = nil
        }

        switch elementName {
            case "title":
                currentItem?.title = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
            case "description":
                currentItem?.description = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
            case "category":
                currentItem?.category = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
            case "pubDate":
                currentItem?.pubDate = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
        }

        currentContent = ""
    }
}
