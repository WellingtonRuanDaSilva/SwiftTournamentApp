import SwiftUI
import ARKit
import SceneKit

struct ARActionView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.autoenablesDefaultLighting = true
        
        // Configuração da Sessão
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if uiView.scene.rootNode.childNodes.isEmpty {
            addVirtualTrophy(to: uiView)
        }
    }
    
    func addVirtualTrophy(to arView: ARSCNView) {
        // Base do Troféu (Cubo Dourado)
        let baseGeometry = SCNBox(width: 0.1, height: 0.02, length: 0.1, chamferRadius: 0.002)
        baseGeometry.firstMaterial?.diffuse.contents = UIColor.systemYellow
        let baseNode = SCNNode(geometry: baseGeometry)
        baseNode.position = SCNVector3(0, -0.2, -0.5) // 50cm na frente da câmera
        
        // Taça (Cilindro/Tubo)
        let cupGeometry = SCNTube(innerRadius: 0.04, outerRadius: 0.05, height: 0.15)
        cupGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        let cupNode = SCNNode(geometry: cupGeometry)
        cupNode.position = SCNVector3(0, 0.08, 0)
        
        baseNode.addChildNode(cupNode)
        arView.scene.rootNode.addChildNode(baseNode)
    }
}

struct TrophyView: View {
    var body: some View {
        ARActionView()
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Spacer()
                    Text("Troféu Virtual")
                        .font(.title)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding()
                }
            )
    }
}

