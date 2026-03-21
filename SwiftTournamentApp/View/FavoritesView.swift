import SwiftUI
import CoreData

struct FavoritesView: View {
    // 1. Core Data: Busca todos os itens salvos localmente
    @FetchRequest(
        entity: FavoriteTournament.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteTournament.dateAdded, ascending: false)]
    ) var savedFavorites: FetchedResults<FavoriteTournament>
    
    // 2. Firebase: Repositório para buscar os dados completos
    @StateObject var repo = TournamentRepository()
    @State private var allTournaments: [Tournament] = []
    @State private var isLoading = true
    
    var body: some View {
        List {
            if savedFavorites.isEmpty {
                Text("Você ainda não tem favoritos.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Filtra a lista completa do Firebase mantendo apenas o que tem ID no Core Data
                let favoriteTournaments = allTournaments.filter { tournament in
                    savedFavorites.contains { fav in fav.id == tournament.id }
                }
                
                ForEach(favoriteTournaments) { tournament in
                    NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text(tournament.name)
                                    .font(.headline)
                                Text(tournament.dates)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Meus Favoritos")
        .overlay {
            if isLoading {
                ProgressView("Sincronizando...")
            }
        }
        .task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            allTournaments = try await repo.getAllTournaments()
            isLoading = false
        } catch {
            print("Erro ao carregar torneios: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    FavoritesView()
}
