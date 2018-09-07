//
//  FeatureFilesWriter.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

public final class SwiftTestsFilesWriter {
    let swiftCodeGenerator: SwiftTestCodeGenerating
    
    private let singleFileName = "FeaturesUITests.swift"
    
    public init(swiftCodeGenerator: SwiftTestCodeGenerating = SwiftTestCodeGenerator()) {
        self.swiftCodeGenerator = swiftCodeGenerator
    }
    
    public func writeSwiftTest(fromFeatures features: [Feature], inFolder folderPath: String, generatedClassType: String?, useSingleFile: Bool) {
        
        let featuresCode = features.map { swiftCodeGenerator.generateSwiftTestCode(forFeature: $0, generatedClassType: generatedClassType) }
        
        if useSingleFile {
            writeSingleFile(fromFeaturesCode: featuresCode, folderPath: folderPath)
        }
        else {
            writeFeatureFiles(fromFeaturesCode: featuresCode, features: features, folderPath: folderPath)
        }
    }
    
    private func writeSingleFile(fromFeaturesCode featuresCode: [String], folderPath: String) {
        let singleFileCode = featuresCode.joined(separator: "\n\n")
        let singleFilePath = folderPath.appending("/" + singleFileName)
        
        do {
            try singleFileCode.write(toFile: singleFilePath, atomically: false, encoding: .utf8)
        } catch {
            print("Unable to save the generated UI Tests file, error: \(error)")
        }
    }
    
    private func writeFeatureFiles(fromFeaturesCode featuresCode: [String], features: [Feature], folderPath: String) {
        for i in 0..<features.count {
            let code = featuresCode[i]
            let feature = features[i]
            
            let featureFilePath = folderPath.appending("/" + feature.name.withoutNotAllowedCaractersAndCamelCased(upper: true) + ".swift")
            do {
                try code.write(toFile: featureFilePath, atomically: false, encoding: .utf8)
            } catch {
                print("Unable to save the feature \"\(feature.name.withoutNotAllowedCaractersAndCamelCased(upper: true))\", error: \(error)")
            }
        }
    }
}
