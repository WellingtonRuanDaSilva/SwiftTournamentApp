import SwiftUI

struct MatchRow: View {
    let match: Match
    let isAdmin: Bool
    let tournamentId: String
    let repo: TournamentRepository
    let onUpdate: () -> Void
    
    @State private var p1Score = ""
    @State private var p2Score = ""
    
    var body: some View {
        VStack {
            Text("Rodada \(match.round)").font(.caption)
            
            HStack {
                Text(match.player1?.email.components(separatedBy: "@").first ?? "BYE")
                    .bold(match.winner?.email == match.player1?.email)
                Spacer()
                TextField("0", text: $p1Score).frame(width: 30).keyboardType(.numberPad)
                    .disabled(match.winner != nil)
                Text("vs")
                TextField("0", text: $p2Score).frame(width: 30).keyboardType(.numberPad)
                     .disabled(match.winner != nil)
                Spacer()
                Text(match.player2?.email.components(separatedBy: "@").first ?? "BYE")
                     .bold(match.winner?.email == match.player2?.email)
            }
            
            if match.winner == nil && match.player2 != nil {
                Button("Atualizar") {
                    guard let s1 = Int(p1Score), let s2 = Int(p2Score) else { return }
                    // Validação simples baseada no repositório Kotlin
                    if (s1 == 2 || s2 == 2) && s1 != s2 {
                        Task {
                            try? await repo.updateMatchScore(tournamentId: tournamentId, match: match, p1Score: s1, p2Score: s2)
                            onUpdate()
                        }
                    }
                }
            } else if match.winner != nil {
                Text("Finalizada").foregroundColor(.green).font(.caption)
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
        .onAppear {
            p1Score = String(match.player1Score)
            p2Score = String(match.player2Score)
        }
    }
}
