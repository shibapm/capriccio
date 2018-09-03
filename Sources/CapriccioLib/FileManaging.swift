//
//  FileManaging.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation

protocol FileManaging {
    func contentsOfDirectory(atPath path: String) throws -> [String]
}

extension FileManager: FileManaging {}


