import XCTest

// MARK: - ScreenshotsUITests

/// Fastlane Snapshot Screenshot UITests
final class ScreenshotsUITests: XCTestCase {
    
    /// The application
    let app = XCUIApplication()
    
    /// Setup
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        self.app.launchArguments.append("--uitesting")
        setupSnapshot(self.app, waitForAnimations: false)
        self.app.launch()
    }
    
    /// Take Screenshots
    func testTakeScreenshots() {
        // Check if HomeTab does not exists
        if !self.app.tabBars.buttons["HomeTab"].exists {
            // Wait for HomeTab existence
            XCTAssertTrue(self.app.tabs.buttons["HomeTab"].waitForExistence(timeout: 10))
        }
        
        snapshot("0_Dashboard")
        
        self.app.buttons["ViewEnergyLabels"].tap()
        
        snapshot("1_EnergyLabels")
        
        self.app.buttons["CloseModal"].tap()
        
        self.app.buttons["AddConsumption"].tap()
        
        self.app.buttons["AddHeating"].tap()
        
        snapshot("2_AddConsumption")
        
        self.app.buttons["CloseModal"].tap()
        
        self.app.tabBars.buttons["SettingsTab"].tap()
        
        snapshot("3_Settings")
    }
    
}

