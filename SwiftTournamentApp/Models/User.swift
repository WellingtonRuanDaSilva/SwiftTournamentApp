import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String? // Mapeia o ID do documento automaticamente
    var email: String
    var birthday: String
    var country: String
    var marketingConsent: Bool
    var termsAccepted: Bool
    var createdAt: Int64
}
