import Foundation

// MARK: - City+PVGISParams

extension City {
    
    /// The PVGIS (Photovoltaic Geographical Information System) parameters of a city.
    struct PVGISParams: Codable, Hashable {
        
        /// The angle.
        let angle: Double
        
        /// The aspect.
        let aspect: Double
        
        /// The investment factor.
        let investmentFactor: Double
        
        /// The latitude.
        let lat: Double
        
        /// The longitude.
        let long: Double
        
    }
    
}
