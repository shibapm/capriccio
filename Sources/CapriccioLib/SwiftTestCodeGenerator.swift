//
//  SwiftTestFileGenerator.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin
import Stencil

final class SwiftTestCodeGenerator {
protocol SwiftTestCodeGenerating {
    func generateSwiftTestCode(forFeature feature: Feature) -> String
}

final class SwiftTestCodeGenerator: SwiftTestCodeGenerating {
    func generateSwiftTestCode(forFeature feature: Feature) -> String {
        let template = Template(templateString: templateString)
        
        do {
            return try template.render(["feature": feature.dictionary])
        }
        catch {
            fatalError("Template file rendering failed with error \(error)")
        }
    }
    
    /// Simple way of embedding the template given SPM doesn't support resources files yet
    let templateString = """
    import XCTest
    import XCTest_Gherkin

    final class {{ feature.className }} {
        {% for scenario in feature.scenarios %}
        {% if scenario.examples.count > 0 %}
        {% for i in 0...scenario.examplesCountForIteration %}
        func {{ scenario.methodName }}With{{ scenario.examples[i].methodNameExamplePart }} {
            {% for step in scenario.examplesSteps[i] %}
            {{ step.swiftText }}
            {% endfor %}
        }
        {% endfor %}
        {% else %}
        func {{ scenario.methodName }} {
            {% for step in scenario.steps%}
            {{ step.swiftText }}
            {% endfor %}
        }
        {% endif %}
        {% endfor %}
    }
    """
}
