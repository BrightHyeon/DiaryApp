//
//  Diary.swift
//  DiaryApp
//
//  Created by HyeonSoo Kim on 2021/12/21.
//

import Foundation

struct Diary {
    var uuidString: String //객체에 고유값 부여하기 위한 uuid프로퍼티.
    var title: String //제목 저장
    var contents: String //내용 저장
    var date: Date //날짜 저장
    var isStar: Bool //즐겨찾기 여부
}
