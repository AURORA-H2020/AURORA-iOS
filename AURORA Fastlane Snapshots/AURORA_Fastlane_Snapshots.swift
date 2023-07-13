//
//  AURORA_Fastlane_Snapshots.swift
//  AURORA Fastlane Snapshots
//
//  Created by Lars Lorenz on 12.07.23.
//

import XCTest

class TestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
      
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        continueAfterFailure = false
    }
    
    func testScreenshots() {
        let app = XCUIApplication()
        
        snapshot("0_Dashboard")
        
        app.buttons["viewEnergyLabels"].tap()
        
        snapshot("1_EnergyLabels")
        
        app.buttons["modalClose"].tap()
        
        app.buttons["addConsumption"].tap()
        
        app.buttons["addheating"].tap()
        
        snapshot("2_AddConsumption")
        
        app.buttons["modalClose"].tap()
        
        app.tabBars.buttons["settingsTab"].tap()
        
        snapshot("3_Settings")
                        
                
    }
    
}
