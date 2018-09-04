//
//  String+CamelCased.swift
//  CapriccioLib
//
//  Created by Franco on 04/09/2018.
//

extension String {
    func camelCased(upper: Bool) -> String {
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
