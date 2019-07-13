//
//  SwiftTestCodeGeneratorTests+MultipleScenarios.swift
//  CapriccioLibTests
//
//  Created by Felipe Docil on 28/05/2019.
//

import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib
import SnapshotTesting

extension SwiftTestCodeGeneratorTests {
    func testItGeneratesTheCorrectCodeWithAnOutlineScenarioAndASimpleScenario() {
        let examples = [Example(values: ["key1": "value1", "key2": "value2"]),
                        Example(values: ["key1": "value3", "key2": "value4"])]
        
        let scenarioOutline: Gherkin.Scenario = .outline(ScenarioOutline(name: "Scenario I want to test",
                                                                  description: "",
                                                                  steps:[Step(name: .given, text: "I'm in a situation"),
                                                                         Step(name: .when, text: "Something happens <key1>"),
                                                                         Step(name: .then, text: "Something else happens <key2>")],
                                                                  examples: examples))
        
        let scenarioSimple: Gherkin.Scenario = .simple(ScenarioSimple(name: "Simple Scenario I want to test",
                                                                      description: "",
                                                                      steps: [Step(name: .given, text: "I'm in a situation"),
                                                                              Step(name: .when, text: "Something simple happens")]))
        
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenarioOutline, scenarioSimple])
        
        assertSnapshot(matching: textFromFeature(feature), as: .lines)
    }
    
    func testAnotherTemplateThatUsesExampleStepParameter() {
        let path = "testPath"
        
        try! """
        import XCTest

        /**
        Feature:
        {{ feature.description }}
        */

        class {{ feature.name }}FeatureTest: {{ classType }} {
            {% for scenario in feature.scenarios %}
            {% if scenario.examples.count > 0 %}
            {% for example in scenario.examples %}
            func testScenario_{{ scenario.name }}_{{ example.valuesDescription }}() {
                {% for step in example.steps %}
                stepDefiner.step{{ step.name }}({% if step.parameters.count > 0 %}{% for parameter in step.parameters %}{{parameter.key}}: "{{parameter.value}}"{% if not forloop.last %},{% endif %}{% endfor %}{% endif %})
                {% endfor %}
            }
            {% endfor %}
            {% else %}
            func testScenario_{{ scenario.name }}() {
                {% for step in scenario.steps %}
                stepDefiner.step{{ step.name }}()
                {% endfor %}
            }
            {% endif %}
            {% endfor %}
        }
        """.write(toFile: path, atomically: false, encoding: .utf8)
        
        let scenarioSimple: Gherkin.Scenario = .simple(ScenarioSimple(name: "I want a simple test",
                                                                description: "",
                                                                steps:[Step(name: .given, text: "I'm in a situation"),
                                                                       Step(name: .when, text: "Something happens")] ))
        
        let examples = [Example(values: ["a": "testA", "b": "situationA"]),
                        Example(values: ["a": "testB", "b": "situationB"])]
        
        let scenarioOutline: Gherkin.Scenario = .outline(ScenarioOutline(name: "I want a complex test",
                                                                         description: "",
                                                                         steps:[Step(name: .given, text: "I'm in a situation"),
                                                                                Step(name: .when, text: "Something <a> happens"),
                                                                                Step(name: .then, text: "<b> just happened")],
                                                                         examples: examples))
        let feature = Feature(name: "Number one",
                              description: "",
                              scenarios: [scenarioSimple, scenarioOutline])
        
        assertSnapshot(matching: textFromFeature(feature, templateFilePath: path), as: .lines)
        
        try? FileManager.default.removeItem(atPath: path)
    }
}
