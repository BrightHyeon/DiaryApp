//
//  DiaryDetailViewController.swift
//  DiaryApp
//
//  Created by HyeonSoo Kim on 2021/12/19.
//

import UIKit

//MARK: - Protocol
//삭제기능을 위한 프로토콜 생성.
//protocol DiaryDetailedViewDelegate: AnyObject {
//    func didSelectDelete(indexPath: IndexPath) //indexPath값을 받음.
//    //func didSelectStar(indexPath: IndexPath, isStar: Bool)
//}

class DiaryDetailViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var starButton: UIBarButtonItem? //즐겨찾기 등록 버튼.?
    //diaryList로부터 Diary객체를 전달받을 준비
    var diary: Diary?
    var indexPath: IndexPath?
    //weak var delegate: DiaryDetailedViewDelegate?
    
    //MARK: - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }
    
    //MARK: - IBAction
    @IBAction func tabEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func tabDeleteButton(_ sender: UIButton) {
        //guard let indexPath = self.indexPath else { return } //오류발생.
        guard let uuidString = self.diary?.uuidString else { return }
        //self.delegate?.didSelectDelete(indexPath: indexPath)
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString, //indexPath,
            userInfo: nil
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Method
    //전달받을 Diary객체를 View에 초기화.
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        //즐겨찾기 버튼 구현 !!
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tabStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    //text에 date전달하기 위한 formatter.
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        //        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diary = diary
        self.configureView()
    }
    //starButton을 눌렀을 때 호출되는 메서드.
    @objc func tabStarButton() {
        guard let isStar = self.diary?.isStar else { return }
        //guard let indexPath = self.indexPath else { return }
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                //"indexPath": indexPath
                "uuidString": diary?.uuidString
            ],
            userInfo: nil
        )
        //self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false)
    }
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.configureView() //뷰를 업데이트
        }
    }
    
    //MARK: - Deinitialize
    //인스턴스가 deinit될 때 해당 인스턴스에 추가된 모든 옵저버가 해제되도록.
    //이러면 관찰이 필요없을 때는 옵저버를 제거할 수 있음.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
