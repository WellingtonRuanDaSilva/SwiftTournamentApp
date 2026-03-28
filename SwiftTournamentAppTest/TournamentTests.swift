import XCTest
@testable import SwiftTournamentApp // Permite acessar as classes e structs do seu app principal

final class TournamentTests: XCTestCase {

    // MARK: - Testes da Propriedade 'location'

    // TESTE 1: Verifica se um torneio via Discord é identificado como "Online"
    func testTournamentLocationIsOnline() {
        // Given (Dado um torneio configurado com plataforma digital)
        let tournament = Tournament(name: "Copa Online", contactEmail: "org@test.com", contactType: "Discord", startDate: "10/10/2023 10:00", endDate: "12/10/2023 10:00", createdAt: 0, createdBy: "user")
        
        // When (Quando checamos a localização)
        let locationResult = tournament.location
        
        // Then (Então o resultado deve ser "Online")
        XCTAssertEqual(locationResult, "Online", "A propriedade location deve retornar 'Online' para plataformas como o Discord.")
    }

    // TESTE 2: Verifica se um torneio com endereço físico é identificado como "Local Event"
    func testTournamentLocationIsLocalEvent() {
        // Given (Dado um torneio configurado com endereço físico)
        let tournament = Tournament(name: "Torneio SP", contactEmail: "org@test.com", contactType: "Av Paulista, 1000 - SP", startDate: "10/10/2023 10:00", endDate: "12/10/2023 10:00", createdAt: 0, createdBy: "user")
        
        // When (Quando checamos a localização)
        let locationResult = tournament.location
        
        // Then (Então o resultado deve ser "Local Event")
        XCTAssertEqual(locationResult, "Local Event", "A propriedade location deve retornar 'Local Event' para um endereço que não seja uma plataforma online mapeada.")
    }

    // MARK: - Testes da Propriedade 'dates'

    // TESTE 3: Verifica a formatação amigável das datas quando o torneio começa e termina no MESMO ANO
    func testTournamentDatesSameYearFormatting() {
        // Given (Dado um torneio em abril de 2022)
        let tournament = Tournament(name: "Teste de Data 1", contactEmail: "org@test.com", contactType: "Email", startDate: "14/04/2022 10:00", endDate: "24/04/2022 18:00", createdAt: 0, createdBy: "user")
        
        // When (Quando formatamos a data)
        let formattedDate = tournament.dates
        
        // Then (Então o resultado deve ocultar o ano da data inicial para não ficar repetitivo)
        XCTAssertEqual(formattedDate, "Apr 14 — Apr 24, 2022", "A formatação de datas do mesmo ano deve seguir o padrão 'Mes Dia — Mes Dia, Ano'.")
    }

    // TESTE 4: Verifica a formatação amigável das datas quando o torneio atravessa ANOS DIFERENTES
    func testTournamentDatesDifferentYearsFormatting() {
        // Given (Dado um torneio que começa no final de 2022 e termina em 2023)
        let tournament = Tournament(name: "Teste Virada de Ano", contactEmail: "org@test.com", contactType: "WhatsApp", startDate: "30/12/2022 10:00", endDate: "05/01/2023 18:00", createdAt: 0, createdBy: "user")
        
        // When (Quando formatamos a data)
        let formattedDate = tournament.dates
        
        // Then (Então o resultado deve exibir o ano tanto na data inicial quanto na final)
        XCTAssertEqual(formattedDate, "Dec 30, 2022 — Jan 05, 2023", "Datas em anos diferentes devem exibir o ano em ambas as partes.")
    }

    // TESTE 5: Verifica o mecanismo de fallback caso as datas inseridas estejam em um formato inválido/inesperado
    func testTournamentDatesInvalidFormatFallback() {
        // Given (Dado um torneio com datas escritas de forma livre, fora do padrão dd/MM/yyyy HH:mm)
        let tournament = Tournament(name: "Teste Falha de Parse", contactEmail: "org@test.com", contactType: "Twitter", startDate: "Amanhã", endDate: "Depois de Amanhã", createdAt: 0, createdBy: "user")
        
        // When (Quando tentamos formatar)
        let formattedDate = tournament.dates
        
        // Then (Então o sistema não deve dar 'crash', mas sim retornar as strings originais separadas por hífen)
        XCTAssertEqual(formattedDate, "Amanhã - Depois de Amanhã", "Se o DateFormatter falhar ao interpretar as datas, o app deve retornar a string original bruta.")
    }
}
