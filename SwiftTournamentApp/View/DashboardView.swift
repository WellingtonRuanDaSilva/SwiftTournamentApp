import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var tournamentRepo = TournamentRepository()
    @State private var tournaments: [Tournament] = []
    
    var body: some View {
        NavigationStack {
            List(tournaments) { tournament in
                NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                    HStack(spacing: 12) {
                        Image(systemName: "trophy.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading) {
                            Text(tournament.name)
                                .font(.headline)
                            Text(tournament.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(tournament.dates) // Exibe as datas simplificadas
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Torneios")
            .overlay {
                if tournaments.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Carregando torneios...")
                            .padding(.top)
                    }
                }
            }
            .toolbar {
                            // Botão de Criar (Direita)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                HStack {
                                    // Botão para ir aos Favoritos
                                    NavigationLink(destination: FavoritesView()) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    }
                                    
                                    NavigationLink(destination: CreateTournamentView()) {
                                        Label("Criar", systemImage: "plus")
                                    }
                                }
                            }
                            
                            // Botão de Sair (Esquerda)
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Sair") {
                                    authVM.logout()
                                }
                            }
                        }
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        do {
            let fetched = try await tournamentRepo.getAllTournaments()
            if fetched.isEmpty {
                // Lógica de Sample Data (Dados de Exemplo se vazio)
                tournaments = getSampleTournaments()
            } else {
                tournaments = fetched
            }
        } catch {
            print("Erro ao carregar: \(error)")
            // Em caso de erro, também mostra samples para não ficar vazio
            if tournaments.isEmpty {
                tournaments = getSampleTournaments()
            }
        }
    }
    
    // Simula os dados de exemplo do Kotlin
    func getSampleTournaments() -> [Tournament] {
        return [
            Tournament(id: "sample1", name: "Teste Arena", contactEmail: "admin@example.com", contactType: "Discord", startDate: "14/04/2022", endDate: "24/04/2022", createdAt: 0, createdBy: "admin@example.com"),
            Tournament(id: "sample2", name: "Campeonato Local", contactEmail: "org@example.com", contactType: "Phone", startDate: "10/05/2022", endDate: "12/05/2022", createdAt: 0, createdBy: "org@example.com")
        ]
    }
}
