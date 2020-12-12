//
//  FriendListViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift
import SVProgressHUD

class FriendSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    //検索文字列
    var inputText :String = ""
    // ユーザデータを格納する配列
    var userPostArray: [UserPostData] = []
    var searchbar :UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Const.DarkColor
        
        //検索バーのインスタンスを取得する
        let searchBar: UISearchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        searchBar.placeholder = "ニックネームで検索"
        searchBar.backgroundColor = Const.DarkColor
        searchBar.searchBarStyle = .prominent
        searchBar.barTintColor = .white
        searchBar.disableBlur()
        self.searchbar = searchBar
        self.view.addSubview(searchbar)
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "UsersTableViewCell", bundle:nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
                
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //recognizerによってCellの選択ができなくなってしまうのを防ぐためにcancelsTouchesInViewを設定
        //falseでタップを認識するようになる
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchbar.text = ""
        self.searchbar.barTintColor = .white
        self.userPostArray = []
        self.tableView.reloadData()
        //検索欄にフォーカスをあてる
        self.searchbar.becomeFirstResponder()
        //画面下部の境界線を消す
        self.tableView.tableFooterView = UIView()

    }
            
    //検索バーで文字編集中（文字をクリアしたときも実行される）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        //文字が空の場合userPostArrayを空にする
        if  searchText.isEmpty {
            self.userPostArray  = []
            self.tableView.reloadData()
        }
        searchBar.textField?.textColor = UIColor.white
    }
    
    //検索ボタンがタップされた時に実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        inputText =  searchBar.text!
        inputText = inputText.trimmingCharacters(in: .whitespaces)
        self.userPostArray  = []
        //HUDで処理中を表示
        SVProgressHUD.show()
        //自分のuid取得
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        //削除ステータスが0より大きいユーザのデータを取得し、その後、画面を描画する
        self.accountDeleteStateGet(myUid: myUid,searchBar: searchBar)
        

    }
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(myUid:String,searchBar:UISearchBar){
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
                //ユーザからデータを取得
                self.getUserData(accountDeleteArray:accountDeleteArray,searchBar:searchBar)
            }
        }
        
    }
    
    //ユーザからデータを取得
    private func getUserData(accountDeleteArray:[String],searchBar:UISearchBar){
        //前方一致検索
        let userRef = Firestore.firestore().collection(Const.Users)
        let ref = userRef.order(by: "userName").start(at: [inputText]).end(at: [inputText + "\u{f8ff}"])
        ref.getDocuments() {
            (querySnapshot,error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: Const.Message12)
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                self.userPostArray = querySnapshot!.documents.map {
                    document in
                    let userPostData = UserPostData(document:document)
                    return userPostData
                }
                searchBar.endEditing(true)
                
                //削除ステータスが0より大きいユーザは除外する
                self.userPostArray = CommonUser.uidExclusion(accountDeleteArray:accountDeleteArray,dataArray:self.userPostArray)
                //HUDを消す
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                
            }
        }

        //キーボード閉じる
        searchBar.endEditing(true)
    }
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int ) -> Int{
        return userPostArray.count
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.CellHeight
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView : UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        //Cell に値を設定する
        cell.setUserPostData(userPostArray[indexPath.row])
        //セル内のボタンのアクションをソースコードで設定する
        cell.followRequestButton.addTarget(self,action:#selector(tapFolloRequestwButton(_ : forEvent:)),for: .touchUpInside)
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){
        //プロフィール画面に遷移する
        let profileViewController = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userPostArray[indexPath.row]
        profileViewController.userData = userData
        //選択後の色をすぐにもとに戻す
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .none
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
    }
    
    //セル内の「フォロー申請」ボタンがタップされた時に呼ばれるメソッド
    @objc func tapFolloRequestwButton(_ sender: UIButton,forEvent event:UIEvent){
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        //タッチした座標
        let point = touch!.location(in:self.tableView)
        //タッチした座標がtableViewのどのindexPath位置か
        let indexPath = tableView.indexPathForRow(at: point)
        //配列からタップされたインデックスのデータを取り出す
        let userPostData = userPostArray[indexPath!.row]
        

        
        //ログインしている自分のuidを取得する
        if  let myUid = Auth.auth().currentUser?.uid {
            //相手（Aさん）のuidのドキュメントを取得する
            let usersRef = Firestore.firestore().collection(Const.Users).document(userPostData.uid!)//userPostData.uidはAさんのuid
            // 更新データを作成する
            var updateValue: FieldValue
            if sender.titleLabel?.text == "フォロー申請" {
                //<<BさんがAさんにフォローリクエストする>>
                //AさんのfollowRequestに自分（Bさん）のuidを追加する
                updateValue = FieldValue.arrayUnion([myUid])
                
            } else {
                //ボタンのラベルが「申請済」の場合
                //申請のキャンセル
                //<<BさんがAさんへのフォローリクエストをキャンセルする>>
                //AさんのfollowRequestから自分（Bさん）のuidを削除する
                updateValue = FieldValue.arrayRemove([myUid])
            }
            //データ更新
            usersRef.updateData(["followRequest":updateValue])
            
            //再描画のためにデータを取得
            let postRef = Firestore.firestore().collection(Const.Users).whereField("userName", isEqualTo:inputText)
            postRef.getDocuments() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    self.userPostArray = querySnapshot!.documents.map {
                        document in
                        let userPostData = UserPostData(document:document)
                        return userPostData
                    }
                    self.accountDeleteStateGet(myUid: myUid, searchBar: self.searchbar)
                }
            }
            
            
            
        }        
    }
    //データ更新
    private func followSend(myUid:String,blockList:[String],usersRef:DocumentReference,sender:UIButton){
        //ブロックリストに自分のUidがあった場合は処理を終了する
        if blockList.firstIndex(of: myUid) != nil{
            SVProgressHUD.showError(withStatus: Const.Message13)
            return
        }
        


    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
}
