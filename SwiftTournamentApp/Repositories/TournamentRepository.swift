import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Combine

class TournamentRepository: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Criar Torneio
    func createTournament(_ tournament: Tournament) async throws -> String {
        let ref = try db.collection("tournaments").addDocument(from: tournament)
        return ref.documentID
    }
    
    // MARK: - Buscar Todos
    func getAllTournaments() async throws -> [Tournament] {
        let snapshot = try await db.collection("tournaments")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Tournament.self) }
    }
    
    // MARK: - Buscar por Usuário (Opcional, mas útil)
    func getTournamentsByUser(email: String) async throws -> [Tournament] {
        let snapshot = try await db.collection("tournaments")
            .whereField("createdBy", isEqualTo: email)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Tournament.self) }
    }
    
    // MARK: - Inscrição
    func subscribe(tournamentId: String, user: User, userId: String) async throws {
        try db.collection("tournaments").document(tournamentId)
            .collection("subscribers").document(userId).setData(from: user)
    }
    
    func unsubscribe(tournamentId: String, userId: String) async throws {
        try await db.collection("tournaments").document(tournamentId)
            .collection("subscribers").document(userId).delete()
    }
    
    func isSubscribed(tournamentId: String, userId: String) async throws -> Bool {
        let doc = try await db.collection("tournaments").document(tournamentId)
            .collection("subscribers").document(userId).getDocument()
        return doc.exists
    }
    
    func getSubscribers(tournamentId: String) async throws -> [User] {
        let snapshot = try await db.collection("tournaments").document(tournamentId)
            .collection("subscribers").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    // MARK: - Gerar Chaves (Bracket)
    func generateBracket(tournamentId: String) async throws {
        let subscribers = try await getSubscribers(tournamentId: tournamentId)
        
        // Validação simples: Precisa de pelo menos 2 jogadores
        guard subscribers.count >= 2 else {
            throw NSError(domain: "App", code: 400, userInfo: [NSLocalizedDescriptionKey: "São necessários pelo menos 2 inscritos."])
        }
        
        let shuffled = subscribers.shuffled()
        let pairs = stride(from: 0, to: shuffled.count, by: 2).map {
            Array(shuffled[$0..<min($0 + 2, shuffled.count)])
        }
        
        let batch = db.batch()
        let matchesRef = db.collection("tournaments").document(tournamentId).collection("matches")
        
        for (_, pair) in pairs.enumerated() {
            let p1 = pair[0]
            let p2 = pair.count > 1 ? pair[1] : nil
            let newDoc = matchesRef.document()
            
            let match = Match(
                id: nil,
                tournamentId: tournamentId,
                round: 1,
                player1: p1,
                player2: p2,
                player1Score: 0,
                player2Score: 0,
                winner: p2 == nil ? p1 : nil // BYE se não tiver par
            )
            try batch.setData(from: match, forDocument: newDoc)
        }
        try await batch.commit()
    }
    
    // MARK: - Partidas
    func getMatches(tournamentId: String) async throws -> [Match] {
        let snapshot = try await db.collection("tournaments").document(tournamentId)
            .collection("matches").order(by: "round").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Match.self) }
    }
    
    func updateMatchScore(tournamentId: String, match: Match, p1Score: Int, p2Score: Int) async throws {
        guard let matchId = match.id else { return }
        
        var winner: User? = nil
        if p1Score == 2 { winner = match.player1 }
        if p2Score == 2 { winner = match.player2 }
        
        let data: [String: Any] = [
            "player1Score": p1Score,
            "player2Score": p2Score,
            "winner": winner.map { try? Firestore.Encoder().encode($0) } as Any
        ]
        
        try await db.collection("tournaments").document(tournamentId)
            .collection("matches").document(matchId).updateData(data)
    }
    
    // MARK: - Excluir Torneio (NOVO)
    func deleteTournament(tournamentId: String) async throws {
        let tournamentRef = db.collection("tournaments").document(tournamentId)
        let batch = db.batch()
        
        // 1. Buscar e agendar exclusão de inscritos
        let subscribers = try await tournamentRef.collection("subscribers").getDocuments()
        for doc in subscribers.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 2. Buscar e agendar exclusão de partidas
        let matches = try await tournamentRef.collection("matches").getDocuments()
        for doc in matches.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 3. Agendar exclusão do documento principal
        batch.deleteDocument(tournamentRef)
        
        // 4. Executar tudo atomicamente
        try await batch.commit()
    }
}
