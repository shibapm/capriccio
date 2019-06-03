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
    
    var feature1: Feature {
        return Feature(fileName: "FeatureOne",
                       description: "Feature number one",
                       name: "FeatureNumberOne",
                       scenarios: [],
                       tags: [])
    }
    
    var feature2: Feature {
        return Feature(fileName: "FeatureTwo",
                       description: "Feature number two",
                       name: "FeatureNumberTwo",
                       scenarios: [],
                       tags: [])
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
        
        let filePath = self.filePath(forFeature: feature1)
        
        generatedFilesPaths.append(filePath)
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1, generatedClassType: generatedClassType, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
    }
    
    func testItPassesTheTemplatePathToTheCodeGenerator() {
        let templatePath = "test"
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: true, templateFilePath: templatePath, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forFeature: feature1)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1, generatedClassType: nil, templateFilePath: templatePath, disableSwiftLint: true, version: "1.0.0")))
    }
    
    func testItWritesTheCorrectFileForAFeature() {
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1], inFolder: testFolder, generatedClassType: nil,  disableSwiftLint: true, templateFilePath: nil, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forFeature: feature1)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
    }
    
    func testItWritesTheCorrectFileForMultipleFeatures() {
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature1, feature2], inFolder: testFolder, generatedClassType: nil, disableSwiftLint: true, templateFilePath: nil, useSingleFile: false, version: "1.0.0")
        
        let filePath = self.filePath(forFeature: feature1)
        generatedFilesPaths.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature1, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
        
        let file2Path = self.filePath(forFeature: feature2)
        generatedFilesPaths.append(file2Path)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature2, generatedClassType: nil, templateFilePath: nil, disableSwiftLint: true, version: "1.0.0")))
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
    
    private func filePath(forFeature feature: CapriccioLib.Feature) -> String {
        let fileName = feature.fileName ?? feature.name
        return testFolder + "/" + fileName.validEntityName() + "UITests.generated.swift"
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
        
        let filePath = singleFile ? testFolder + "/FeaturesUITests.swift" : self.filePath(forFeature: feature1)
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
        callstack.record(.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType, templateFilePath: templateFilePath, disableSwiftLint: disableSwiftLint, version: "1.0.0"))
        return result
    }
}

private class SpyCodeWriting: CodeWriting, TestSpy {
    enum Method: Equatable {
        case write(code: String, featureFilePath: String)
    }
    
    var callstack: CallstackContainer<Method> = CallstackContainer()
    
    func write(code: String, toFile featureFilePath: String) {
        callstack.record(.write(code: code, featureFilePath: featureFilePath))
    }
}

