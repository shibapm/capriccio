//
//  Gherkin+SwiftCode.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

extension Feature {
    var className: String {
        return name.withoutNotAllowedCaractersAndCamelCased(upper: true)
    }
    
    var dictionary: [String:Any] {
        return ["className": className,
                "scenarios": scenarios.map { $0.dictionary }]
    }
}

extension Scenario {
    var methodName: String {
        return name.withoutNotAllowedCaractersAndCamelCased(upper: true)
    }
    
    var dictionary: [String:Any] {
        var result: [String:Any] = ["methodName": methodName]
        
        switch self {
        case .simple:
            result["steps"] = steps.map { $0.dictionary }
        case .outline:
            result["examples"] = examples?.map { $0.dictionary } ?? [:]
            result["examplesCountForIteration"] = (examples?.count ?? 0) - 1 // Stencil doens't support - operator
            
            let examplesSteps = examples?.map {
                example in steps.map { step in
                    step.createDictionary(forExample: example)
                }
            }
            result["examplesSteps"] = examplesSteps
        }
        
        return result
    }
}

extension Step {
    var dictionary: [String:Any] {
        return createDictionary(forExample: nil)
    }
    
    func createDictionary(forExample example: Example?) -> [String:Any] {
        var text: String
        if let example = example {
            text = example.values.reduce(self.text) { $0.replacingOccurrences(of: "<" + $1.key + ">", with: $1.value)  }
        } else {
            text = self.text
        }
        
        return ["swiftText": swiftText(fromText: text)]
    }
    
    private func swiftText(fromText text: String) -> String {
        return stepName + "(\"" + text + "\")"
    }
    
    // But is not handled by XCTest_Gherkin. And is the closest stap name that we can use
    private var stepName: String {
        switch name {
        case .but:
            return "And"
        default:
            return name.rawValue.capitalized
        }
    }
}

extension Example {
    var methodNameExamplePart: String {
        return values.reduce("") { (result, item) -> String in
            let (_, value) = item
            var result = result
            
            if !result.isEmpty {
                result += "And"
            }

            
            result += value.withoutNotAllowedCaractersAndCamelCased(upper: true)
            return result
        }
    }
    
    var dictionary: [String:Any] {
        return ["values": values,
                "methodNameExamplePart": methodNameExamplePart]
    }
}
