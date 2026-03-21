import Foundation
import FirebaseFirestore

struct Match: Codable, Identifiable {
    @DocumentID var id: String?
    var tournamentId: String
    var round: Int
    var player1: User?
    var player2: User?
    var player1Score: Int
    var player2Score: Int
    var winner: User?
}
