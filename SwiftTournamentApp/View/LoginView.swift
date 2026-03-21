import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login").font(.largeTitle).bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Login") {
                    Task { try? await authVM.login(email: email, pass: password) }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Register") { showRegister = true }
            }
            .padding()
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
