//
//  ViewController.swift
//  MyDiary
//
//  Created by yc on 2021/10/31.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // 일기장 리스트
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiaryList()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification),
            name: NSNotification.Name("editDiary"),
            object: nil
        )

    }
    
    // userDefault에 저장하는 함수(diaryList에 데이터가 들어갈때마다 실행된다.)
    private func saveDiaryList() {
        let data = self.diaryList.map {
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }

        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "diaryList")
    }
    
    // 실행될때 userDefault에서 diaryList를 가져오는 함수
    private func loadDiaryList() {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.object(forKey: "diaryList") as? [[String: Any]] else { return }
        
        self.diaryList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }
        
        self.diaryList = self.diaryList.sorted {
            $0.date.compare($1.date) == .orderedDescending
        }
    }

    // date를 string으로 바꿔주는 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
}


extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
        self.diaryList = self.diaryList.sorted {
            $0.date.compare($1.date) == .orderedDescending
        }
        self.collectionView.reloadData()
    }
}

// #selector
extension ViewController {
    @objc func editDiaryNotification(notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
        
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted {
            $0.date.compare($1.date) == .orderedDescending
        }
        self.collectionView.reloadData()
    }
    
    // starButton이 눌렸을 때 눌렸다는 신호가 notificationCenter에 post되었고 그것을 받아 diaryList 수정
    @objc func starDiaryNotification(notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString}) else { return }
        
        self.diaryList[index].isStar = isStar
    }
    
    @objc func deleteDiaryNotification(notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString}) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        
        return cell
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let diaryDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        
        let diary = self.diaryList[indexPath.row]
        diaryDetailViewController.diary = diary
        diaryDetailViewController.indexPath = indexPath
        
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)

    }
}
