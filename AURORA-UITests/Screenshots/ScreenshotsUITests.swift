import XCTest

// MARK: - ScreenshotsUITests

/// Fastlane Snapshot Screenshot UITests
final class ScreenshotsUITests: XCTestCase {
    
    /// Setup
    @MainActor
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("UITests")
        setupSnapshot(app)
        app.launch()
    }
    
    /// Take Screenshots
    @MainActor
    func testTakeScreenshots() {
        // Initialize App
        let app = XCUIApplication()
        // Check if home tab does not exists
        if !app.tabBars.buttons["HomeTab"].exists {
            // Wait until home tab exists
            XCTAssertTrue(
                app.tabBars.buttons["HomeTab"].waitForExistence(timeout: 10)
            )
        }
        // Snapshot dashboard
        snapshot("0_Dashboard")
        // Tap energy lables button
        app.buttons["ViewEnergyLabels"].tap()
        // Snapshot energy lables
        snapshot("1_EnergyLabels")
        // Tap close modal button
        app.buttons["CloseModal"].tap()
        // Tap add consumption button
        app.buttons["AddConsumption"].tap()
        // Tap add heating button
        app.buttons["AddHeating"].tap()
        // Snapshot add consumption
        snapshot("2_AddConsumption")
        // Tap close modal button
        app.buttons["CloseModal"].tap()
        // Tap settings tab
        app.tabBars.buttons["SettingsTab"].tap()
        // Snapshot settings
        snapshot("3_Settings")
    }
    
}

