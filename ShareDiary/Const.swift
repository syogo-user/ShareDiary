//
//  Const.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import UIKit
struct Const {
    static let ImagePath = "images"
    static let PostPath = "posts"
    static let Users = "users"//ユーザ
    static let Report = "report"//レポート（通報リスト）
    static let TermsOfServiceURL = "https://sharediary.sakura.ne.jp/ShareDiary/terms_of_service.html"//利用規約URL
    static let Follow = "follow" //フォロー
    static let Follower = "follower"//フォロワー
    static let FollowRequest = "followRequest"//フォローリクエスト
    
    static let FollowShowButton = "followShowButton"
    static let FollowerShowButton = "followerShowButton"
    static let Unknown = "unknown"//削除されたユーザの名前
    static let Ok = "OK"
    static let Cancel = "CANCEL"
    
    static let DarkColor = UIColor(red:0/255,green:0/255,blue:32/255,alpha:1.0)
    static let SlideColor = UIColor(red:0/255,green:0/255,blue:40/255,alpha:1.0)
    static let LightOrangeColor = UIColor(red:255/255,green:245/255,blue:229/255,alpha:1.0)
    //各ボタンのグラデーション
    static let ButtonStartColor = UIColor(red:254/255,green:225/255,blue:64/255,alpha:1.0)
    static let ButtonEndColor = UIColor(red:250/255,green:112/255,blue:154/255,alpha:1.0)
    //ナビゲーションのボタンの色
    static let NavigationButtonColor = UIColor(red:255/255,green:175/255,blue:38/255,alpha:1.0)

    //ユーザセルの高さ
    static let  CellHeight :CGFloat = 110
    //辞書型[String:CGColor]の配列
    static let BackGroundColor  = [
        ["startColor":UIColor(red:255/255,green:255/255,blue:153/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:173/255,green:255/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:252/255,green:229/255,blue:207/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:255/255,green:172/255,blue:214/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:255/255,green:172/255,blue:214/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:100/255,green:216/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:211/255,blue:253/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:10/255,green:222/255,blue:232/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:249/255,green:212/255,blue:35/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:248/255,green:54/255,blue:0/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:150/255,green:230/255,blue:161/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:10/255,green:222/255,blue:232/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:249/255,green:240/255,blue:71/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:15/255,green:216/255,blue:120/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:250/255,green:112/255,blue:154/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:255/255,green:207/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:250/255,green:112/255,blue:154/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:254/255,green:225/255,blue:64/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:100/255,blue:233/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:238/255,green:208/255,blue:233/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:253/255,green:180/255,blue:163/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:235/255,green:228/255,blue:21/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:224/255,green:195/255,blue:252/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:142/255,green:197/255,blue:252/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:42/255,green:245/255,blue:152/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:142/255,green:197/255,blue:252/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:224/255,green:195/255,blue:252/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:0/255,green:158/255,blue:253/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:179/255,green:255/255,blue:171/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:209/255,green:253/255,blue:255/255,alpha:1.0).cgColor,
        ]
    ]
    //jpg
    static let Jpg = ".jpg"
    static let Message1  = "アカウントは使用できません"
    static let Message2  = "必要項目を入力してください"
    static let Message3  = "サインインに失敗しました。"
    static let Message4  = "メールアドレスの書式で\n入力してください"
    static let Message5  = "パスワードは6桁以上で\n入力してください"
    static let Message6  = "パスワードは同じものを\n入力してください"
    static let Message7  = "ニックネームは10文字以内で\n入力してください"
    static let Message8  =  "\(Const.Unknown)は\n使用できません"
    static let Message9  = "利用規約をお読みの上、\n同意をお願いします"
    static let Message10 = "ユーザ作成に失敗しました。"
    static let Message11 = "表示名の設定に失敗しました。"
    static let Message12 = "検索に失敗しました"
    static let Message13 = "フォローの申請ができません"
    static let Message14 = "画像のアップロードが\n失敗しました"
    static let Message15 = "アカウントを削除しました"
    static let Message16 = "アカウントを削除します。よろしいですか？\n（削除後に新規アカウントを作成する場合、\n同じアドレスは30日間使用できません。）"
    static let Message17 = "複数選択は４枚までです！"
    static let Message18 = "このユーザをブロックします"
    static let Message19 = "このユーザを通報します"
    static let Message20 = "をブロックしてもよろしいですか？"
    static let Message21 = "通報の詳細をお知らせ願います。"
    static let Message22 = "不審な内容またはスパムです"
    static let Message23 = "不適切な内容を含んでいる"
    static let Message24 = "攻撃的な内容を含んでいる"
    static let Message25 = "を通報してもよろしいですか？"
    static let Message26 =  "ご連絡ありがとうございます。確認が取れ次第対応を行います。"
    static let Message27 = "自分の投稿です"
    static let Message28 = "名前が空です"
    static let Message29 = "ニックネームは10文字以内で入力してください"
    static let Message30 = "ログアウトしますか？"
    static let Message31 = "この投稿を削除してもよろしいですか？"
    static let Message32 = "新しいパスワードが一致しません"
    static let Message33 = "認証に失敗しました"
    static let Message34 = "パスワードの更新に失敗しました"
    static let Message35 = "メールアドレスを入力してください"
    static let Message36 = "認証を行うためパスワードを入力してください"
    static let Message37 = "メールアドレスの更新に失敗しました"
    static let Message38 = "アカウントを削除します。削除後データはもとに戻せませんがよろしいですか？"
    static let Message39 = "アカウントの削除が正常に行われました。"
    




    

}
