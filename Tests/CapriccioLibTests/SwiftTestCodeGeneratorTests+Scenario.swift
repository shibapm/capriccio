//
//  SwiftTestCodeGeneratorTests+Options.swift
//  CapriccioLibTests
//
//  Created by Franco on 07/09/2018.
//

import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib
import SnapshotTesting

extension SwiftTestCodeGeneratorTests {
    func testItGeneratesTheCorrectCodeWithASimpleFeature() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testItGeneratesTheCorrectCodeWithAMoreComplexFeature() {
        let scenario: Gherkin.Scenario = .simple(ScenarioSimple(name: "Scenario I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        
        let scenario2: Gherkin.Scenario = .simple(ScenarioSimple(name: "Other scenario I want to test",
                                                         description: "",
                                                         steps:[Step(name: .given, text: "I'm in another situation"),
                                                                Step(name: .when, text: "Something different happens"),
                                                                Step(name: .then, text: "Something else happens")] ))
        
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario, scenario2])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
}
