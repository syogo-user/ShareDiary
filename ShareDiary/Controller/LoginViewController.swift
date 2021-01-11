//
//  LoginViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import LTMorphingLabel
class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    
    //表示制御用タイマー
    private var timer:Timer?

    
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 15
        self.backImage.image = UIImage(named: "yozora")
        self.backImage.contentMode = .scaleAspectFill
        //メールアドレス欄
        self.mailAddressTextField.layer.cornerRadius = 15
        self.mailAddressTextField.layer.borderWidth = 0.1   
        self.mailAddressTextField.layer.borderColor = UIColor.white.cgColor
        self.mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        //パスワード欄
        self.passwordTextField.layer.cornerRadius = 15
        self.passwordTextField.layer.borderWidth = 0.1
        self.passwordTextField.layer.borderColor = UIColor.white.cgColor
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //ボタンの押下時の文字色
        self.loginButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
        self.createAccountButton.setTitleColor(UIColor.lightGray ,for: .highlighted)
        self.loginButton.addTarget(self, action: #selector(tapLoginButton(_:)), for: .touchUpInside)
        self.createAccountButton.addTarget(self, action: #selector(tapcreateAccountButton(_:)), for: .touchUpInside)
        
        //タイマーの追加
        titleLabel.morphingEffect = .sparkle
         timer=Timer.scheduledTimer(timeInterval:2.0,
                                      target:self,
                                      selector:#selector(update(timer:)),userInfo:nil,
                                      repeats:true)
         timer?.fire()
        titleLabel.text = "Welcome"

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    @objc func update(timer:Timer){
        //ここでtextの更新
        
        titleLabel.text = "Share Diary"
        
    }
 
    @objc private func tapLoginButton(_ sender :UIButton){
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: Const.Message2)
                return
            }
            //HUDで処理中を表示
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if error != nil {
                    SVProgressHUD.showError(withStatus:Const.Message3)
                    return
                }
                guard let myUid = Auth.auth().currentUser?.uid else{return}
                //アカウントが削除済みでないかを判定
                self.JudgDeleteUid(myUid: myUid)
            }
        }
    }

    @objc private func tapcreateAccountButton(_ sender :UIButton){
        //アカウント作成画面に遷移
        let accountCreateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcountCreateViewController") as! AccountCreateViewController

        accountCreateViewController.mailAddress = self.mailAddressTextField.text ?? ""
        accountCreateViewController.password = self.passwordTextField.text ?? ""
        accountCreateViewController.modalPresentationStyle = .fullScreen
        self.present(accountCreateViewController, animated: true, completion: nil)
    }
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    private func loginProcess(){
        //最終ログイン日時を記録
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "lastLoginDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        //メッセージの保存
        let userRef = Firestore.firestore().collection(Const.Users).document(myUid)
        userRef.updateData(docData)
    }
    //アカウントが削除済みか判定
    private func JudgDeleteUid (myUid:String){
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
                
                //自分のuidが削除済みかを判定
                if accountDeleteArray.firstIndex(of: myUid) != nil{
                    SVProgressHUD.dismiss()
                    // ログアウトする
                    CommonUser.logout()
                    //アカウントは使用できませんのメセージを表示
                    let alert = UIAlertController.init(title: "", message: Const.Message1, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Const.Ok, style: UIAlertAction.Style.cancel, handler:{ action in
                        //ログイン画面を閉じる
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)

                }else {
                    //ログイン日時を記録
                    self.loginProcess()
                    //HUDを消す
                    SVProgressHUD.dismiss()
                    // 画面を閉じてタブ画面に戻る
                    self.dismiss(animated: true, completion: nil)                    
                }
            }
        }
    }
}
