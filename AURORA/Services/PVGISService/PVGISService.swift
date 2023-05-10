import Foundation

/// The PVGIS (Photovoltaic Geographical Information System) Service.
struct PVGISService: Sendable {
    
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

// MARK: - PhotovoltaicInvestmentResult

extension PVGISService {
    
    /// A photovoltaic investment result
    struct PhotovoltaicInvestmentResult: Codable, Hashable {
        
        /// The investment amount.
        let amount: Int
        
        /// The produced energy by the photovoltaic.
        let producedEnergy: Measurement<UnitEnergy>
    
        /// The carbon emissions produced by the photovoltaic.
        let carbonEmissions: Measurement<UnitMass>
        
        /// The carbon emissions without the photovoltaic.
        let normalCarbonEmissions: Measurement<UnitMass>
        
        /// The carbon emissions reduction.
        var carbonEmissionsReduction: Measurement<UnitMass> {
            self.normalCarbonEmissions - self.carbonEmissions
        }
        
    }
    
}

// MARK: - Calculate Photovoltaic Investment

extension PVGISService {
    
    /// Calculate a photovoltaic investment.
    /// - Parameters:
    ///   - amount: The amount to invest.
    ///   - pvgisParams: The PVGIS parameters of the city.
    ///   - country: The country.
    func calculatePhotovoltaicInvestment(
        amount: Int,
        using pvgisParams: City.PVGISParams,
        in country: Country
    ) async throws -> PhotovoltaicInvestmentResult {
        // Try to retrieve response
        let (responseData, response) = try await self.urlSession
            .data(
                from: .init(
                    url: self.hostURL,
                    amount: amount,
                    pvgisParams: pvgisParams
                )
            )
        // Verify response data is not empty
        // and the response is a success
        guard !responseData.isEmpty,
              (response as? HTTPURLResponse)?.statusCode == 200 else {
            // Otherwise throw an error
            throw URLError(.badServerResponse)
        }
        // Try to decode response as calculation response
        let calculationResponse = try JSONDecoder()
            .decode(
                CalculationResponse.self,
                from: responseData
            )
        // Initialize the produced energy
        let producedEnergy = Measurement<UnitEnergy>(
            value: calculationResponse
                .outputs
                .totals
                .fixed
                .energyOutputPerYear,
            unit: .kilowattHours
        )
        // Return photovoltaic investment result
        return .init(
            amount: amount,
            producedEnergy: producedEnergy,
            carbonEmissions: .init(
                value: producedEnergy.value * 0.0305,
                unit: .kilograms
            ),
            normalCarbonEmissions: .init(
                value: producedEnergy.value * 0.116,
                unit: .kilograms
            )
        )
    }
    
}

// MARK: - URL+init

private extension URL {
    
    /// Creates a new instance of `URL`.
    /// - Parameters:
    ///   - url: The host URL.
    ///   - amount: The amount.
    ///   - pvgisParams: The PVGIS parameters.
    init(
        url: URL,
        amount: Int,
        pvgisParams: City.PVGISParams
    ) throws {
        // Verify URLComponents can be initialized from URL.
        guard var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            // Otherwise throw an error
            throw URLError(.badURL)
        }
        // Set query items
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
                value: .init(Double(amount) / pvgisParams.investmentFactor / 1000)
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
        // Verify a URL is available
        guard let url = urlComponents.url else {
            // Otherwise throw an error
            throw URLError(.badURL)
        }
        // Initialize
        self = url
    }
    
}

// MARK: - CalculationResponse

private extension PVGISService {
    
    /// A PVGIS calculation response
    struct CalculationResponse: Codable {
        
        /// The Outputs.
        let outputs: Outputs
        
    }
    
}

// MARK: - CalculationResponse+Outputs

private extension PVGISService.CalculationResponse {
    
    /// The PVGIS calculation response outputs.
    struct Outputs: Codable {
        
        /// The Totals.
        let totals: Totals
        
    }
    
}

// MARK: - CalculationResponse+Outputs+Totals

private extension PVGISService.CalculationResponse.Outputs {
    
    /// The PVGIS calculation response outputs totals.
    struct Totals: Codable {
        
        /// The Fixed.
        let fixed: Fixed
        
    }
    
}

// MARK: - CalculationResponse+Outputs+Totals+Fixed

private extension PVGISService.CalculationResponse.Outputs.Totals {
    
    /// The PVGIS calculation response outputs totals fixed.
    struct Fixed: Codable {
        
        /// The CodingKeys
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case energyOutputPerMonth = "E_m"
            case energyOutputPerYear = "E_y"
        }
        
        /// The energy output per month.
        let energyOutputPerMonth: Double
        
        /// The energy output per year.
        let energyOutputPerYear: Double
        
    }
    
}
