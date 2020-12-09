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
        let tabBarController = viewController.tabBarController as! TabBarController
        tabBarController.selectedIndex = 2
        tabBarController.selectedIndex = 1
        // ログイン画面から戻ってきた時のためにカレンダー画面（index = 0）を選択している状態にしておく
        tabBarController.selectedIndex = 0
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

}

