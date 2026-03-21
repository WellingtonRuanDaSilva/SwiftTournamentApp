import SwiftUI
import FirebaseCore
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct SwiftTournamentAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Inicializa o Controller do Core Data
    let persistenceController = PersistenceController.shared
    
    // Inicializa o ViewModel de Autenticação
    @StateObject var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // Lógica de Troca de Tela (Login / Dashboard)
            Group {
                if authVM.isAuthenticated {
                    DashboardView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authVM)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
