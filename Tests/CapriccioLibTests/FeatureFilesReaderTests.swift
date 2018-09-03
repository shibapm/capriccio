//
//  FeatureFilesReaderTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 03/09/2018.
//

import XCTest
import Foundation
import Nimble
@testable import CapriccioLib

final class FeatureFilesReaderTests: XCTestCase {
    let testFile1Path = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                            .userDomainMask, true).first! + "test1.feature"
    let testFile2Path = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                            .userDomainMask, true).first! + "test2.feature"
    
    var featureFilesReader: FeatureFilesReader!
    
    override func setUp() {
        super.setUp()
        featureFilesReader = FeatureFilesReader()
    }
    
    override func tearDown() {
        featureFilesReader = nil
        try? FileManager.default.removeItem(atPath: testFile1Path)
        try? FileManager.default.removeItem(atPath: testFile2Path)
        super.tearDown()
    }
    
    func testItCanReadSingleFeatureFile() {
        try! testFeatureFile1Content().write(toFile: testFile1Path, atomically: true, encoding: .utf8)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path])
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].name) == "Test Scenario"
    }
    
    func testItCanReadMultipleFeatureFiles() {
        try! testFeatureFile1Content().write(toFile: testFile1Path, atomically: true, encoding: .utf8)
        try! testFeatureFile2Content().write(toFile: testFile2Path, atomically: true, encoding: .utf8)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path])
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].name) == "Test Scenario"
        expect(featureFiles[1].name) == "Test Scenario 2"
    }
    
    private func testFeatureFile1Content() -> String {
        return """
        Feature: Test Scenario

        Scenario: test scenario
        Given I have to do a test
        And I'm a developer
        """
    }
    
    private func testFeatureFile2Content() -> String {
        return """
        Feature: Test Scenario 2
        
        Scenario: test scenario 2
        Given I have to do another test
        And I'm the same developer i was before
        """
    }
}
