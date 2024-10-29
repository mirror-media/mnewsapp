
import Foundation

func formatDate(dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // Input format

    if let date = dateFormatter.date(from: dateString) {
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm" // Output format
        return dateFormatter.string(from: date)
    } else {
        return "Invalid Date"
    }
}
