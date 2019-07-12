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
        var result = removeKeyWords()
        result = result.removeNotValidCharacters()
        return result.upperCamelCased
    }
    
    func removeNotValidCharacters() -> String {
        return replacingOccurrences(of: "([^A-Za-z0-9 ]*)", with: "", options:.regularExpression)
    }
    
    func removeKeyWords() -> String {
        return replacingOccurrences(of: "\\s?<[\\w\\s]*>", with: "", options:.regularExpression)
    }
    
    var upperCamelCased: String {
        let words = split(separator: " ")
        return words.map { word in
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined()
    }
}
