import SwiftUI
import MapKit

struct TournamentMapView: View {
    let locationName: String
    
    @State private var position: MapCameraPosition = .automatic
    @State private var marker: LocationMarker? // Apenas um marcador é suficiente
    
    struct LocationMarker: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
    
    var body: some View {
        Map(position: $position) {
            if let marker = marker {
                Marker(marker.name, coordinate: marker.coordinate)
                    .tint(.red)
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
        .mapStyle(.standard)
        .task {
            await searchLocation()
        }
    }
    
    func searchLocation() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            if let item = response.mapItems.first {
                let coord = item.placemark.coordinate
                let name = item.name ?? locationName
                
                // Atualiza o marcador
                self.marker = LocationMarker(name: name, coordinate: coord)
                
                // Move a câmera para o local com uma animação suave
                withAnimation {
                    self.position = .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
        } catch {
            print("Erro ao buscar local no mapa: \(error.localizedDescription)")
        }
    }
}
