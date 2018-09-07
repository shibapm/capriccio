//
//  SwiftTestsFilesWriterTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 04/09/2018.
//

import XCTest
import Foundation
import Nimble
import Gherkin
import TestSpy
@testable import CapriccioLib

final class SwiftTestsFilesWriterTests: XCTestCase {
    private var swiftTestsFilesWriter: SwiftTestsFilesWriter!
    private var stubbedSwiftTestCodeGenerating: StubbedSwiftTestCodeGenerating!
    
    let testFolder = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                         .userDomainMask, true).first!
    
    var generatedFilesPaths: [String]!
    
    let testContent = "Test Code"
    
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
        generatedFilesPaths?.forEach { try? FileManager.default.removeItem(atPath: $0) }
        super.tearDown()
    }
    
    func testItPassesTheGeneratedClassTypeToTheCodeGenerator() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        let generatedClassType = "ClassType"
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature], inFolder: testFolder, generatedClassType: generatedClassType, useSingleFile: false)
        
        let filePath = self.filePath(forFeature: feature)
        generatedFilesPaths?.append(filePath)
        
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType)))
    }
    
    func testItWritesTheCorrectFileForAFeature() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature], inFolder: testFolder, generatedClassType: nil, useSingleFile: false)
        
        let filePath = self.filePath(forFeature: feature)
        generatedFilesPaths?.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature, generatedClassType: nil)))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
    }
    
    func testItWritesTheCorrectFileForMultipleFeatures() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        let feature2 = Feature(name: "Feature number two",
                              description: "",
                              scenarios: [])
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature, feature2], inFolder: testFolder, generatedClassType: nil, useSingleFile: false)
        
        let filePath = self.filePath(forFeature: feature)
        generatedFilesPaths?.append(filePath)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature, generatedClassType: nil)))
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent
        
        let file2Path = self.filePath(forFeature: feature2)
        generatedFilesPaths?.append(file2Path)
        
        expect(self.stubbedSwiftTestCodeGenerating).to(haveReceived(.generateSwiftTestCode(forFeature: feature2, generatedClassType: nil)))
        expect(FileManager.default.fileExists(atPath: file2Path)) == true
        expect(try? String(contentsOfFile: file2Path)) == testContent
    }
    
    func testItWritesTheCorrectFileForMultipleFeaturesOnSingleFile() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        let feature2 = Feature(name: "Feature number two",
                               description: "",
                               scenarios: [])
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature, feature2], inFolder: testFolder, generatedClassType: nil, useSingleFile: true)
        
        let filePath = testFolder + "/FeaturesUITests.swift"
        generatedFilesPaths?.append(filePath)
        
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == testContent + "\n\n" + testContent
    }
    
    private func filePath(forFeature feature: Feature) -> String {
        return testFolder + "/" + feature.name.withoutNotAllowedCaractersAndCamelCased(upper: true) + ".swift"
    }
}

private class StubbedSwiftTestCodeGenerating: SwiftTestCodeGenerating, TestSpy  {
    var result: String!
    
    enum Method: Equatable {
        case generateSwiftTestCode(forFeature: Feature, generatedClassType: String?)
    }
    
    var callstack = CallstackContainer<Method>()
    
    func generateSwiftTestCode(forFeature feature: Feature, generatedClassType: String?) -> String {
        callstack.record(.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType))
        return result
    }
}

extension Feature: Equatable { }

public func == (lhs: Feature, rhs: Feature) -> Bool {
    return lhs.name == rhs.name
}
