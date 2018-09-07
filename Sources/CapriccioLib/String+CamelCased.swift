//
//  String+CamelCased.swift
//  CapriccioLib
//
//  Created by Franco on 04/09/2018.
//

enum ValidEntryNameStringType {
    case `class`
    case feature
    case method
    case example
}

extension String {
    func validEntityName() -> String {
        let result = removeNotValidCharacters()
        return result.upperCamelCased
    }
    
    func removeNotValidCharacters() -> String {
        return replacingOccurrences(of: "([^A-Za-z0-9 ]*)", with: "", options:.regularExpression)
    }
    
    var upperCamelCased: String {
        let words = split(separator: " ")
        return words.map { word in
            return word.capitalized
        }.joined()
    }
}
