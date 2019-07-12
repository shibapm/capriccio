//
//  FeatureFilesWriter.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Gherkin
import Foundation

public final class SwiftTestsFilesWriter {
    let swiftCodeGenerator: SwiftTestCodeGenerating
    let codeWriter: CodeWriting
    
    private let singleFileName = "FeaturesUITests.generated.swift"
    
    public init(swiftCodeGenerator: SwiftTestCodeGenerating = SwiftTestCodeGenerator(),
                codeWriter: CodeWriting = CodeWriter()) {
        self.swiftCodeGenerator = swiftCodeGenerator
        self.codeWriter = codeWriter
    }
    
    public func writeSwiftTest(fromFeatures metadatas: [Metadata], inFolder folderPath: String, generatedClassType: String?, disableSwiftLint: Bool, templateFilePath: String?, useSingleFile: Bool, version: String) {
        
        let featuresCode = metadatas.map { swiftCodeGenerator.generateSwiftTestCode(forFeature: $0.feature, generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint, version: version) }
        
        if useSingleFile {
            writeSingleFile(fromFeaturesCode: featuresCode, folderPath: folderPath)
        }
        else {
            writeFeatureFiles(fromFeaturesCode: featuresCode, metadatas: metadatas, folderPath: folderPath)
        }
    }
    
    private func writeSingleFile(fromFeaturesCode featuresCode: [String], folderPath: String) {
        let singleFileCode = featuresCode.joined(separator: "\n\n")
        let singleFilePath = folderPath.appending("/" + singleFileName)
        
        write(code: singleFileCode, toFile: singleFilePath)
    }
    
    private func writeFeatureFiles(fromFeaturesCode featuresCode: [String], metadatas: [Metadata], folderPath: String) {
        for (index, metadata) in metadatas.enumerated() {
            let code = featuresCode[index]
            
            let fileName = metadata.fileName
            let output = metadata.path
            let featureFilePath = folderPath.appending("/" + output + fileName + "UITests.generated.swift")
            
            let directory = folderPath.appending("/" + output)
            codeWriter.writeAndCreate(code: code, toFile: featureFilePath, toDirectory: directory)
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
    func writeAndCreate(code: String, toFile filePath: String, toDirectory directoryPath: String)
}

public final class CodeWriter: CodeWriting {
    public init() {}
    
    public func writeAndCreate(code: String, toFile filePath: String, toDirectory directoryPath: String) {
        do {
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            try code.write(toFile: filePath, atomically: false, encoding: .utf8)
        } catch {
            print("Unable to save the generated UI Tests file, error: \(error)")
        }
    }
    
    public func write(code: String, toFile featureFilePath: String) {
        do {
            try code.write(toFile: featureFilePath, atomically: false, encoding: .utf8)
        } catch {
            print("Unable to save the generated UI Tests file, error: \(error)")
        }
    }
}
