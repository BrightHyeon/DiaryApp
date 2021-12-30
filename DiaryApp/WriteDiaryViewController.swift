//
//  WriteDiaryViewController.swift
//  DiaryApp
//
//  Created by HyeonSoo Kim on 2021/12/19.
//

import UIKit

//MARK: - Enum
enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

//MARK: - Protocol
protocol WriteDiaryViewDelegate: AnyObject { //정보전달을 위한 delegate프로토콜 생성. (ViewController의 diaryList에 등록한 Diary객체를 전달)
    func didSelectRegister(diary: Diary) //정보전달을 위한 함수 생성. (이 메서드에 일기가 작성된 Diary객체를 전달할 거임.)
}

class WriteDiaryViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    //datePicker
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    var diaryEditorMode: DiaryEditorMode = .new //기본값. 등록모드.
    //Delegate
    weak var delegate: WriteDiaryViewDelegate? //정보전달위한 delegate프로퍼티 생성. (delegate프로토콜의 함수를 쓰기위한 프로퍼티.)
    
    // MARK: - Override Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureEditMode()
        self.configureInputField()
        self.confirmButton.isEnabled = false //초기 설정(비활성)
    }
    //datePicker
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - IBAction
    //Delegate
    //일기를 다 작성하고, 등록버튼을 눌렀을 때 Diary객체를 생성하고, delegate에 정의한 함수를 호출해서 생성된 Diary객체를 전달해줄거임.
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return } //String포맷말고, Date형식으로 보이게할거임.
        
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(
                //일기를 생성할 때마다 uuidString프로퍼티에 일기를 특정할 수 있는 고유한 UUID가 특정이 된다.
                uuidString: UUID().uuidString, //UUID인스턴스에 uuid스트링 대입.
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )
            self.delegate?.didSelectRegister(diary: diary) //객체전달
        case let .edit(_, diary):
            let diary = Diary(
                uuidString: diary.uuidString,//final: 이거때문에 수정값이 컬렉션뷰에 안뜬거였음.
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar)
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
                    //["indexPath.row": indexPath.row] //indexPath로 전달하면 오류유발. 책 필기 참고.
            )
        }
        self.navigationController?.popViewController(animated: true)//동시에 화면도 전환.
    }
    
    //MARK: - Method
    //수정모드
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
        default:
            break
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    // TextView's Border
    private func configureContentsTextView() {
        let borderColor = CGColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = borderColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5
    }
    // datePicker
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date //날짜만 설정
        self.datePicker.preferredDatePickerStyle = .wheels //휠 스타일
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) //자신(datePicker)의 값이 바뀔 때 selector의 메서드 호출. -> .addTarget을 써야지만 날짜 설정을 통해 날짜를 지정할 수 있음.
        //        self.datePicker.locale = Locale(identifier: "ko_KR") //지금 버전에선 이거 안해줘도 한글 뜸
        self.dateTextField.inputView = self.datePicker //inputView - target click 시에 keyboard 대신 datePicker가 뜨도록.
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) { //datePicker를 받음.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (EEEEE)" //ex) 2021년 12월 20일 (Fri)
        formatter.locale = Locale(identifier: "ko_KR") //ex) Fri -> 금
        self.diaryDate = datePicker.date //바뀐 값을 Date타입으로 저장.
        self.dateTextField.text = formatter.string(from: datePicker.date) //Date타입 값을 받아 설정한 문자열로 포맷. -> 값 넘김.
        self.dateTextField.sendActions(for: .editingChanged) //날짜값(datePicker)이 바뀔 때 .editingChanged를 발생시킴. 아랫 블럭 셀렉터 호출됨.
    }
    //confirmButton Enable or not
    private func configureInputField() { //head 함수.
        self.contentsTextView.delegate = self //Delegate 프로토콜에 정의된 메서드들을 받는? 과정...!
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged) //값 타이핑 시, selector호출.
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
        //값 타이핑 시, selector호출. 허나 datePicker형태로 설정했기에 키보드가 없으니 호출이 안 됨. 윗 블럭 go.
        
        //         // OTHER WAY - 그냥 이렇게 해도 되긴 함. - 1
        //        self.titleTextField.delegate = self
        //        self.dateTextField.delegate = self
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    // OTHER WAY 2 - 굳이 위아래 두 개 따로 만들 필요가 있나? 하나로 만들고 셀렉터에 넘겨도 되긴 함. -
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    //제목, 내용, 날짜가 모두 입력되면 .isEnabled = true로 바꿔주는 메서드.
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
}

//MARK: - Extension
//textViewDidChange 메서드를 사용하기 위해 Delegate프로토콜 채택.
extension WriteDiaryViewController: UITextViewDelegate/*, UITextFieldDelegate*/ {
    func textViewDidChange(_ textView: UITextView) { //textView에 text가 입력될 때마다 호출되는 메서드.
        self.validateInputField() //textView에 text가 입력될 때마다 등록가능성여부를 판단.
    }
    //     // OTHER WAY 1 - 그냥 이렇게 해도 되긴 함. 오히려 이게 상위호환. 키보드타이핑 상관없이 textField에 text가 생기면 호출됨.
    //    func textFieldDidChangeSelection(_ textField: UITextField) {
    //        self.validateInputField()
    //    }
}
