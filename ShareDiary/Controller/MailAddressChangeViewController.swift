
//
//  MailAddressChangeViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class MailAddressChangeViewController: UIViewController {
    
    //メールアドレス
    @IBOutlet weak var mailAddress: UITextField!
    //パスワード
    @IBOutlet weak var password: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.view.backgroundColor = Const.DarkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        guard let user = Auth.auth().currentUser else{return}
        //現在のメールアドレスを表示
        self.mailAddress.text = user.email

        
    }
    private func check(mailAddress:String,password:String) -> Bool{
        if mailAddress.isEmpty {
             //メールアドレスが空の場合
            let dialog = UIAlertController(title: Const.Message35, message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         //メールアドレスかをチェック
         if !Validation.isValidEmail(mailAddress){
            let dialog = UIAlertController(title: Const.Message4, message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         if password.isEmpty{
             //パスワードが空の場合
            let dialog = UIAlertController(title: Const.Message36, message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         //パスワード桁数
         if password.count < 6{
             //アラート
            let dialog  =  UIAlertController(title: Const.Message5, message: nil, preferredStyle: .actionSheet)
             //OKボタン
             dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
        
        //チェックOK
        return true
    }
    //保存ボタン押下時
    @objc private func saveButtonTap(){
        guard let user = Auth.auth().currentUser else{return}

        guard let email = user.email else {return}
        var credential: AuthCredential
        
        if let mailAddress = self.mailAddress.text ,let password = self.password.text {
            //入力チェック
            let checkResult = check(mailAddress:mailAddress,password:password)
            //入力チェックでfalseの場合はreturn
            guard checkResult else {return}
             
            //HUDを表示
            SVProgressHUD.show()

            //再認証を行う
            credential = EmailAuthProvider.credential(withEmail: email, password:password)
            // Prompt the user to re-provide their sign-in credentials
            user.reauthenticate(with: credential) { result ,error in
                if let error = error {
                    // An error happened.
                    print("DEBUG:\(error)")
                    let dialog  =  UIAlertController(title: Const.Message33, message:nil, preferredStyle: .alert)
                    //OKボタン
                    dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
                    self.present(dialog,animated: true,completion: nil)
                    //HUDを消す
                    SVProgressHUD.dismiss()
                    return
                } else {
                    // User re-authenticated.
                    //メールアドレス更新
                    self.updateMailAddress(user:user)
                }
            }
        }
    }
    
    //メールアドレス更新
    private func updateMailAddress(user:User){
        user.updateEmail(to: self.mailAddress.text!){ error in
            if error != nil {
                let dialog  =  UIAlertController(title: Const.Message37, message:nil, preferredStyle: .alert)
                //OKボタン
                dialog.addAction(UIAlertAction(title: Const.Ok, style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                //HUDを消す
                SVProgressHUD.dismiss()
                return
            }else{
                //HUDを消す
                SVProgressHUD.dismiss()
                //前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
  
    
}
