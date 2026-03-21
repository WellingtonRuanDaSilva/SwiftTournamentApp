import SwiftUI
import FirebaseAuth

struct CreateTournamentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var repo = TournamentRepository()
    
    // Estados do Formulário
    @State private var name = ""
    @State private var contactEmail = ""
    
    // Estados de Localização
    @State private var isLocalEvent = false
    @State private var selectedPlatform = "Discord"
    @State private var address = ""
    
    // Datas
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    // Estados de Interface
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Estado para os Confetes
    @State private var showConfetti = false
    
    let platforms = ["Discord", "Email", "WhatsApp", "Twitter"]
    
    var isDateValid: Bool {
        return endDate >= startDate
    }
    
    var body: some View {
        ZStack { // 1. Usamos ZStack para colocar os confetes por cima de tudo
            Form {
                Section(header: Text("Detalhes do Torneio")) {
                    TextField("Nome do Torneio", text: $name)
                    
                    TextField("Email de Contato", text: $contactEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("Localização")) {
                    Picker("Tipo de Evento", selection: $isLocalEvent) {
                        Text("Online").tag(false)
                        Text("Presencial").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    if isLocalEvent {
                        VStack(alignment: .leading) {
                            Text("Endereço do Evento")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Ex: Av. Paulista, 1000 - SP", text: $address)
                        }
                    } else {
                        Picker("Plataforma", selection: $selectedPlatform) {
                            ForEach(platforms, id: \.self) { platform in
                                Text(platform)
                            }
                        }
                    }
                }
                
                Section(header: Text("Datas")) {
                    DatePicker("Início", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Fim", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    
                    if !isDateValid {
                        Text("A data final deve ser posterior à data inicial.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    if isLoading {
                        HStack { Spacer(); ProgressView(); Spacer() }
                    } else {
                        Button("Criar Torneio") {
                            createTournament()
                        }
                        .disabled(isFormInvalid || showConfetti) // Desabilita se estiver rodando animação
                    }
                }
            }
            .navigationTitle("Novo Torneio")
            .onAppear {
                if let userEmail = Auth.auth().currentUser?.email {
                    contactEmail = userEmail
                }
            }
            .alert("Erro", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            
            // 2. A Camada de Confetes
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false) // Permite clicar "através" da animação se necessário
                    .ignoresSafeArea()
            }
        }
    }
    
    var isFormInvalid: Bool {
        let isBasicInvalid = name.isEmpty || contactEmail.isEmpty || !isDateValid
        if isLocalEvent {
            return isBasicInvalid || address.isEmpty
        } else {
            return isBasicInvalid
        }
    }
    
    func createTournament() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "Usuário não identificado."
            showError = true
            return
        }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let finalContactType = isLocalEvent ? address : selectedPlatform
        
        let newTournament = Tournament(
            id: nil,
            name: name,
            contactEmail: contactEmail,
            contactType: finalContactType,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            createdAt: Int64(Date().timeIntervalSince1970 * 1000),
            createdBy: userEmail
        )
        
        Task {
            do {
                _ = try await repo.createTournament(newTournament)
                isLoading = false
                
                // 3. Lógica de Sucesso com Animação
                withAnimation {
                    showConfetti = true // Ativa os confetes
                }
                
                // Espera 3 segundos antes de fechar a tela
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    dismiss()
                }
                
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
