//
//  LeftViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/06.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SVProgressHUD
class LeftViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followShowButton: UIButton!
    @IBOutlet weak var followerShowButton: UIButton!
    @IBOutlet weak var followRequestShowButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var exclamationMark: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.view.backgroundColor = Const.SlideColor
        self.imageView.layer.cornerRadius  = 25
        self.logoutButton.addTarget(self, action: #selector(tapLogoutButton(_:)), for: .touchUpInside)
        self.followShowButton.addTarget(self, action: #selector(tapFollowShowButton(_:)), for: .touchUpInside)
        self.followerShowButton.addTarget(self, action: #selector(tapFollowerShowButton(_:)), for: .touchUpInside)
        self.followRequestShowButton.addTarget(self, action: #selector(tapFollowRequestShowShowButton(_:)), for: .touchUpInside)
        self.settingButton.addTarget(self,action:#selector(tapSettingButton(_:)),for:.touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let  myUid = Auth.auth().currentUser?.uid else{return}
        //削除ステータス0より大きいものを取得
        accountDeleteStateGet(myUid:myUid)
    }
    //画像の表示
    private func userDataShow(accountDeleteArray:[String]){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let postUserRef = Firestore.firestore().collection(Const.Users).document(myUid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                let myImageName = document["myImageName"] as? String ?? ""
                var myFollow = document["follow"] as? [String] ?? []
                var myFollower = document["follower"] as? [String] ?? []
                var myFollowRequest = document["followRequest"] as? [String] ?? []
                
                
                //削除ステータスが立っているものは除外する
                myFollow = self.deleteArray(array: myFollow, accountDeleteArray: accountDeleteArray)
                myFollower  = self.deleteArray(array: myFollower, accountDeleteArray: accountDeleteArray)
                myFollowRequest = self.deleteArray(array: myFollowRequest, accountDeleteArray: accountDeleteArray)
                
                if myFollowRequest.count > 0{
                    //表示
                    self.exclamationMark.isHidden = false
                }else{
                    //非表示
                    self.exclamationMark.isHidden = true
                }
                
                //画像の取得
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(myImageName + Const.Jpg)
                //名前の表示
                self.userName.text = document["userName"] as? String ?? ""
                //フォロー・フォロワー数の表示
                self.followLabel.text = "フォロー： \(myFollow.count)"
                self.followerLabel.text = "フォロワー：\(myFollower.count)"
                //画像がなければデフォルトの画像表示
                if myImageName == "" {
                    self.imageView.image = UIImage(named: Const.Unknown)
                }else{
                    //取得した画像の表示
                    self.imageView.sd_imageIndicator =
                        SDWebImageActivityIndicator.gray
                    self.imageView.sd_setImage(with: imageRef)
                }
            }
        }
    }
    private func deleteArray(array :[String],accountDeleteArray:[String]) -> [String]{
        var arrayUid = array
//        //削除ステータスが0より大きいユーザは除外する
        arrayUid = CommonUser.uidExclusion(accountDeleteArray: accountDeleteArray, dataArray: arrayUid)
        return arrayUid
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
                
                //描画
                self.userDataShow(accountDeleteArray:accountDeleteArray)
            }
        }
        
    }
    //フォローボタンが押された時
    @objc private func tapFollowShowButton(_ sender :UIButton){
        let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerListTableViewController") as! FollowFollowerListTableViewController
          followFollowerListTableViewController.fromButton = Const.Follow
          followFollowerListTableViewController.modalPresentationStyle = .fullScreen
          self.present(followFollowerListTableViewController, animated: true, completion: nil)
    }
    //フォロワーボタンが押された時
    @objc private func tapFollowerShowButton(_ sender :UIButton){
        let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerListTableViewController") as! FollowFollowerListTableViewController
        followFollowerListTableViewController.fromButton = Const.Follower
        followFollowerListTableViewController.modalPresentationStyle = .fullScreen
        self.present(followFollowerListTableViewController, animated: true, completion: nil)
    }
    
    //フォローリクエストボタンが押された時
    @objc private func tapFollowRequestShowShowButton(_ sender :UIButton){
        let followRequestListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowRequestListTableViewController") as! FollowRequestListTableViewController
        followRequestListTableViewController.modalPresentationStyle = .fullScreen
        self.present(followRequestListTableViewController, animated: true, completion: nil)
    }
    
    //設定ボタンが押された時
    @objc private func tapSettingButton(_ sender :UIButton){
        //ナビゲーションコントローラを取得
        let slideViewController = parent as! SlideViewController
        let navigationController = slideViewController.mainViewController as! UINavigationController
        //画面遷移        
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        navigationController.pushViewController(settingViewController, animated: true)
        //スライドメニューを閉じる
        closeLeft()
    }
    //ログアウトボタンが押された時
    @objc private func tapLogoutButton(_ sender :UIButton){
        //ダイアログ表示
        let dialog = UIAlertController(title: Const.Message30, message: nil, preferredStyle: .alert)
        //OKボタン
        dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: { action in
            self.logout()
        }))
        //キャンセルボタン
        dialog.addAction(UIAlertAction(title: Const.Cancel, style: .default, handler: { action in
        }))
        self.present(dialog,animated: true,completion: nil)

    }
    private func logout(){
        //スライドメニューのクローズ
        closeLeft()
        // ログアウトする
        CommonUser.logout()
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController?.modalPresentationStyle = .fullScreen
        self.present(loginViewController!, animated: true, completion: nil)        
        
        //タブバーを取得する
        let slideViewController = parent as! SlideViewController
        let navigationController = slideViewController.mainViewController as! UINavigationController
        let tabBarController = navigationController.topViewController as! TabBarController
        // ログイン画面から戻ってきた時のためにカレンダー画面（index = 0）を選択している状態にしておく
        tabBarController.selectedIndex = 0
    }
    
    
}
