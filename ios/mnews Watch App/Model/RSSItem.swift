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
        let pattern = "<[^>]+>(.*?)</[^>]+>"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: description!.utf16.count)
        let descriptionWithoutPTags = regex.stringByReplacingMatches(in: description!, options: [], range: range, withTemplate: "$1")
        if !descriptionWithoutPTags.isEmpty {
            return descriptionWithoutPTags
        } else {
            return nil
        }
    }
}

class RSSParser: NSObject, XMLParserDelegate {

    var items: [RSSItem] = []
    var currentItem: RSSItem?
    var currentElement: String?

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

        if elementName == "media:content", let url = attributeDict["url"] {
            currentItem?.imageUrl = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title":
                guard currentItem?.title != nil else {
                    currentItem?.title = string
                    return
                }

            case "description":
                guard currentItem?.description != nil else {
                    currentItem?.description = string
                    return
                }

            case "category":
                guard currentItem?.category != nil else {
                    currentItem?.category = string
                    return
                }

            case "pubDate":
                guard currentItem?.pubDate != nil else {
                    currentItem?.pubDate = string
                    return
                }

            default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item", let currentItem = currentItem {
            let uuid = UUID().uuidString
            self.items.append(RSSItem(id: uuid, title: currentItem.title, description: currentItem.description, category: currentItem.category, pubDate: currentItem.pubDate, imageUrl: currentItem.imageUrl))
            self.currentItem = nil
        }
    }
}
