//
//  PostTableViewCell.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase


class PostTableViewCell: UITableViewCell {
        
    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentsView: GradationView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var variousButton: UIButton!
    @IBOutlet weak var imageLayoutWorkerView: ImageLayoutWorkerView!

    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    
    let cornerRadius1:CGFloat = 20
    let cornerRadius2:CGFloat = 25
    override func awakeFromNib() {
        super.awakeFromNib()
        self.postUserImageView.layer.cornerRadius = cornerRadius1
        self.contentsView.layer.cornerRadius = cornerRadius2
        self.contentsView.layer.masksToBounds = true
        //影
        self.shadowView.backgroundColor = .clear
        //文字サイズをラベルの大きさに合わせて調整
        self.postUserLabel.adjustsFontSizeToFitWidth = true
        self.commentNumberLabel.adjustsFontSizeToFitWidth = true
        self.likeNumberLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func layoutSubviews() {
        //描画されるときに呼び出される
        super.layoutSubviews()

        contentsView.frame = self.bounds

    }
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    //写真を削除
    private func removeUIImageSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            if let subview = subview as? UIStackView{
                //UIStackViewが存在していたら削除する
                subview.removeFromSuperview()
            }
        }
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        //UIDを変数に設定（プロフィール写真を取得するため）
        let imageMaxNumber  = postData.contentImageMaxNumber
        //StackViewを削除
        self.removeUIImageSubviews(parentView: self.contentsView)
        //投稿された写真の表示
        imageLayoutWorkerView.imageSet(imageMaxCount: imageMaxNumber,imageName:postData.id)
        //プロフィール写真の設定
        self.setMyImage(imageName: postData.profileImageName)
        //画面表示
        self.displaySet(postData: postData)
    }
    //画面描画
    private func displaySet(postData:PostData){
        //投稿者の名前
        self.postUserLabel.text = ""
        if let documentUserName = postData.documentUserName {
            self.postUserLabel.text = "\(documentUserName)"
        }
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        //いいねの配列に値を代入
        let likeArray = postData.likes
        
        // いいね数の表示
        let likeNumber = likeArray.count
        likeNumberLabel.text = ""
        likeNumberLabel.text = "\(likeNumber)"
        
        //コメント数の表示
        let commentNumber = postData.commentsId.count
        commentNumberLabel.text = ""
        commentNumberLabel.text = "\(commentNumber)"
        //コメントボタンの表示
        if postData.isCommented {
            let buttonImage = UIImage(named: "reply_exist")
            self.commentButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "reply_none")
            self.commentButton.setImage(buttonImage, for: .normal)
        }
        
        // 日時の表示
        self.dateLabel.text = ""
        if let selectDate = postData.selectDate {
            self.dateLabel.text = selectDate
        }
        // コンテントの表示
        self.contentLabel.text = ""
        if let content = postData.content{
            self.contentLabel.text! = content
        }
        //背景色を設定
        contentsView.setBackgroundColor(colorIndex:postData.backgroundColorIndex)        
    }
    
    private func setPostImage(uid:String){
        print("DEBUG:setPostImage")
        let userRef = Firestore.firestore().collection(Const.Users).document(uid)
        userRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                if let document = querySnapshot!.data(){
                    let imageName = document["myImageName"] as? String ?? ""
                    print("DEBUG:myImageNameUid:\(uid)")
                    print("DEBUG:myImageName:\(imageName)")
                    self.setMyImage(imageName:imageName)
                }
            }
        }
    }
    
    private func setMyImage(imageName:String){
        //画像の取得
         let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + Const.Jpg)
         
         //画像がなければデフォルトの画像表示
         if imageName == "" {
             self.postUserImageView.image = UIImage(named: Const.Unknown)
         }else{
             //取得した画像の表示
             self.postUserImageView.sd_imageIndicator =
                 SDWebImageActivityIndicator.gray
             self.postUserImageView.sd_setImage(with: imageRef)
         }
    }
    
}
