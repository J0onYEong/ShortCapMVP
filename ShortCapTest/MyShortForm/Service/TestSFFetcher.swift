//
//  TestSFFetcher.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class TestSFFetcher: SFFetcher {
    
    let dummyData: [SFModel] = [
        SFModel(
            uuid: "1",
            title: "유튜브 쇼츠 더미1",
            description: "더미객체1의 설명입니다.",
            keywords: ["키워드1", "키워드2", "키워드3"],
            url: "https://youtube.com/shorts/e5jsSi_aKmM?si=vRUkRp2utJV00Vbt",
            summary: "더미객체1의 요약입니다.",
            address: "더미객체1의 주소입니다.",
            createdAt: "2024-03-03T20:00:00.000",
            isFetched: true
        ),
        SFModel(
            uuid: "2",
            title: "인스타 릴스 더미2",
            description: "더미객체2의 설명입니다.",
            keywords: ["키워드1", "키워드2", "키워드3"],
            url: "https://www.instagram.com/reel/C3bm6JNPwbW/?utm_source=ig_web_copy_link",
            summary: "더미객체2의 요약입니다.",
            address: "더미객체2의 주소입니다.",
            createdAt: "2024-03-03T20:00:00.000",
            isFetched: true
        ),
        SFModel(
            uuid: "3",
            title: nil,
            description: nil,
            keywords: nil,
            url: "https://youtube.com/shorts/BjjtDjkSlRo?si=Mt_4Sh6L8_tJu-z3",
            summary: nil,
            address: nil,
            createdAt: nil,
            isFetched: false
        ),
        SFModel(
            uuid: "4",
            title: nil,
            description: nil,
            keywords: nil,
            url: "https://www.instagram.com/reel/C1odCzdSpNr/?utm_source=ig_web_copy_link",
            summary: nil,
            address: nil,
            createdAt: nil,
            isFetched: false
        )
    ]
    
    func getSFModels(completion: @escaping (Result<[SFModel], Error>) -> Void) {
        
        completion(.success(dummyData))
    }
}
