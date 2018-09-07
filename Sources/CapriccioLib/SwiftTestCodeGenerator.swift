//
//  SwiftTestFileGenerator.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin
import Stencil

public protocol SwiftTestCodeGenerating {
    func generateSwiftTestCode(forFeature feature: Feature, generatedClassType: String?, disableSwiftLint: Bool) -> String
}

public final class SwiftTestCodeGenerator: SwiftTestCodeGenerating {
    public init() { }
    
    public func generateSwiftTestCode(forFeature feature: Feature, generatedClassType: String?, disableSwiftLint: Bool) -> String {
        let template = Template(templateString: templateString)
        let generatedClassType = generatedClassType ?? "XCTestCase"
        
        do {
            return try template.render(["feature": feature.dictionary, "classType": generatedClassType, "disableSwiftLint": disableSwiftLint])
        }
        catch {
            fatalError("Template file rendering failed with error \(error)")
        }
    }
}

/// Simple way of embedding the template given SPM doesn't support resources files yet
private let templateString = """
import XCTest
import XCTest_Gherkin

{% if disableSwiftLint %}
// swiftlint:disable all
{% endif %}
final class {{ feature.className }}: {{ classType }} {
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
    func test{{ scenario.methodName }}() {
        {% for step in scenario.steps%}
        {{ step.swiftText }}
        {% endfor %}
    }
    {% endif %}
    {% endfor %}
}
{% if disableSwiftLint %}
// swiftlint:enable all
{% endif %}
"""
