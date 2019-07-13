//
//  SwiftTestCodeGeneratorTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 03/09/2018.
//

import XCTest
import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib
import SnapshotTesting

final class SwiftTestCodeGeneratorTests: XCTestCase {
    var swiftCodeGenerator: SwiftTestCodeGenerator!
    
    override func setUp() {
        super.setUp()
        swiftCodeGenerator = SwiftTestCodeGenerator()
    }
    
    override func tearDown() {
        swiftCodeGenerator = nil
        super.tearDown()
    }
    
    func testItUsesTheGeneratedClassType() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature, generatedClassType: "TestClass"), as: .lines)
    }
    
    func testItRemovesNotAllowedCaracters() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testItChangesButToAnd() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testItDisablesFileLenghtWarningWhenRequired() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature, disableSwiftLint: true), as: .lines)
    }
    
    func testItUsesAPassedTemplate() {
        let path = "testPath"
        
        try! """
        import Lib1
        import Lib2

        final class {{ feature.name }}: {{ classType }} {
        {% for scenario in feature.scenarios %}
            func testScenario_{{ scenario.name }}() {
                {% for step in scenario.steps%}
                step_{{ step.name }}(){% endfor %}
            }
        }{% endfor %}
        """.write(toFile: path, atomically: false, encoding: .utf8)
        
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature, templateFilePath: path), as: .lines)
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
    func textFromFeature(_ feature: Gherkin.Feature, generatedClassType: String? = nil, templateFilePath: String? = nil, disableSwiftLint: Bool = false) -> String {
        let result = swiftCodeGenerator.generateSwiftTestCode(forFeature: CapriccioLib.Feature(gherkinFeature: feature), generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint, version: "1.0.0")
        return result
    }
}
