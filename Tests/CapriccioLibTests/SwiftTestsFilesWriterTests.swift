//
//  SwiftTestsFilesWriterTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 04/09/2018.
//

import XCTest
import Foundation
import Nimble
import TestSpy
@testable import CapriccioLib

final class SwiftTestsFilesWriterTests: XCTestCase {
    private var swiftTestsFilesWriter: SwiftTestsFilesWriter!
    private var stubbedSwiftTestCodeGenerating: StubbedSwiftTestCodeGenerating!
    
    let testFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                         .userDomainMask, true).first! + "/"
    
    var generatedFilesPaths: [String]!
    
    let testContent = "Test Code"
    
    var feature1: Metadata {
        let feature = Feature(description: "Feature number one",
                              name: "FeatureNumberOne",
                              scenarios: [],
                              tags: [])
        return Metadata(fileName: "FeatureOne", path: "", feature: feature)
    }
    
    var feature2: Metadata {
        let feature = Feature(description: "Feature number two",
                              name: "FeatureNumberTwo",
                              scenarios: [],
                              tags: [])
        return Metadata(fileName: "FeatureTwo", path: "", feature: feature)
    }
    
    override func setUp() {
        super.setUp()
        generatedFilesPaths = []
        
        stubbedSwiftTestCodeGenerating = StubbedSwiftTestCodeGenerating()
        stubbedSwiftTestCodeGenerating.result = testContent
        swiftTestsFilesWriter = SwiftTestsFilesWriter(swiftCodeGenerator: stubbedSwiftTestCodeGenerating)
    }
    
    override func tearDown() {
        stubbedSwiftTestCodeGenerating = nil
        swiftTestsFilesWriter = nil
        generatedFilesPaths.forEach { try? FileManager.default.removeItem(atPath: $0) }
        super.tearDown()
    }
    
    func testItPassesTheGeneratedClassTypeToTheCodeGenerator() {
        let generatedClassType = "ClassType"
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: generatedClassType, disableSwiftLint: true, templateFilePath: nil, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forName: feature1.fileName)
        generatedFilesPaths.append(filePath)
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1.feature, generatedClassType: generatedClassType, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
    }
    
    func testItPassesTheTemplatePathToTheCodeGenerator() {
        let templatePath = "test"
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: true, templateFilePath: templatePath, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forName: feature1.fileName)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1.feature, generatedClassType: nil, templateFilePath: templatePath, disableSwiftLint: true, version: "1.0.0")))
    }
    
    func testItWritesTheCorrectFileForAFeature() {
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: nil,  disableSwiftLint: true, templateFilePath: nil, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forName: feature1.fileName)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1.feature, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
    }
    
    func testItWritesTheCorrectFileForMultipleFeatures() {
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1, feature2], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: true, templateFilePath: nil, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forName: feature1.fileName)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1.feature, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
        
        let file2Path = self.filePath(forName: feature2.fileName)
        generatedFilesPaths.append(file2Path)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature2.feature, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
        expect(FileManager.default.fileExists(atPath: file2Path)) == true
        expect(try? String(contentsOfFile: file2Path)) == testContent
    }
    
    func testItWritesTheCorrectFileForMultipleFeaturesOnSingleFile() {
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1, feature2], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: false, templateFilePath: nil, useSingleFile: true, version: "1.0.0")
        
        let filePath = testFolder + "/FeaturesUITests.generated.swift"
        generatedFilesPaths.append(filePath)
        
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent + "\n\n" + testContent
    }
    
    private func filePath(forName name: String) -> String {
        return testFolder + name + "UITests.generated.swift"
    }
}

extension SwiftTestsFilesWriterTests {
    func testItDoesnReWriteAFileIfItExistsAndHasTheSameContent() {
        checkItDoesntReWriteAFileIfItExistsAndHasTheSameContent(singleFile: false)
    }
    
    func testItDoesnReWriteAFileIfItExistsAndHasTheSameContentAndSingleFile() {
        checkItDoesntReWriteAFileIfItExistsAndHasTheSameContent(singleFile: true)
    }
    
    private func checkItDoesntReWriteAFileIfItExistsAndHasTheSameContent(singleFile: Bool) {
        let codeWriter = SpyCodeWriting()
        swiftTestsFilesWriter = SwiftTestsFilesWriter(swiftCodeGenerator: stubbedSwiftTestCodeGenerating, codeWriter: codeWriter)
        
        let filePath = singleFile ? testFolder + "/FeaturesUITests.swift" : self.filePath(forName: feature1.fileName)
        generatedFilesPaths.append(filePath)
        
        try? testContent.write(toFile: filePath, atomically: false, encoding: .utf8)
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: true, templateFilePath: nil, useSingleFile: singleFile, version: "1.0.0")
        
        expect(codeWriter).toNot(haveReceived(.write(code: testContent, featureFilePath: filePath)))
    }
}


private class StubbedSwiftTestCodeGenerating: SwiftTestCodeGenerating, TestSpy  {
    var result: String!
    
    enum Method: Equatable {
        case generateSwiftTestCode(forFeature: Feature, generatedClassType: String?, templateFilePath: String?, disableSwiftLint: Bool, version: String)
    }
    
    var callstack = CallstackContainer<Method>()
    
    func generateSwiftTestCode(forFeature feature: Feature, generatedClassType: String?, templateFilePath: String?, disableSwiftLint: Bool, version: String) -> String {
        callstack.record(.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint, version: version))
        return result
    }
}

private class SpyCodeWriting: CodeWriting, TestSpy {
    enum Method: Equatable {
        case write(code: String, featureFilePath: String)
        case writeAndCreate(code: String, toFile: String, toDirectory: String)
    }
    
    var callstack: CallstackContainer<Method> = CallstackContainer()
    
    func write(code: String, toFile featureFilePath: String) {
        callstack.record(.write(code: code, featureFilePath: featureFilePath))
    }
    
    func writeAndCreate(code: String, toFile filePath: String, toDirectory directoryPath: String) {
        callstack.record(.writeAndCreate(code: code, toFile: filePath, toDirectory: directoryPath))
    }
}

