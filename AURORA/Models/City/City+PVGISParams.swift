import Foundation

// MARK: - City+PVGISParams

extension City {
    
    /// The PVGIS (Photovoltaic Geographical Information System) parameters of a city.
    struct PVGISParams: Codable, Hashable {
        
        let angle: Double
        
        let aspect: Double
        
        let investmentFactor: Double
        
        let lat: Double
        
        let long: Double
        
    }
    
}
