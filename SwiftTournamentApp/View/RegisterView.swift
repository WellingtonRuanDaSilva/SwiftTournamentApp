import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss // Para fechar a tela se necessário
    
    // Estados dos Campos
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var country = ""
    @State private var birthDate = Date()
    @State private var marketingConsent = false
    @State private var termsAccepted = false
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        Form {
            Section(header: Text("Dados de Acesso")) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Senha", text: $password)
                SecureField("Confirmar Senha", text: $confirmPassword)
            }
            
            Section(header: Text("Dados Pessoais")) {
                TextField("País", text: $country)
                DatePicker("Data de Nascimento", selection: $birthDate, displayedComponents: .date)
            }
            
            Section(header: Text("Termos e Condições")) {
                Toggle("Aceito receber marketing", isOn: $marketingConsent)
                Toggle("Aceito os termos de uso", isOn: $termsAccepted)
            }
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                Button("Registrar") {
                    registerUser()
                }
                .disabled(!isValidForm)
            }
        }
        .navigationTitle("Criar Conta")
        .alert("Erro", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Validação simples do formulário
    var isValidForm: Bool {
        return !email.isEmpty
            && !password.isEmpty
            && !confirmPassword.isEmpty
            && password == confirmPassword
            && termsAccepted
    }
    
    func registerUser() {
        isLoading = true
        
        // Formatar Data para String (igual ao formato do Kotlin)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: birthDate)
        
        Task {
            do {
                // Chamada ao ViewModel criado anteriormente
                try await authVM.register(
                    email: email,
                    pass: password,
                    country: country,
                    birth: dateString
                )
                isLoading = false

            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
