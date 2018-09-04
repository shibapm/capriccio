//
//  Gherkin+SwiftCode.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

extension Feature {
    var className: String {
        return name.camelCased(upper: true)
    }
    
    var dictionary: [String:Any] {
        return ["className": className,
                "scenarios": scenarios.map { $0.dictionary }]
    }
}

extension Scenario {
    var methodName: String {
        return name.camelCased(upper: false)
    }
    
    var dictionary: [String:Any] {
        return ["methodName": methodName,
                "steps": steps.map { $0.dictionary }]
    }
}

extension Step {
    var swiftText: String {
        return name.rawValue.capitalized + "(\"" + text + "\")"
    }
    
    var dictionary: [String:Any] {
        return ["swiftText": swiftText]
    }
}


fileprivate extension String {
    fileprivate func camelCased(upper: Bool) -> String {
        let words = self.split(separator: " ")
        return words.map { word in
            if !upper && word == words[0] {
                return word.lowercased()
            } else {
                return word.capitalized
            }
        }.joined()
    }
}
