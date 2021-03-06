//
//  TimeLineViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class TimeLineViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate ,TabBarDelegate{
        
    @IBOutlet weak var tableView: UITableView!
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    //全ユーザの一覧を格納する配列（プロフィール写真取得用）
    var userPostArray:[UserPostData] = []
    //リフレッシュコントロール
    let refreshCtl = UIRefreshControl()
    // Firestoreのリスナー
    var userListener: ListenerRegistration!
    var postListenerArray: [ListenerRegistration] = []
    //フォローと自分のuid配列
    var followAndMyUidArray : [String] = []

    
    override func viewDidLoad() {
        print("DEBUGview:viewDidLoad")
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //tableViewの境界線を消す
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        //リフレッシュ
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)                                
        print("DEBUGview:viewWillAppear")
        guard let myUid = Auth.auth().currentUser?.uid else {return}

        
        //削除フラグが設定されている人を取得し、その後タイムラインを表示する
        self.accountDeleteStateGet(myUid: myUid)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for postListener in postListenerArray{
            postListener.remove()
        }
        postListenerArray = []
        postArray = []
        tableView.reloadData()

        if userListener != nil{
            userListener.remove()
            userListener = nil
            postArray = []
            tableView.reloadData()
        }
    }
        
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("DEBUGview:tableView　cellForRowAt 開始")
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //セルを選択した時に選択状態の表示にしない（セルを選択した時に選択状態の表示にしない）
        //(つまりセルが選択された時にUITableViewCellSelectedBackgroundを使用しない)
        cell.selectionStyle = .none
        
        //プロフィール写真名を設定
        self.profileImageNameSet()
        //セルの設定
        cell.setPostData(postArray[indexPath.row])

        //いいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(tapLikeButton(_:forEvent:)), for: .touchUpInside)
        //コメントボタンを押下時
        cell.commentButton.addTarget(self, action:#selector(tapCommnetButton(_:forEvent:)), for: .touchUpInside)
        
        //variousボタン押下時
        cell.variousButton.addTarget(self, action:#selector(tapVariousButtion(_:forEvent:)), for: .touchUpInside)
        
        //自作のデリゲート
        cell.imageLayoutWorkerView.imageLayoutWorkerViewCellDelegate = self
        return cell
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 800 //セルの高さ
        return UITableView.automaticDimension
    }
    //セルを選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath.row]
        
        detailViewController.postData = postData
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    //ドキュメント表示
    func documentShow(myUid:String,accountDeleteArray:[String]){
        //◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
        let postUserRef = Firestore.firestore().collection(Const.Users).document(myUid)
        userListener = postUserRef.addSnapshotListener() {
            (querySnapshot2,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                let document = querySnapshot2?.data()
                guard let doc = document else{return}
                if let docFollow = doc["follow"] {
                    self.followAndMyUidArray = []
                    self.followAndMyUidArray = docFollow as! [String]
                    //自分のuidも追加
                    self.followAndMyUidArray.append(myUid)
                    //削除済みユーザを除外
                    self.followAndMyUidArray = CommonUser.uidExclusion(accountDeleteArray: accountDeleteArray, dataArray: self.followAndMyUidArray)
                    //初期化
                    self.postArray = []
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                    //フォローしている人の配列でループ（自分含み）
                    for uid in self.followAndMyUidArray{
                        let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("uid",isEqualTo:uid)//.order(by: "date", descending: true)
                        //スナップショットリスナーを追加
                        self.postListenerArray.append(postsRef.addSnapshotListener(){ (querySnapshot, error) in
                            //nillの場合は処理を飛ばす
                            guard querySnapshot != nil  else{return}
                            querySnapshot!.documents.forEach{
                                document in
                                let postData = PostData(document: document)
                                //配列に存在するかどうか
                                if self.postArray.firstIndex(where: {post -> Bool in return post.id == postData.id}) == nil {
                                    //存在しない場合
                                    //そのまま追加
                                    self.postArray.append(postData)
                                }else{
                                    //存在する場合
                                    for (index,post) in self.postArray.enumerated(){
                                        if post.id == postData.id {
                                            //存在するデータを削除してから追加
                                            self.postArray.remove(at: index)
                                            self.postArray.append(postData)
                                        }
                                    }
                                }
                                
                                //日付順に入れ替える
                                self.postArray.sort{ (d0 ,d1) -> Bool in
                                    if let date0 = d0.date, let date1 = d1.date{
                                        //２つの日付が両方ともnilでないとき
                                        return date0  > date1
                                    }else{
                                        return false
                                    }
                                }
                                
                                // TableViewの表示を更新する
                                self.tableView.reloadData()
                                
                            }
                            
                        })
                    }
                }
            }
        }
        

    }
    
    //いいねボタンがタップされた時に呼ばれるメソッド
    @objc func tapLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    @objc func refresh( sender: UIRefreshControl){
        tableView.reloadData()
        //通信終了後、endRefreshingを実行することでロードインジケータ（くるくる）が終了する
        sender.endRefreshing()
    }
    //コメントボタン押下時
    @objc func tapCommnetButton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        detailViewController.postData = postData
        detailViewController.scrollFlg = true //画面遷移後すぐに下にスクロールを行う
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    //ブロックor通報
    @objc func tapVariousButtion(_ sender : UIButton,forEvent event:UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        guard let myUid = Auth.auth().currentUser?.uid else{return}

        let dialog = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: Const.Message18, style: .default, handler: { action in
            if myUid == postData.uid{
                self.myAlert()
                return
            }
            //ブロック
            self.userBlock(postData:postData)
        }))
        dialog.addAction(UIAlertAction(title: Const.Message19, style: .default, handler: { action in
            if myUid == postData.uid{
                self.myAlert()
                return
            }
            //通報
            self.userReportQuestion(postData:postData)
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: { action in
        }))
        self.present(dialog,animated: true,completion: nil)
        
    }
    
    //タブボタンがタップされた場合
    func didSelectTab(tabBarController: TabBarController) {
        //最上部にスクロール
        let contentOffset = CGPoint(x: 0.0, y: 0.0)
        self.tableView.setContentOffset(contentOffset, animated: true)
    }
    
    //ブロック処理
    private func userBlock(postData:PostData){
        let userName = postData.documentUserName ?? ""
        let dialog = UIAlertController(title: userName + Const.Message20, message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: { action in
            guard let myUid = Auth.auth().currentUser?.uid else{return}
            let db = Firestore.firestore()
            //トランザクション開始
            let batch = db.batch()
            
            let userRef = db.collection(Const.Users).document(myUid)
            var updateValue: FieldValue
            updateValue = FieldValue.arrayUnion([postData.uid])
            //自分のblockListにブロックしたいユーザのuidを書き込む
            batch.updateData(["blockList": updateValue],forDocument: userRef)
            
            
            //自分のフォローのリストから相手のuidを削除
            updateValue = FieldValue.arrayRemove([postData.uid])
            batch.updateData(["follow":updateValue], forDocument: userRef)
            
            //相手のフォロワーのリストからmyUidを削除
            let userRef2 = db.collection(Const.Users).document(postData.uid)
            updateValue = FieldValue.arrayRemove([myUid])
            batch.updateData(["follower":updateValue], forDocument: userRef2)
            //トランザクション終了
            //コミット
            batch.commit(){ error in
                if error != nil {

                }else{

                }
            }
        }))
        dialog.addAction(UIAlertAction(title: Const.Cancel, style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    //通報処理
    private func userReportQuestion(postData:PostData){
        let dialog = UIAlertController(title: Const.Message21, message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: Const.Message22, style: .default, handler:{ action in
            self.userReport(postData: postData, reportKind: 1)
        }))
        dialog.addAction(UIAlertAction(title: Const.Message23, style: .default, handler: { action in
            self.userReport(postData: postData, reportKind: 2)
        }))
        dialog.addAction(UIAlertAction(title: Const.Message24, style: .default, handler: { action in
            self.userReport(postData: postData, reportKind: 3)
        }))
        self.present(dialog,animated: true,completion:nil)
    }
    //通報処理
    private func userReport(postData :PostData,reportKind:Int){
        let userName = postData.documentUserName ?? ""
        let dialog = UIAlertController(title: userName + Const.Message25, message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: { action in
            guard let myUid = Auth.auth().currentUser?.uid else{return}
            //データをまとめる
            /*reportUid 通報された人のuid
              reportDocumentId 通報された投稿のID
              reportKind 通報の種類 1:不審な内容またはスパムです 2:不適切な内容を含んでいる 3:攻撃的な内容を含んでいる
              senderUid 通報した人のuid
              date 通報の日時
            */
            let reportRef = Firestore.firestore().collection(Const.Report).document()
            let reportDic = [
                "reportUid":postData.uid,
                "reportDocumentId":postData.id,
                "reportKind":reportKind,
                "senderUid":myUid,
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            //データを登録
            reportRef.setData(reportDic)
            //ご連絡ありがとうございます
            let dialog2 = UIAlertController(title: Const.Message26, message: nil, preferredStyle: .alert)
            dialog2.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
            self.present(dialog2,animated:true,completion: nil)
        }))
        dialog.addAction(UIAlertAction(title: Const.Cancel, style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    
    
    //自分だった場合
    private func myAlert(){
        let dialog = UIAlertController(title: Const.Message27, message: nil, preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(myUid:String){
        //削除ステータスが0よりも大きいもの
        let userRef = Firestore.firestore().collection(Const.Users).whereField("accountDeleteState",isGreaterThan:0)
        userRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var accountDeleteArray  :[String] = []
                accountDeleteArray = querySnapshot!.documents.map {
                    document -> String in
                    let userUid = UserPostData(document:document).uid ?? ""
                    return userUid
                }

                //ユーザデータを取得後ドキュメント表示
                self.userPostGet(myUid: myUid, accountDeleteArray: accountDeleteArray)
            }
        }
        
    }
    //プロフィール写真のためのユーザデータ取得
    private func userPostGet(myUid:String,accountDeleteArray:[String]){
        //全ユーザの情報を取得
        let userRef = Firestore.firestore().collection(Const.Users)
        userRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var userPostArray  :[UserPostData] = []
                userPostArray = querySnapshot!.documents.map {
                    document -> UserPostData in
                    let userPost = UserPostData(document:document)
                    return userPost
                }
                self.userPostArray = userPostArray
                

                //ドキュメント表示
                self.documentShow(myUid: myUid, accountDeleteArray:accountDeleteArray)



                
            }
        }
    }
    //postArrayにプロフィール写真名を設定
    private func profileImageNameSet(){
        self.postArray.forEach(){ post in
            for userPost in self.userPostArray {
                if post.uid == userPost.uid ?? ""{
                    //uidが同じ場合 プロフィール写真名を設定
                    post.profileImageName = userPost.myImageName ?? ""
                }
            }
        }
    }
    
    
}

extension TimeLineViewController:ImageLayoutWorkerViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedUIImageView = sender.view! as? UIImageView
        //  UIImage を取得
        guard let tappedImageView = tappedUIImageView  else {return}
        guard let tappedImageviewImage = tappedImageView.image else {return}
        let tappedImage = tappedImageviewImage
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController

        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
}
