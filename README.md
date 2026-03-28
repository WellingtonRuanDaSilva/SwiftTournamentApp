# 🏆 SwiftTournamentApp

Um aplicativo iOS nativo desenvolvido para organizar, gerenciar e acompanhar torneios de e-sports e eventos locais. 
Este projeto foi desenvolvido como parte de um trabalho acadêmico com foco na aplicação de boas práticas de engenharia de software no ecossistema Apple.


---

## 🛠 Tecnologias Utilizadas
* **Linguagem:** Swift 5.0
* **Interface:** SwiftUI
* **Arquitetura:** MVVM (Model-View-ViewModel)
* **Backend & Autenticação:** Firebase (Firestore & FirebaseAuth)
* **Persistência Local:** Core Data
* **Frameworks Nativos:** MapKit (Localização), ARKit/SceneKit (Troféu Virtual 3D), SpriteKit (Animação de Confetes)

---

## 📋 Atendimento aos Requisitos do Projeto

Este projeto foi construído para cumprir rigorosamente os seguintes requisitos acadêmicos:

### 1. Clean Code (Código Limpo)
O projeto aplica os princípios de Clean Code para garantir legibilidade e facilidade de manutenção:
* **Nomenclatura Clara:** Variáveis e funções possuem nomes descritivos em inglês (ex: `createTournament()`, `loadMatches()`, `toggleFavorite()`).
* **Responsabilidade Única (SRP):** As funções são curtas e focadas. Por exemplo, em `TournamentDetailView.swift`, as lógicas de animação (`triggerConfetti()`) e exclusão (`deleteTournament()`) estão isoladas do corpo principal da View.
* **Tratamento de Erros:** Utilização de blocos `do-catch` e concorrência estruturada (`Task`/`await`) para chamadas de rede seguras.

### 2. Arquitetura de Software (MVVM)
A arquitetura escolhida foi a **MVVM**, o padrão mais recomendado para o framework SwiftUI:
* **Model:** Estrutura os dados e regras de negócio puras (`Tournament`, `Match`, `User`).
* **View:** Interface de usuário construída de forma declarativa (telas na pasta `View/`).
* **ViewModel / Service:** Gerencia o estado e a comunicação externa, como o `AuthViewModel` (gerenciamento de sessão) e o `TournamentRepository` (comunicação com o Firestore).

### 3. Injeção de Dependência (Dependency Injection)
A injeção de dependência foi utilizada para desacoplar componentes e compartilhar estados globais:
* **Injeção via Environment:** O `AuthViewModel` é injetado na raiz do app (`.environmentObject(authVM)`) e consumido pelas Views dependentes. O contexto do Core Data é injetado via `@Environment(\.managedObjectContext)`.
* **Injeção via Construtor:** Em componentes menores, como `MatchRow`, dependências como o repositório (`repo`) são passadas diretamente na inicialização da View.

### 4. Testes Unitários
Foram implementados testes unitários utilizando o framework **XCTest** para validar as regras de negócio da camada *Model* (em `TournamentTests.swift`):
1. `testTournamentLocationIsOnline`: Valida a classificação de eventos online.
2. `testTournamentLocationIsLocalEvent`: Valida a identificação de eventos presenciais.
3. `testTournamentDatesSameYearFormatting`: Verifica a formatação encurtada de datas para torneios que ocorrem no mesmo ano.
4. `testTournamentDatesDifferentYearsFormatting`: Verifica a formatação completa para torneios que viram o ano.
5. `testTournamentDatesInvalidFormatFallback`: Assegura a robustez do código retornando uma string de *fallback* para formatos de data inválidos, evitando *crashes*.

### 5. Design Patterns (Padrões de Projeto)
* **Repository Pattern:** O `TournamentRepository` abstrai a complexidade do Firebase SDK. A View apenas solicita os dados sem saber como eles são buscados.
* **Observer Pattern:** Utilizado nativamente via `Combine` (`@Published`, `@ObservableObject`). Views reagem automaticamente a mudanças de estado.
* **Singleton:** Aplicado no `PersistenceController.shared` para garantir uma instância única do gerenciador do Core Data.

### 6. Interface Funcional (Telas)
O aplicativo excede o requisito mínimo de 3 telas, entregando um fluxo completo:
* **Login & Registro:** Autenticação de usuários.
* **Dashboard:** Listagem reativa de todos os torneios.
* **Detalhes do Torneio:** Tela rica que inclui mapas integrados (`MapKit`) e visualização 3D de troféu (`ARKit`).
* **Criação de Torneio:** Formulário com validações e feedback visual via `SpriteKit`.
* **Favoritos:** Integração off-line/on-line utilizando o Core Data para salvar preferências locais.

---

## 🚀 Como Executar o Projeto

1. Clone este repositório.
2. Certifique-se de ter o **Xcode 15+** instalado.
3. Abra o arquivo `SwiftTournamentApp.xcodeproj`.
4. O projeto utiliza o Swift Package Manager (SPM). Aguarde o Xcode resolver as dependências do Firebase.
5. Selecione um simulador (ex: iPhone 15 Pro) e pressione `Cmd + R` para rodar.
6. Para rodar os testes unitários, pressione `Cmd + U`.

## 🎥 Demonstração em Vídeo

Clique no link abaixo  para assistir ao vídeo demonstrativo do aplicativo no YouTube:

https://youtu.be/li6c6G33unM
