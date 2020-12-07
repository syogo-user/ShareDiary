//
//  Auth.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/11/25.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import Firebase
import SVProgressHUD
struct CommonUser {
    
    //ログアウト
    static func logout(viewController :UIViewController){
        //最終ログアウト日時を記録
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "lastLogoutDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        //メッセージの保存
        let userRef = Firestore.firestore().collection(Const.Users).document(myUid)
        userRef.updateData(docData)
        
        sleep(1)
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        loginViewController?.modalPresentationStyle = .fullScreen
        viewController.present(loginViewController!, animated: true, completion: nil)

        //タブバーを取得する
        let tabBarController = viewController.tabBarController
            
        // ログイン画面から戻ってきた時のためにカレンダー画面（index = 0）を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    //削除スタータスが0より大きいものを削除する([String]型)
    static func uidExclusion(accountDeleteArray:[String],dataArray:[String]) -> [String]{
        var uidArray = dataArray
        for deleteUid in accountDeleteArray {
            for i in 0 ..< uidArray.count {
                if deleteUid == uidArray[i] {
                    uidArray.remove(at:i)
                    break
                }
            }
        }
        return uidArray
    }
    //削除スタータスが0より大きいものを削除する([PostData]型)
    static func uidExclusion(accountDeleteArray:[String],dataArray:[PostData]) -> [PostData]{
        var postArray = dataArray
        for deleteUid in accountDeleteArray {
            for i in 0 ..< postArray.count {
                if deleteUid == postArray[i].uid {
                    postArray.remove(at:i)
                    break
                }
            }
        }
        return postArray
    }
    
    //削除スタータスが0より大きいものを削除する([UserPostData]型)
    static func uidExclusion(accountDeleteArray:[String],dataArray:[UserPostData])-> [UserPostData]{
        var userPostArray = dataArray
        for deleteUid in accountDeleteArray {
            for i in 0 ..< userPostArray.count {
                if deleteUid == userPostArray[i].uid {
                    userPostArray.remove(at:i)
                    break
                }
            }
        }
        return userPostArray

    }
    
    
    
    //    //自分のuidが削除されたユーザされたユーザかどうかを判定　削除済みの場合は強制ログアウト
    //    static func JudgDeleteUid (myUid:String,viewController:UIViewController){
    //        //削除ステータスが0よりも大きいもの
    //        let userRef = Firestore.firestore().collection(Const.users).whereField("accountDeleteState",isGreaterThan:0)
    //        userRef.getDocuments(){
    //            (querySnapshot,error) in
    //            if let error = error {
    //                print("DEBUG: snapshotの取得が失敗しました。\(error)")
    //                return
    //            } else {
    //                var accountDeleteArray  :[String] = []
    //                accountDeleteArray = querySnapshot!.documents.map {
    //                    document -> String in
    //                    let userUid = UserPostData(document:document).uid ?? ""
    //                    return userUid
    //                }
    //
    //                //自分のuidが削除済みかを判定
    //                if accountDeleteArray.firstIndex(of: myUid) != nil{
    //                    //強制ログアウト
    ////                    self.logout(viewController:viewController)
    //                    viewController.dismiss(animated: true, completion: nil)
    //                }
    //            }
    //        }
//}




}

