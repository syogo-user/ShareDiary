//
//  SettingViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//
import UIKit
import Firebase
import SVProgressHUD
class SettingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mailAddressButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var accountDeleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.DarkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        self.mailAddressButton.addTarget(self, action: #selector(tapMailAddressButton(_:)), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(tapPasswordButton(_:)), for: .touchUpInside)
        self.accountDeleteButton.addTarget(self,action:#selector(tapAccountDeleteButton(_:)),for:.touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mailAddress = Auth.auth().currentUser?.email else {return}
        self.titleLabel.text = "アカウント設定"
        self.titleLabel.textColor = UIColor.white
        self.mailAddressButton.setTitle("メールアドレス： \(mailAddress)" , for: .normal)
        self.mailAddressButton.setTitleColor(UIColor.white, for: .normal)
        self.passwordButton.setTitle("パスワード： ●●●●●●●●" , for: .normal)
        self.passwordButton.setTitleColor(UIColor.white, for: .normal)
        self.accountDeleteButton.setTitleColor(UIColor.white, for: .normal)
        
//        self.accountDeleteButtonSetting()

    }
//    //アカウント削除ボタン表示の切り替え
//    private func accountDeleteButtonSetting(){
//        //アカウント削除ボタンは非表示で初期化する
//        self.accountDeleteButton.isHidden = true
//
//        guard let myUid = Auth.auth().currentUser?.uid else {return}
//        let userRef = Firestore.firestore().collection(Const.users).document(myUid)
//        userRef.getDocument() {
//            (querySnapshot,error) in
//            if let error = error {
//                return
//            } else {
//                if let document = querySnapshot!.data(){
//                    let administratorFlg  = document["administratorFlg"] as? Bool ?? false
//                    //管理者権限かどうかでボタンの表示を設定
//                    if administratorFlg == true {
//                        //管理者の場合、表示
//                        self.accountDeleteButton.isHidden = false
//                    }else {
//                        //管理者出ない場合、非表示
//                        self.accountDeleteButton.isHidden = true
//                    }
//                }
//            }
//        }
//
//    }
    
    //メールアドレスボタン押下時
    @objc private func tapMailAddressButton(_ sender : UIButton){        
        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
        mailAddressChangeViewController.accountDeleteFlg = false //メールアドレスからの場合はfalse
        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
    }
    //パスワードボタン押下時
    @objc private func tapPasswordButton(_ sender : UIButton){
        let passwordChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
    //アカウント削除ボタン押下時
    @objc private func tapAccountDeleteButton(_ sender:UIButton){
        //ダイアログ表示
        let dialog = UIAlertController(title: Const.Message16, message: nil, preferredStyle: .actionSheet)
        //OKボタン
        dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: { action in
            //削除フラグの設定
            self.accountDeleteFlgSet()
        }))
        //キャンセルボタン
        dialog.addAction(UIAlertAction(title: Const.Cancel, style: .default, handler: { action in}))
        self.present(dialog,animated: true,completion: nil)
    }
    //削除フラグ設定
    private func accountDeleteFlgSet(){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "accountDeleteState":1,
            "accountDeleteDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        //メッセージの保存
        let userRef = Firestore.firestore().collection(Const.Users).document(myUid)
        userRef.updateData(docData)
        //いいねをしたユーザを検索して、抽出したユーザへのいいねを削除する
        self.deleteLikeSearch()
        
        let alert = UIAlertController.init(title: "", message: Const.Message15, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Const.Ok, style: UIAlertAction.Style.cancel, handler:{ action in
            //一つ前の画面に戻る
            self.navigationController?.popViewController(animated: true)
            //スライドメニューを閉じる
            self.closeLeft()
            // ログアウトする
            try! Auth.auth().signOut()
            let tabBarController  = self.navigationController?.topViewController as! TabBarController
            tabBarController.selectedIndex = 0
            //前の画面に戻ります
            self.navigationController?.popViewController(animated:true)
            
        }))
        self.present(alert, animated: true, completion: nil)

        
    }
    //いいねしているユーザを検索
    private func deleteLikeSearch(){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let postRef = Firestore.firestore().collection(Const.PostPath).whereField("likes",arrayContains: myUid)
        postRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var postDataId  :[String] = []
                postDataId = querySnapshot!.documents.map {
                    document -> String in
                    let postId = PostData(document:document).id
                    return postId
                }
                //投稿のIDを渡してその中のいいねをしている自分のuidを削除する
                self.deleteLikeUid(deletePostId:postDataId ,myUid:myUid)
            }
        }
    }
    //いいね削除
    private func deleteLikeUid(deletePostId:[String],myUid:String){
        let db = Firestore.firestore()
        let batch = db.batch()
        
        for id in deletePostId {
            let postRef = db.collection(Const.PostPath).document(id)
            var myUidValue: FieldValue
            //自分のuidを削除する
            myUidValue = FieldValue.arrayRemove([myUid])
            batch.updateData(["likes":myUidValue],forDocument: postRef)
        }
        //コミット
        batch.commit() { err in
            if err != nil {
                print("DEBUG:削除失敗")
            } else {
                print("DEBUG:削除成功")
            }
        }
    }
    
    
//    @objc func tapAccountDeleteAdministrator(_ sender:UIButton){
//        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
//        mailAddressChangeViewController.accountDeleteFlg = true //アカウント削除からの場合はtrue
//        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
//    }
    
}
