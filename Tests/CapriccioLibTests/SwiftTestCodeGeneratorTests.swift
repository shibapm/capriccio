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
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: TestClass {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                Then("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult, generatedClassType: "TestClass")
    }
    
    func testItRemovesNotAllowedCaracters() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                Then("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult)
    }
    
    func testItChangesButToAnd() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                And("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult)
    }
    
    func testItDisablesFileLenghtWarningWhenRequired() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        // swiftlint:disable all
        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                And("Something else happens")
            }
        }
        // swiftlint:enable all
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult, disableSwiftLint: true)
    }
    
    func testItUsesAPassedTemplate() {
        let path = "testPath"
        
        try! """
        import Lib1
        import Lib2

        {{ feature.className }}: {{ classType }} {
        {% for scenario in feature.scenarios %}
        {% if scenario.examples.count > 0 %}
        {% for i in 0...scenario.examplesCountForIteration %}
        func test{{ scenario.methodName }}With{{ scenario.examples[i].methodNameExamplePart }}() {
            {% for step in scenario.examplesSteps[i] %}
            {{ step.swiftText }}
            {% endfor %}
        }
        {% endfor %}
        {% else %}
        {{ scenario.methodName }}() {
            {% for step in scenario.steps%}
            {{ step.swiftText }}
            {% endfor %}
        }
        {% endif %}
        {% endfor %}
        }
        """.write(toFile: path, atomically: false, encoding: .utf8)
        
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import Lib1
        import Lib2

        FeatureNumberOne: XCTestCase {
            ScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                And("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult, templateFilePath: path)
        
        try? FileManager.default.removeItem(atPath: path)
    }
    
    func fileGenerationCheck(feature: Feature, expectedResult: String, generatedClassType: String? = nil, templateFilePath: String? = nil, disableSwiftLint: Bool = false) {
        let text = swiftCodeGenerator.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint)
        expect(self.splittedAndTrimmedStringToTest(fromString: expectedResult)) == splittedAndTrimmedStringToTest(fromString: text)
    }
    
    /// Stencil generates files with a lot of newlines and spaces depending on how is the stancil file written, given the important part to test is the actual generated text instead of the number of newlines and whitespaces, the string is splitted to take just the not empty lines and trimmed to remove the whitespaces
    private func splittedAndTrimmedStringToTest(fromString string: String) -> [String] {
        return string.split(separator: "\n", omittingEmptySubsequences: true).compactMap { let result = String($0).trim(); return result.isEmpty ? nil : result  }
    }
}

fileprivate extension String {
    fileprivate func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
