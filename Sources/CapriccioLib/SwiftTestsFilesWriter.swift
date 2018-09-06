//
//  FeatureFilesWriter.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

public final class SwiftTestsFilesWriter {
    let swiftCodeGenerator: SwiftTestCodeGenerating
    
    public init(swiftCodeGenerator: SwiftTestCodeGenerating = SwiftTestCodeGenerator()) {
        self.swiftCodeGenerator = swiftCodeGenerator
    }
    
    public func writeSwiftTest(fromFeatures features: [Feature], inFolder folderPath: String, generatedClassType: String?) {
        features.forEach { feature in
            let code = swiftCodeGenerator.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType)
            let featureFilePath = folderPath.appending("/" + feature.name.withoutNotAllowedCaractersAndCamelCased(upper: true) + ".swift")
            do {
                try code.write(toFile: featureFilePath, atomically: false, encoding: .utf8)
            } catch {
                print("Unable to save the feature \"\(feature.name.withoutNotAllowedCaractersAndCamelCased(upper: true))\", error: \(error)")
            }
        }
    }
}
