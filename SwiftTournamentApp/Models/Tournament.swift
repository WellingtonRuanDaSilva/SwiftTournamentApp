import Foundation
import FirebaseFirestore

struct Tournament: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var contactEmail: String
    var contactType: String
    var startDate: String
    var endDate: String
    var createdAt: Int64
    var createdBy: String

    // Lógica para definir se é Online ou Presencial
    var location: String {
        let onlineTypes = ["discord", "email", "twitter", "whatsapp"]
        return onlineTypes.contains(contactType.lowercased()) ? "Online" : "Local Event"
    }

    var dates: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        guard let start = inputFormatter.date(from: startDate),
              let end = inputFormatter.date(from: endDate) else {
            return "\(startDate) - \(endDate)"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd"
        outputFormatter.locale = Locale(identifier: "en_US")

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"

        let startYear = yearFormatter.string(from: start)
        let endYear = yearFormatter.string(from: end)

        if startYear == endYear {
            return "\(outputFormatter.string(from: start)) — \(outputFormatter.string(from: end)), \(startYear)"
        } else {
            return "\(outputFormatter.string(from: start)), \(startYear) — \(outputFormatter.string(from: end)), \(endYear)"
        }
    }
}
