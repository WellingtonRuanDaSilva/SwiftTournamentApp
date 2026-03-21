import SwiftUI
import SpriteKit

class ConfettiScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true
        
        let emitter = SKEmitterNode()
        
        // 1. Textura Gerada via Código (Retângulo Branco)
        emitter.particleTexture = createConfettiTexture()
        
        // 2. Configuração de Emissão
        emitter.particleBirthRate = 40  // Quantidade por segundo
        emitter.numParticlesToEmit = 0  // 0 = Infinito (controlamos via View)
        emitter.particleLifetime = 5.0  // Tempo que dura na tela
        
        // 3. Posição (Topo da tela, espalhado horizontalmente)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        
        // 4. Física (Caindo para baixo)
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.yAcceleration = -50     // Gravidade suave
        emitter.emissionAngle = 3 * .pi / 2 // 270 graus (baixo)
        emitter.emissionAngleRange = .pi / 4
        
        // 5. Cores
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0 // Usa 100% da cor definida abaixo
        
        // Troca de cores dinâmica (Arco-íris)
        let colors: [UIColor] = [.red, .cyan, .green, .yellow, .magenta, .orange, .purple]
        let colorAction = SKAction.customAction(withDuration: 0) { node, _ in
            if let particle = node as? SKEmitterNode {
                particle.particleColor = colors.randomElement() ?? .white
            }
        }
        
        let ramp = SKKeyframeSequence(keyframeValues: colors, times: [0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0])
        emitter.particleColorSequence = ramp
        
        // 6. Tamanho (Menores)
        emitter.particleScale = 0.3       // Tamanho base (pequeno)
        emitter.particleScaleRange = 0.1  // Variação
        emitter.particleScaleSpeed = -0.05 // Diminuem levemente enquanto caem
        
        // 7. Rotação (Efeito de papel caindo)
        emitter.particleRotation = 0
        emitter.particleRotationRange = 2 * .pi // Rotação inicial aleatória (360 graus)
        emitter.particleRotationSpeed = 1.5     // Giram enquanto caem
        
        addChild(emitter)
    }
    
    // Função auxiliar para desenhar um retângulozinho na memória
    func createConfettiTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 10) // Formato de papel picado
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
}

struct ConfettiView: View {
    var body: some View {
        SpriteView(scene: setupScene(), options: [.allowsTransparency])
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
    
    func setupScene() -> SKScene {
        let scene = ConfettiScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }
}
