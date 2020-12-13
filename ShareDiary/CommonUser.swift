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
    static func logout(){
        //最終ログアウト日時を記録
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "lastLogoutDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        let userRef = Firestore.firestore().collection(Const.Users).document(myUid)
        userRef.updateData(docData)
        
        sleep(2)
        // ログアウトする
        try! Auth.auth().signOut()

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

