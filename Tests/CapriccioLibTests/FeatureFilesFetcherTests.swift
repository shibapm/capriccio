//
//  FeatureFilesFetcherTests.swift
//  CapriccioTests
//
//  Created by Franco on 03/09/2018.
//

import XCTest
import Nimble
import TestSpy
@testable import CapriccioLib

final class FeatureFilesFetcherTests: XCTestCase {
    var mockFileManager: MockFileManager!
    var featureFilesFetcher: FeatureFilesFetcher!
    
    override func setUp() {
        super.setUp()
        mockFileManager = MockFileManager()
        featureFilesFetcher = FeatureFilesFetcher(fileManager: mockFileManager)
    }
    
    override func tearDown() {
        mockFileManager = nil
        featureFilesFetcher = nil
        super.tearDown()
    }
    
    func testItCallsTheFileManagerWithTheCorrectPath() {
        let testPath = "testPath"
        mockFileManager.subpathsOfDirectoryResult = []
        _ = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(self.mockFileManager).to(haveReceived(.subpathsOfDirectory(path: testPath)))
    }
    
    func testItReturnsTheFoundYAMLFiles() {
        let yamlFiles = [".capriccio.yml"]
        mockFileManager.contentOfDirectoryResult = yamlFiles
        let result = featureFilesFetcher.yamlFile()
        expect(result) == yamlFiles.map { "./" + $0 }.first
    }
    
    func testItReturnsTheFoundFeatureFiles() {
        let testPath = "testPath"
        let featureFiles = ["file1.feature",
                            "file2.feature",
                            "file3.feature"]
        mockFileManager.subpathsOfDirectoryResult = featureFiles
        let result = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(result) == featureFiles.map { $0 }
    }
    
    func testItFiltersOutTheNotFeatureFiles() {
        let testPath = "testPath"
        let featureFiles = ["file1.feature",
                            "file2.feature",
                            "file3.feature"]
        var files = ["/file4.jpg"]
        files.append(contentsOf: featureFiles)
        mockFileManager.subpathsOfDirectoryResult = files
        let result = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(result) == featureFiles.map { $0 }
    }
}
