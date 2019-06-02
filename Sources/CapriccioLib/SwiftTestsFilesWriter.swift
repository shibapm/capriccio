//
//  FeatureFilesWriter.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Gherkin

public final class SwiftTestsFilesWriter {
    let swiftCodeGenerator: SwiftTestCodeGenerating
    let codeWriter: CodeWriting
    
    private let singleFileName = "FeaturesUITests.swift"
    
    public init(swiftCodeGenerator: SwiftTestCodeGenerating = SwiftTestCodeGenerator(),
                codeWriter: CodeWriting = CodeWriter()) {
        self.swiftCodeGenerator = swiftCodeGenerator
        self.codeWriter = codeWriter
    }
    
    public func writeSwiftTest(fromFeatures features: [Feature], inFolder folderPath: String, generatedClassType: String?, disableSwiftLint: Bool, templateFilePath: String?, useSingleFile: Bool, version: String) {
        
        let featuresCode = features.map { swiftCodeGenerator.generateSwiftTestCode(forFeature: $0, generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint, version: version) }
        
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
        
        write(code: singleFileCode, toFile: singleFilePath)
    }
    
    private func writeFeatureFiles(fromFeaturesCode featuresCode: [String], features: [Feature], folderPath: String) {
        for i in 0..<features.count {
            let code = featuresCode[i]
            let feature = features[i]
            
            let featureFilePath = folderPath.appending("/" + feature.name.validEntityName() + ".swift")
            write(code: code, toFile: featureFilePath)
        }
    }
    
    private func write(code: String, toFile featureFilePath: String) {
        if let previousCode = try? String(contentsOfFile: featureFilePath),
            previousCode == code {
            return
        }
        
        codeWriter.write(code: code, toFile: featureFilePath)
    }
}

public protocol CodeWriting {
    func write(code: String, toFile featureFilePath: String)
}

public final class CodeWriter: CodeWriting {
    public init() {}
    
    public func write(code: String, toFile featureFilePath: String) {
        do {
            try code.write(toFile: featureFilePath, atomically: false, encoding: .utf8)
        } catch {
            print("Unable to save the generated UI Tests file, error: \(error)")
        }
    }
}
