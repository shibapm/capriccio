//
//  SwiftTestCodeGeneratorTests+SenarioOutline.swift
//  CapriccioLibTests
//
//  Created by Franco on 04/09/2018.
//

import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib
import SnapshotTesting

extension SwiftTestCodeGeneratorTests {
    func testItGeneratesTheCorrectCodeWithAnOutlineScenario() {
        let examples = [Example(values: ["key1": "value1", "key2": "value2"]),
                        Example(values: ["key1": "value3", "key2": "value4"])]
        
        let scenario: Gherkin.Scenario = .outline(ScenarioOutline(name: "Scenario I want to test",
                                                          description: "",
                                                          steps:[Step(name: .given, text: "I'm in a situation"),
                                                                 Step(name: .when, text: "Something happens <key1>"),
                                                                 Step(name: .then, text: "Something else happens <key2>")],
                                                          examples: examples))
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testItGeneratesTheCorrectCodeWithMultipleOutlineScenarios() {
        let examples = [Example(values: ["key1": "value1", "key2": "value2"]),
                        Example(values: ["key1": "value3", "key2": "value4"])]
        
        let scenario: Gherkin.Scenario = .outline(ScenarioOutline(name: "Scenario I want to test",
                                                          description: "",
                                                          steps:[Step(name: .given, text: "I'm in a situation"),
                                                                 Step(name: .when, text: "Something happens <key1>"),
                                                                 Step(name: .then, text: "Something else happens <key2>")],
                                                          examples: examples))
        
        let examples2 = [Example(values: ["key3": "value5", "key4": "value6"]),
                        Example(values: ["key3": "value7", "key4": "value8"])]
        
        let scenario2: Gherkin.Scenario = .outline(ScenarioOutline(name: "Other scenario I want to test",
                                                          description: "",
                                                          steps:[Step(name: .given, text: "I'm in another situation"),
                                                                 Step(name: .when, text: "Something different happens <key4>"),
                                                                 Step(name: .then, text: "Something else happens <key3>")],
                                                          examples: examples2))
        
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario, scenario2])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testItGeneratesTheCorrectCodeWithAnOutlineScenarioAndComplexExamples() {
        let examples = [Example(values: ["key1": "value1", "key2": "text with spaces, commas and dots."]),
                        Example(values: ["key1": "another - really % complex @ text", "key2": "value4"])]
        
        let scenario: Gherkin.Scenario = .outline(ScenarioOutline(name: "Scenario I want to test",
                                                          description: "",
                                                          steps:[Step(name: .given, text: "I'm in a situation"),
                                                                 Step(name: .when, text: "Something happens <key1>"),
                                                                 Step(name: .then, text: "Something else happens <key2>")],
                                                          examples: examples))
        
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
}
