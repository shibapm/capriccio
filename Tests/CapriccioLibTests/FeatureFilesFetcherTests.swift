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
        mockFileManager.contentOfDirectoryResult = []
        _ = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(self.mockFileManager).to(haveReceived(.contentsOfDirectory(path: testPath)))
    }
    
    func testItReturnsTheFoundFeatureFiles() {
        let testPath = "testPath"
        let featureFiles = ["file1.feature",
                            "file2.feature",
                            "file3.feature"]
        mockFileManager.contentOfDirectoryResult = featureFiles
        let result = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(result) == featureFiles.map { testPath + "/" + $0 }
    }
    
    func testItFiltersOutTheNotFeatureFiles() {
        let testPath = "testPath"
        let featureFiles = ["file1.feature",
                            "file2.feature",
                            "file3.feature"]
        var files = ["/file4.jpg"]
        files.append(contentsOf: featureFiles)
        mockFileManager.contentOfDirectoryResult = files
        let result = featureFilesFetcher.featureFiles(atPath: testPath)
        expect(result) == featureFiles.map { testPath + "/" + $0 }
    }
}
