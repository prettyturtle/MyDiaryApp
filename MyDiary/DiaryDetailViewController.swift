//
//  DiaryDetailViewController.swift
//  MyDiary
//
//  Created by yc on 2021/11/01.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var starButton: UIBarButtonItem?
    
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }
    
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let writeDiaryViewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        
        writeDiaryViewController.diaryEditorMode = .edit(indexPath, diary)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        self.navigationController?.pushViewController(writeDiaryViewController, animated: true)
    }
    
    @objc func editDiaryNotification(notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        self.diary = diary
        self.configureView()
    }
    
    @objc func starDiaryNotification(notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let diary = starDiary["diary"] as? Diary else { return }
        
        self.diary = diary
        self.configureView()
    }
    
    @objc func deleteDiaryNotification(notification: Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.diary?.uuidString else { return }
        
        // 삭제 버튼이 눌렸을 때 uuidString을 notificationCenter에 post
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
        )
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // 처음 화면 구성
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsLabel.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    // starButton을 눌렀을 때
    @objc func tapStarButton() {
        guard let isStar = self.diary?.isStar else { return }
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        
        // isStar 값이 변할때 notificationCenter에 post한다
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                "uuidString": self.diary?.uuidString
            ],
            userInfo: nil
        )
    }
    
    // date를 string으로 바꿔주는 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // DiaryDetailViewController에서 나가면 notificationCenter의 Observer 삭제
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
