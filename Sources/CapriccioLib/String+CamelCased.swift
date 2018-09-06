//
//  String+CamelCased.swift
//  CapriccioLib
//
//  Created by Franco on 04/09/2018.
//

extension String {
    func withoutNotAllowedCaractersAndCamelCased(upper: Bool) -> String {
        let string = self.replacingOccurrences(of: "([^A-Za-z0-9 ]*)", with: "", options:.regularExpression)
        let words = string.split(separator: " ")
        return words.map { word in
            if !upper && word == words[0] {
                return word.lowercased()
            } else {
                return word.capitalized
            }
            }.joined()
    }
}
