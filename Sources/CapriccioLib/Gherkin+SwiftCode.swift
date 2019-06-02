//
//  Gherkin+SwiftCode.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

/**
 description: Following text after `Feature:`
 name: description but without space and uppercased
 scenarios: List of Scenario
 tags: list of tags on that Feature
 */
public struct Feature: Encodable, Equatable {
    var description: String
    var name: String
    var scenarios: [Scenario]
    var tags: [Tag]
    
    init(gherkinFeature: Gherkin.Feature) {
        description = gherkinFeature.name
        name = gherkinFeature.name.validEntityName()
        scenarios = gherkinFeature.scenarios.compactMap(Scenario.init)
        tags = gherkinFeature.tags?.compactMap(Tag.init) ?? []
    }
    
    init(description: String, name: String, scenarios: [Scenario], tags: [Tag]) {
        self.description = description
        self.name = name
        self.scenarios = scenarios
        self.tags = tags
    }
}

/**
 description: Following text after `Scenario:` or `Scenario Outline:`
 name: description but without space and uppercased
 steps: List of steps
 tags: List of tags on that scenario
 examples: List of examples if it's a scenario outline
 */
public struct Scenario: Encodable, Equatable {
    var description: String
    var name: String
    var steps: [Step]
    var tags: [Tag]
    var examples: [Example]
    
    init(gherkinScenario: Gherkin.Scenario) {
        description = gherkinScenario.name
        name = gherkinScenario.name.validEntityName()
        tags = gherkinScenario.tags?.compactMap(Tag.init) ?? []
        let steps = gherkinScenario.steps.compactMap(Step.init)
        
        let examples: [Example] = (gherkinScenario.examples?.compactMap(Example.init) ?? []).compactMap { example in
            var exampleCopy = example
            for step in steps {
                exampleCopy.replaceDescriptionKeyword(on: step)
            }
            return exampleCopy
        }
        
        self.examples = examples
        self.steps = steps
    }
}

/**
 type: Given, When, Then, And, But
 description: Following text after `type`
 descriptionReplaceKeyword: description but if it is an example replaced all keywords for respective value
 name: description but without space and uppercased
 */
public struct Step: Encodable, Equatable {
    var type: String
    var description: String
    var name: String
    var parameters: [Parameter] = []
    
    init(gherkinStep: Gherkin.Step) {
        switch gherkinStep.name {
        case .but:
            type = "And"
        default:
            type = gherkinStep.name.rawValue.validEntityName()
        }
        
        description = gherkinStep.text
        name = gherkinStep.text.validEntityName()
    }
}

/**
 values: Array of value, where key is the first element on a table on .feature file
 valuesDescription: all values capitalized joined in a string, using "And" as separator.
 steps: List of steps that uses this Example
 */
public struct Example: Encodable, Equatable {
    var valuesDescription: String
    var values: [String: String]
    var steps: [Step] = []
    
    init(gherkinExample: Gherkin.Example) {
        values = gherkinExample.values
        
        let allValues = gherkinExample.values.sorted(by: { $0.0 < $1.0 }).compactMap { $0.value.validEntityName() }
        valuesDescription = allValues.joined(separator: "And")
    }
    
    mutating func replaceDescriptionKeyword(on step: Step) {
        var step = step
        
        var text = step.description
        var parameters: [Parameter] = []
        
        let sortedDictionary = values.sorted(by: {$0.0 < $1.0 })
        for (key, value) in sortedDictionary {
            if step.description.contains("<\(key)>") {
                text = step.description.replacingOccurrences(of: "<\(key)>", with: value)
                parameters.append(Parameter(key: key, value: value))
            }
        }
        
        step.description = text
        step.parameters = parameters
        
        steps.append(step)
    }
}

/**
 name: Following text after `@`
 */
public struct Tag: Encodable, Equatable {
    var name: String

    init(gherkinTag: Gherkin.Tag) {
        name = gherkinTag.name
    }
    
    init(name: String) {
        self.name = name
    }
}

/**
 key: key of a Data Table
 value: value of a Data Table
 */
struct Parameter: Encodable, Equatable {
    var key: String
    var value: String
}
