//
//  FeatureFilesReader.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Gherkin

final class FeatureFilesReader {    
    func readFiles(atPaths paths: [String]) -> [Feature] {
        let filesContent = paths.compactMap { try? String(contentsOfFile: $0) }
        return filesContent.compactMap { try? Feature($0) }
    }
}
