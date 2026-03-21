import SwiftUI
import CoreData // Necessário para a funcionalidade de Favoritos

struct TournamentDetailView: View {
    // MARK: - Propriedades
    let tournament: Tournament
    
    // Environment Objects
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext // Contexto do Core Data
    
    // Repository
    @StateObject var repo = TournamentRepository()
    
    // MARK: - Estados da View
    @State private var matches: [Match] = []
    @State private var isSubscribed = false
    @State private var subscribersCount = 0
    
    // Estados para Funcionalidades Extras
    @State private var showConfetti = false // SpriteKit (Animação de vitória)
    @State private var showARTrophy = false // ARKit (Ver troféu 3D)
    
    // Estados para Admin
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    
    // MARK: - Core Data (Favoritos)
    // Busca na tabela 'FavoriteTournament' para ver se este torneio já foi salvo
    @FetchRequest(
        entity: FavoriteTournament.entity(),
        sortDescriptors: []
    ) var favorites: FetchedResults<FavoriteTournament>
    
    // Propriedade computada para saber se o torneio atual é favorito
    var isFavorite: Bool {
        favorites.contains { $0.id == tournament.id }
    }
    
    // Verifica se o usuário logado é o dono do torneio
    var isAdmin: Bool {
        return authVM.currentUser?.email == tournament.createdBy
    }
    
    // MARK: - Corpo da View
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 1. CABEÇALHO (Nome + Favorito)
                    HStack {
                        Text(tournament.name)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        // Botão de Favoritar (Core Data)
                        Button {
                            toggleFavorite()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.title2)
                        }
                    }
                    
                    // Datas e Local (Texto)
                    HStack {
                        Image(systemName: "calendar")
                        Text(tournament.dates)
                    }
                    .foregroundColor(.secondary)
                    
                    // 2. MAPKIT (Localização)
                    if tournament.location != "Online" {
                        VStack(alignment: .leading) {
                            Text("Localização")
                                .font(.headline)
                            
                            TournamentMapView(locationName: tournament.contactType)
                            
                            Text(tournament.contactType)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    } else {
                        HStack {
                            Image(systemName: "globe")
                            Text("Evento Online")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // 3. ARKIT (Botão do Troféu)
                    Button(action: { showARTrophy = true }) {
                        HStack {
                            Image(systemName: "cube.transparent")
                            Text("Ver Troféu em 3D")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .sheet(isPresented: $showARTrophy) {
                        TrophyView()
                    }
                    
                    Divider()
                    
                    // 4. ÁREA DE INSCRIÇÃO
                    HStack {
                        Text("\(subscribersCount) inscritos")
                            .font(.headline)
                        
                        Spacer()
                        
                        if matches.isEmpty {
                            Button(isSubscribed ? "Cancelar Inscrição" : "Inscrever-se") {
                                toggleSubscription()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(isSubscribed ? .red : .blue)
                        } else {
                            Text("Inscrições Encerradas")
                                .font(.caption)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Divider()
                    
                    // 5. PAINEL DE ADMIN (Se for o criador)
                    if isAdmin {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Painel do Organizador")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            HStack {
                                // Botão Gerar Chaves
                                if matches.isEmpty {
                                    Button("Gerar Chaves") {
                                        Task {
                                            try? await repo.generateBracket(tournamentId: tournament.id!)
                                            loadMatches()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.orange)
                                } else {
                                    Label("Chaves Geradas", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                // Botão Excluir
                                Button(role: .destructive) {
                                    showDeleteAlert = true
                                } label: {
                                    if isDeleting {
                                        ProgressView()
                                    } else {
                                        Label("Excluir", systemImage: "trash")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(isDeleting)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        
                        Divider()
                    }
                    
                    // 6. LISTA DE PARTIDAS
                    Text("Partidas")
                        .font(.title2)
                        .bold()
                    
                    if matches.isEmpty {
                        Text("Nenhuma partida agendada ainda.")
                            .italic()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(matches) { match in
                            MatchRow(match: match, isAdmin: isAdmin, tournamentId: tournament.id!, repo: repo) {
                                // Callback executado quando o placar é atualizado
                                loadMatches()
                                
                                // SPRITEKIT: Se houver um vencedor, ativa os confetes
                                if match.winner != nil {
                                    triggerConfetti()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            // 7. SPRITEKIT OVERLAY (Confetes)
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false) // Permite clicar através dos confetes
            }
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        
        // Alerta de Exclusão
        .alert("Excluir Torneio?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                deleteTournament()
            }
        } message: {
            Text("Tem certeza? Todas as partidas e inscrições serão apagadas permanentemente.")
        }
        // Carregamento inicial
        .task {
            await checkSubscription()
            loadMatches()
        }
    }
    
    // MARK: - Funções Auxiliares
    
    // Lógica do Core Data (Adicionar/Remover Favorito)
    func toggleFavorite() {
        if isFavorite {
            // Remover dos favoritos
            // Procura o objeto no array de results que tem o mesmo ID
            if let favToDelete = favorites.first(where: { $0.id == tournament.id }) {
                viewContext.delete(favToDelete)
            }
        } else {
            // Adicionar aos favoritos
            let newFav = FavoriteTournament(context: viewContext)
            newFav.id = tournament.id
            newFav.name = tournament.name
            newFav.dateAdded = Date()
        }
        
        // Salvar as alterações no banco local
        do {
            try viewContext.save()
        } catch {
            print("Erro ao salvar favorito: \(error)")
        }
    }
    
    // Ativa a animação de confetes por 3 segundos
    func triggerConfetti() {
        withAnimation {
            showConfetti = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showConfetti = false
            }
        }
    }
    
    func toggleSubscription() {
        guard let user = authVM.currentUser, let uid = user.id, let tid = tournament.id else { return }
        Task {
            if isSubscribed {
                try? await repo.unsubscribe(tournamentId: tid, userId: uid)
            } else {
                try? await repo.subscribe(tournamentId: tid, user: user, userId: uid)
            }
            await checkSubscription()
        }
    }
    
    func checkSubscription() async {
        guard let uid = authVM.currentUser?.id, let tid = tournament.id else { return }
        isSubscribed = (try? await repo.isSubscribed(tournamentId: tid, userId: uid)) ?? false
        let subs = (try? await repo.getSubscribers(tournamentId: tid)) ?? []
        subscribersCount = subs.count
    }
    
    func loadMatches() {
        guard let tid = tournament.id else { return }
        Task {
            matches = (try? await repo.getMatches(tournamentId: tid)) ?? []
        }
    }
    
    func deleteTournament() {
        guard let tid = tournament.id else { return }
        isDeleting = true
        Task {
            do {
                try await repo.deleteTournament(tournamentId: tid)
                isDeleting = false
                dismiss() // Volta para a tela anterior
            } catch {
                isDeleting = false
                print("Erro ao excluir: \(error)")
            }
        }
    }
}
