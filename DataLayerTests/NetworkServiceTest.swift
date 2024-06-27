//
//  DataLayerTests.swift
//  DataLayerTests
//
//  Created by 최준영 on 6/8/24.
//

import XCTest
@testable import Data

final class NetworkServiceTest: XCTestCase {
    
    let config = TestNetworkConfiguration()
    let credential = TestAuthCredential()
    
    lazy var networkService = DefaultNetworkDataSource(
        configuration: config,
        credential: credential
    )
    
    lazy var api = ShortcapAPI(
        configuration: config,
        credential: credential
    )

    
    // MARK: - Video summary
    func testVideoSummary() throws {
        
        let expectation1 = expectation(description: "Initiating video summary")
        
        let dto = RawVideoInformationDTO(
            url: "https://youtube.com/shorts/JT7x05YNSIo?si=CwMj1ijaMJj0xZqR",
            categoryId: nil,
            categoryIncluded: false
        )
        
        let requestable = api.initiateSummary(
            videoInformation: dto
        )
        
        var videoCode = ""
        
        networkService
            .request(requestConvertible: requestable) { result in
                
                switch result {
                case .success(let success):
                    
                    print(success)
                    
                    let temp = success.data?.videoCode
                    
                    XCTAssertNotNil(temp)
                    
                    videoCode = temp!
                    
                    expectation1.fulfill()
                case .failure(let failure):
                    
                    XCTFail(failure.localizedDescription)
                    
                    expectation1.fulfill()
                }
            }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        let expectation2 = expectation(description: "Check Summary Is Finished")
        
        let requestable2 = api.fetchVideoSummaryState(videoCode: videoCode)
        
        networkService
            .request(requestConvertible: requestable2) { result in
                
                switch result {
                case .success(let success):
                    
                    print(success)
                    
                    let id = success.data?.videoSummaryId
                    
                    XCTAssertNotNil(id)
                    
                    print("video id: \(id!)")
                    
                    expectation2.fulfill()
                case .failure(let failure):
                    
                    XCTFail(failure.localizedDescription)
                    
                    expectation2.fulfill()
                }
            }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
    }
    
    func testTokenIsAvailable() throws {
        
        
    }

}

