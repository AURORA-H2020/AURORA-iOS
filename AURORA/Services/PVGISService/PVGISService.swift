import Foundation

/// The PVGIS (Photovoltaic Geographical Information System) Service.
struct PVGISService {
    
    // MARK: Properties
    
    /// The host URL.
    private let hostURL: URL
    
    /// The URLSession
    private let  urlSession: URLSession
    
    // MARK: Initializer
    
    /// Creates a new instance of `PVGISService`
    /// - Parameters:
    ///   - hostURL: The host URL.
    ///   - urlSession: The URLSession. Default value `.shared`
    init(
        hostURL: URL = .init(string: "https://re.jrc.ec.europa.eu/api/v5_2/PVcalc")!,
        urlSession: URLSession = .shared
    ) {
        self.hostURL = hostURL
        self.urlSession = urlSession
    }
    
}

// MARK: - Shared

extension PVGISService {
    
    /// The shared PVGISService instance.
    static let shared = Self()
    
}

// MARK: - Calculcate Photovoltaic Investment

extension PVGISService {
    
    struct PhotovoltaicInvestmentResult: Codable, Hashable {
        
        let producedEnergy: Double
    
        let carbonEmissionsSavings: Double
        
    }
    
    func calculcatePhotovoltaicInvestment(
        amount: Double,
        using pvgisParams: City.PVGISParams,
        in country: Country
    ) async throws -> PhotovoltaicInvestmentResult {
        guard var urlComponents = URLComponents(url: self.hostURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        urlComponents.queryItems = [
            .init(
                name: "lat",
                value: .init(pvgisParams.lat)
            ),
            .init(
                name: "lon",
                value: .init(pvgisParams.long)
            ),
            .init(
                name: "peakpower",
                value: .init(amount / pvgisParams.investmentFactor / 1000)
            ),
            .init(
                name: "loss",
                value: "0.14"
            ),
            .init(
                name: "pvtechchoice",
                value: "crystSi"
            ),
            .init(
                name: "mountingplace",
                value: "free"
            ),
            .init(
                name: "raddatabase",
                value: "PVGIS-SARAH"
            ),
            .init(
                name: "aspect",
                value: .init(pvgisParams.aspect)
            ),
            .init(
                name: "angle",
                value: .init(pvgisParams.angle)
            ),
            .init(
                name: "outputformat",
                value: "json"
            )
        ]
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        let (responseData, response) = try await self.urlSession.data(from: url)
        print(String(decoding: responseData, as: UTF8.self))
        guard !responseData.isEmpty, (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let calculcationResponse = try JSONDecoder()
            .decode(
                CalculcationResponse.self,
                from: responseData
            )
        
        throw URLError(.badURL)
    }
    
}

private extension PVGISService {
    
    struct CalculcationResponse: Codable {
        
        let outputs: Outputs
        
    }
    
}

private extension PVGISService.CalculcationResponse {
    
    struct Outputs: Codable {
        
        let totals: Totals
        
    }
    
}

private extension PVGISService.CalculcationResponse.Outputs {
    
    struct Totals: Codable {
        
        let fixed: Fixed
        
    }
    
}

private extension PVGISService.CalculcationResponse.Outputs.Totals {
    
    struct Fixed: Codable {
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case energyOutputPerMonth = "E_m"
            case energyOutputPerYear = "E_y"
        }
        
        let energyOutputPerMonth: Double
        
        let energyOutputPerYear: Double
        
    }
    
}
