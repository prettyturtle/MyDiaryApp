//
//  WriteDiaryViewController.swift
//  MyDiary
//
//  Created by yc on 2021/10/31.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIBarButtonItem!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    weak var delegate: WriteDiaryViewDelegate?
    
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureDatePicker()
        self.configureContentsTextView()
        self.confirmButton.isEnabled = false
        self.configureInputField()
        self.configureEditMode()
    }
    
    // 수정할 때
    private func configureEditMode() {
        switch diaryEditorMode {
        case .edit(_, let diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
        default:
            break
        }
    }
    
    // date를 string으로 바꿔주는 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // contentsTextView 꾸미기
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderWidth = 0.6
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    // dateTextField를 선택했을 때 datePicker로 하는 함수
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .inline
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker
    }
    @objc private func datePickerValueDidChange(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
//        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    // 빈화면 터치하면 키보드 or 데이트 피커 사라지기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        switch diaryEditorMode {
        case .new:
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )
            
            self.delegate?.didSelectRegister(diary: diary)
        case .edit(_, let diary):
            let diary = Diary(
                uuidString: diary.uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    // 세 항목이 모두 채워졌을 때, 등록버튼 활성화하는 함수
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !(self.contentsTextView.text.isEmpty)
    }
    
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange), for: .editingDidEnd)
    }
    
    @objc func titleTextFieldDidChange(textField: UITextField) {
        self.validateInputField()
    }
    @objc func dateTextFieldDidChange(textField: UITextField) {
        self.validateInputField()
    }
    
}


extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
