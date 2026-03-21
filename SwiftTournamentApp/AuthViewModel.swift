import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    
    init() {
        // Verifica usuário logado ao iniciar
        if let authUser = Auth.auth().currentUser {
            Task { await fetchUser(uid: authUser.uid) }
        }
    }
    
    func login(email: String, pass: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: pass)
        await fetchUser(uid: result.user.uid)
    }
    
    func register(email: String, pass: String, country: String, birth: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: pass)
        
        let newUser = User(
            email: email,
            birthday: birth,
            country: country,
            marketingConsent: false,
            termsAccepted: true,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        try db.collection("users").document(result.user.uid).setData(from: newUser)
        self.currentUser = newUser
        self.isAuthenticated = true
    }
    
    func logout() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    private func fetchUser(uid: String) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try doc.data(as: User.self)
            self.isAuthenticated = true
        } catch {
            print("Erro ao buscar user: \(error)")
        }
    }
}
