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

protocol PostTableViewCellDelegate {
    func imageTransition(_ sender:UITapGestureRecognizer)
}


class PostTableViewCell: UITableViewCell {
        
    @IBOutlet weak var postUserImageView: UIImageView!
    @IBOutlet weak var postUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentsView: GradationView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var variousButton: UIButton!

    //デリゲート
    var postTableViewCellDelegate :PostTableViewCellDelegate?
    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    
    let contentLabelBottomConstraint0:CGFloat = 50  //contentLabelから下の長さ
    let contentLabelBottomConstraint1:CGFloat = 350 //contentLabelから下の長さ
    let contentLabelBottomConstraint2:CGFloat = 240 //contentLabelから下の長さ
    let contentLabelBottomConstraint3:CGFloat = 390 //contentLabelから下の長さ
    let contentLabelBottomConstraint4:CGFloat = 350 //contentLabelから下の長さ

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.postUserImageView.layer.cornerRadius = 20
        self.contentsView.layer.cornerRadius = 25
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
        
    //image:選択した写真,index：選択した何枚目,maxCount：選択した全枚数
    private func imageSet(imageRef:StorageReference,index:Int,maxCount:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        //imageViewの初期化
        let imageView = UIImageView()
        //タップイベント追加
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        //画像のアスペクト比　sacaleAspectFil：写真の比率は変わらない。imageViewの枠を超える。cliptToBounds をtrueにしているため枠は超えずに、比率も変わらない。
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black

        //画像の枚数によってサイズと配置場所を設定する
        switch maxCount {
        case 1:
            //画像１枚の場合
            self.imageCount1(imageRef:imageRef,imageView: imageView,stackViewHorizon1:stackViewHorizon1)
        case 2:
            //画像２枚の場合
            self.imageCount2(imageRef:imageRef,imageView: imageView,index:index,stackViewHorizon1:stackViewHorizon1)
        case 3:
            //画像３枚の場合
            self.imageCount3(imageRef:imageRef,imageView: imageView,index:index,stackViewHorizon1: stackViewHorizon1,stackViewHorizon2: stackViewHorizon2)
        case 4:
            //画像４枚の場合
            self.imageCount4(imageRef:imageRef,imageView: imageView,index:index,stackViewHorizon1:stackViewHorizon1,stackViewHorizon2:stackViewHorizon2)

        default: break
            
        }
        
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
    //フルサイズの写真をモーダルで表示
    @objc func imageTransition(_ sender:UITapGestureRecognizer){
        postTableViewCellDelegate?.imageTransition(sender)
    }
    
    private func imageCount1(imageRef:StorageReference,imageView:UIImageView,stackViewHorizon1:UIStackView){
        //x軸方向並び
        stackViewHorizon1.axis = .horizontal
        //translatesAutoresizingMaskIntoConstraintsの文言が必要
        stackViewHorizon1.translatesAutoresizingMaskIntoConstraints = false
        //すべて同じ幅
        stackViewHorizon1.distribution = .fillEqually
        
        stackViewHorizon1.topAnchor.constraint(equalTo: contentLabel.bottomAnchor,constant: self.constantValue2).isActive = true
        stackViewHorizon1.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor).isActive = true
        stackViewHorizon1.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor).isActive = true
        stackViewHorizon1.heightAnchor.constraint(equalToConstant: 250 ).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        //角丸 左上 右上 左下 右下
        imageView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner]
        imageView.sd_setImage(with: imageRef)
        //スタックビューに写真を追加
        stackViewHorizon1.addArrangedSubview(imageView)
    }
    
    private func imageCount2(imageRef:StorageReference,imageView:UIImageView,index:Int,stackViewHorizon1:UIStackView){
        switch index {
        case 1:
            //x軸方向並び
            stackViewHorizon1.axis = .horizontal
            //translatesAutoresizingMaskIntoConstraintsの文言が必要
            stackViewHorizon1.translatesAutoresizingMaskIntoConstraints = false
            //すべて同じ幅
            stackViewHorizon1.distribution = .fillEqually
            stackViewHorizon1.topAnchor.constraint(equalTo: contentLabel.bottomAnchor,constant: self.constantValue2).isActive = true
            stackViewHorizon1.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor).isActive = true
            stackViewHorizon1.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor).isActive = true
            stackViewHorizon1.heightAnchor.constraint(equalToConstant: 130 ).isActive = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 20
            //角丸 左上 左下
            imageView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon1.addArrangedSubview(imageView)
        case 2:
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 20
            //角丸 右上 右下
            imageView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon1.addArrangedSubview(imageView)
        default:
            break
        }
        
    }
    private func imageCount3(imageRef:StorageReference,imageView:UIImageView,index:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        switch index {
        case 1:
            self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            imageView.layer.cornerRadius = 20
            //角丸 左上
            imageView.layer.maskedCorners = [.layerMinXMinYCorner]
        case 2:
            self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            imageView.layer.cornerRadius = 20
            //角丸 右上
            imageView.layer.maskedCorners = [.layerMaxXMinYCorner]
        case 3:
            //x軸方向に横並び
            stackViewHorizon2.axis = .horizontal
            stackViewHorizon2.translatesAutoresizingMaskIntoConstraints = false
            //すべて同じ幅
            stackViewHorizon2.distribution = .fillEqually
            
            stackViewHorizon2.topAnchor.constraint(equalTo: contentLabel.bottomAnchor,constant: 180).isActive = true
            stackViewHorizon2.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor).isActive = true
            stackViewHorizon2.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor).isActive = true
            stackViewHorizon2.heightAnchor.constraint(equalToConstant: 170 ).isActive = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 20
            //角丸 左下 右下
            imageView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon2.addArrangedSubview(imageView)

        default:
            break
        }
    }
    private func imageCount4(imageRef:StorageReference,imageView:UIImageView,index:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        switch index {
        case 1:
            self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            imageView.layer.cornerRadius = 20
            //角丸 左上
            imageView.layer.maskedCorners = [.layerMinXMinYCorner]
        case 2:
            self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            imageView.layer.cornerRadius = 20
            //角丸 右上
            imageView.layer.maskedCorners = [.layerMaxXMinYCorner]
        case 3:
            //x軸方向並び
            stackViewHorizon2.axis = .horizontal
            //translatesAutoresizingMaskIntoConstraintsの文言が必要
            stackViewHorizon2.translatesAutoresizingMaskIntoConstraints = false
            //すべて同じ幅
            stackViewHorizon2.distribution = .fillEqually
            
            stackViewHorizon2.topAnchor.constraint(equalTo: contentLabel.bottomAnchor,constant: 180).isActive = true
            stackViewHorizon2.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor).isActive = true
            stackViewHorizon2.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor).isActive = true
            stackViewHorizon2.heightAnchor.constraint(equalToConstant: 130 ).isActive = true
            
            
            imageView.translatesAutoresizingMaskIntoConstraints = false

            imageView.sd_setImage(with: imageRef)
            imageView.layer.cornerRadius = 20
            //角丸 左下
            imageView.layer.maskedCorners = [.layerMinXMaxYCorner]
            //スタックビューに写真を追加
            stackViewHorizon2.addArrangedSubview(imageView)
        case 4:
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 20
            //角丸 右下
            imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon2.addArrangedSubview(imageView)
        default:
            break
        }
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        //UIDを変数に設定（プロフィール写真を取得するため）
        let imageMaxNumber  = postData.contentImageMaxNumber
        //StackViewを削除
        self.removeUIImageSubviews(parentView: self.contentsView)
        //投稿写真の枚数分ループする (1,2,3,4)
        //投稿された写真の表示
        if imageMaxNumber > 0{
            //外枠のStackViewの生成
            let stackView = UIStackView()
            
            //y軸方向並び
            stackView.axis = .vertical

            stackView.translatesAutoresizingMaskIntoConstraints = false
            //外枠のスタックビューをビューに設定
            self.contentsView.addSubview(stackView)
            //制約
            stackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor,constant: self.constantValue2).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor).isActive = true
            if imageMaxNumber <= 3{
                //1〜3枚の場合
                stackView.heightAnchor.constraint(equalToConstant: 300 ).isActive = true
            } else {
                //4枚の場合
                stackView.heightAnchor.constraint(equalToConstant: 260 ).isActive = true
            }
            //内側のスタックビュー1を生成
            let stackViewHorizon1 = UIStackView()
            stackViewHorizon1.layer.masksToBounds = true
            //内側のスタックビューを外枠のスタックビューに設定
            stackView.addArrangedSubview(stackViewHorizon1)

            //内側のスタックビュー2を生成
            let stackViewHorizon2 = UIStackView()
            stackViewHorizon2.layer.masksToBounds = true
            //内側のスタックビューを外枠のスタックビューに設定
            stackView.addArrangedSubview(stackViewHorizon2)
            
            for i in 1...imageMaxNumber{
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + "\(i)\(Const.Jpg)")
                imageSet(imageRef:imageRef ,index: i, maxCount: imageMaxNumber,stackViewHorizon1:stackViewHorizon1,stackViewHorizon2:stackViewHorizon2)
            }
        }
        //プロフィール写真の設定
        self.setMyImage(imageName: postData.profileImageName)
        
        switch imageMaxNumber {
        case 0:
            //写真の枚数が0枚の場合
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint0
        case 1:
            //写真の枚数が1枚の場合
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint1
        case 2:
            //写真の枚数が2枚の場合
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint2
        case 3:
            //写真の枚数が3枚の場合
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint3
        case 4:
            //写真の枚数が4枚の場合
            contentLabelBottomConstraint.constant = contentLabelBottomConstraint4
            
        default: break
        }
        
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
        

        
        
        

            


//                self.setPostImage(uid:self.postDataUid)//この処理をlayoutSubviewsに変更
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
