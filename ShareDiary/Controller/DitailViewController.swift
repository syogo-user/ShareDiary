//
//  DitailViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
class DitailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeUserButton: UIButton!
    @IBOutlet weak var diaryDate: UILabel!
    @IBOutlet weak var postDeleteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView1: UIView!
    @IBOutlet weak var diaryText: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    var scrollFlg :Bool = false //下部（コメントエリア）にスクロールさせるかの判定
    var postData :PostData?
    var commentData : [CommentData] = [CommentData]()
    private let contentInset :UIEdgeInsets = .init(top: 0, left: 0, bottom: 100, right: 0)
    private let indicateInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 100, right: 0)
    //セルの高さ（最低基準）
    private let cellHeight :CGFloat = 100
    
    private lazy var inputTextView : InputTextView = {
        let view = InputTextView()      
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    
    //Viewの高さ設定
    let headerViewHeight0:CGFloat = 250 //写真0枚のとき
    let headerViewHeight1:CGFloat = 500 //写真1枚のとき
    let headerViewHeight2:CGFloat = 400 //写真2枚のとき
    let headerViewHeight3:CGFloat = 550 //写真3枚のとき
    let headerViewHeight4:CGFloat = 500 //写真4枚のとき
    
    //元々持っている；プロパティ
    override var inputAccessoryView: UIView?{
        //inputAccessoryViewにInputTextViewを設定する
        get {
            return inputTextView
        }
    }
    
    override  var canBecomeFirstResponder: Bool{
        return true
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()        
        //グラーデションのフレームの大きさを設定
        gradientLayer.frame = self.containerView1.layer.bounds
    }
    
    
    //描画が終わったあとに呼び出される
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let post = postData else {return}
        
        //選択された写真の枚数
        let imageMaxNumber  = post.contentImageMaxNumber
        switch imageMaxNumber {
        case 0:
            //写真の枚数が0枚の場合
            self.containerView1.frame = CGRect (x:0,y:0,width: containerView1.frame.width,height: headerViewHeight0 + diaryText.frame.height)
            self.viewHeader.frame = CGRect (x:0,y:0,width: viewHeader.frame.width,height: headerViewHeight0 + diaryText.frame.height)
        case 1:
            //写真の枚数が1枚の場合
            self.containerView1.frame = CGRect (x:0,y:0,width: containerView1.frame.width,height: headerViewHeight1 + diaryText.frame.height)
            self.viewHeader.frame = CGRect (x:0,y:0,width: viewHeader.frame.width,height: headerViewHeight1 + diaryText.frame.height)
        case 2:
            //写真の枚数が2枚の場合
            self.containerView1.frame = CGRect (x:0,y:0,width: containerView1.frame.width,height: headerViewHeight2 + diaryText.frame.height)
            self.viewHeader.frame = CGRect (x:0,y:0,width: viewHeader.frame.width,height: headerViewHeight2 + diaryText.frame.height)
            
        case 3:
            //写真の枚数が3枚の場合
            self.containerView1.frame = CGRect (x:0,y:0,width: containerView1.frame.width,height: headerViewHeight3 + diaryText.frame.height)
            self.viewHeader.frame = CGRect (x:0,y:0,width: viewHeader.frame.width,height: headerViewHeight3 + diaryText.frame.height)
        case 4:
            //写真の枚数が4枚の場合
            self.containerView1.frame = CGRect (x:0,y:0,width: containerView1.frame.width,height: headerViewHeight4 + diaryText.frame.height)
            self.viewHeader.frame = CGRect (x:0,y:0,width: viewHeader.frame.width,height: headerViewHeight4 + diaryText.frame.height)
            
        default: break
            
        }
        //テーブルの高さが確定したあとにテーブルの再更新をかけてtableViewのcontentSizeを再設定する
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //カスタムセルを登録する(Cellで登録)xib
        let nib = UINib(nibName: "CommentTableViewCell", bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CommentTableViewCell")
        self.tableView.backgroundColor = Const.LightOrangeColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        //いいねボタンのアクションを設定
        self.likeButton.addTarget(self, action:#selector(likeButton(_:forEvent:)), for: .touchUpInside)
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        self.imageView.layer.cornerRadius = 30
        guard let post = postData else {return}
        //削除ステータスのユーザを除外した後に画面項目を設定
        self.accountDeleteStateGet(post: post)
        
        //自分のuidではなかった時は削除ボタンを非表示
        if post.uid != Auth.auth().currentUser?.uid {
            self.postDeleteButton.isHidden = true//非表示
            self.postDeleteButton.isEnabled = false//非活性
        }else {
            self.postDeleteButton.isHidden = false//表示
            self.postDeleteButton.isEnabled = true//活性
        }
        //削除ボタン押下時
        self.postDeleteButton.addTarget(self, action: #selector(postDelete(_:)), for: .touchUpInside)
        //likeUserButton押下時
        self.likeUserButton.addTarget(self, action: #selector(likeUserShow(_:)), for: .touchUpInside)
        
        //スクロールでキーボードをしまう
        self.tableView.keyboardDismissMode = .interactive
        setupNotification()
        
        self.containerView1.layer.cornerRadius = 25
        self.containerView1.clipsToBounds = true
        self.viewHeader.clipsToBounds = true
        self.viewHeader.layer.cornerRadius   = 25
        self.viewHeader.backgroundColor = .clear
        //文字サイズをボタンの大きさに合わせて調整
        self.likeUserButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //文字サイズをラベルの大きさに合わせて調整
        self.userName.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //レイアウト終了（viewDidLayoutSubviews()）の後
        super.viewDidAppear(true)
        //描画後
        //初期表示後はスクロールをtrueとする
        self.scrollFlg = true
    }
    
    //image:選択した写真,index：選択した何枚目,maxCount：選択した全枚数
    private func imageSet(imageRef:StorageReference,index:Int,maxCount:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        //imageViewの初期化
        let imageView = UIImageView()
        //タップイベント追加
        imageView.isUserInteractionEnabled = true //画像のタップを有効化。
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        
        let swipeUp = UISwipeGestureRecognizer(target:self,action:nil)
        swipeUp.direction = .up
        imageView.addGestureRecognizer(swipeUp)
        
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
            if let subview = subview as? UIImageView{
                //UIImageViewが存在していたら削除する
                subview.removeFromSuperview()
            }
        }
    }
    //フルサイズの写真をモーダルで表示
    @objc func imageTransition(_ sender:UITapGestureRecognizer){
        //画面遷移
        //タップしたUIImageViewを取得
        let tappedImageView = sender.view! as! UIImageView
        //  UIImage を取得
        let tappedImage = tappedImageView.image!
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)        
    }
    
    private func imageCount1(imageRef:StorageReference,imageView:UIImageView,stackViewHorizon1:UIStackView){
        //x軸方向並び
        stackViewHorizon1.axis = .horizontal
        //translatesAutoresizingMaskIntoConstraintsの文言が必要
        stackViewHorizon1.translatesAutoresizingMaskIntoConstraints = false
        //すべて同じ幅
        stackViewHorizon1.distribution = .fillEqually
        
        stackViewHorizon1.topAnchor.constraint(equalTo: self.diaryText.bottomAnchor,constant: self.constantValue2).isActive = true
        stackViewHorizon1.trailingAnchor.constraint(equalTo: self.diaryText.trailingAnchor).isActive = true
        stackViewHorizon1.leadingAnchor.constraint(equalTo: self.diaryText.leadingAnchor).isActive = true
        stackViewHorizon1.heightAnchor.constraint(equalToConstant: 250 ).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
            stackViewHorizon1.topAnchor.constraint(equalTo: self.diaryText.bottomAnchor,constant: self.constantValue2).isActive = true
            stackViewHorizon1.trailingAnchor.constraint(equalTo: self.diaryText.trailingAnchor).isActive = true
            stackViewHorizon1.leadingAnchor.constraint(equalTo: self.diaryText.leadingAnchor).isActive = true
            stackViewHorizon1.heightAnchor.constraint(equalToConstant: 130 ).isActive = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon1.addArrangedSubview(imageView)
        case 2:
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.sd_setImage(with: imageRef)
            //スタックビューに写真を追加
            stackViewHorizon1.addArrangedSubview(imageView)

        default:
            break
        }
        
    }
    private func imageCount3(imageRef:StorageReference,imageView:UIImageView,index:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        switch index {
            case 1,2:
                self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            case 3:
                //x軸方向に横並び
                stackViewHorizon2.axis = .horizontal
                stackViewHorizon2.translatesAutoresizingMaskIntoConstraints = false
                //すべて同じ幅
                stackViewHorizon2.distribution = .fillEqually
                
                stackViewHorizon2.topAnchor.constraint(equalTo: self.diaryText.bottomAnchor,constant: 180).isActive = true
                stackViewHorizon2.trailingAnchor.constraint(equalTo: self.diaryText.trailingAnchor).isActive = true
                stackViewHorizon2.leadingAnchor.constraint(equalTo: self.diaryText.leadingAnchor).isActive = true
                stackViewHorizon2.heightAnchor.constraint(equalToConstant: 170 ).isActive = true
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.sd_setImage(with: imageRef)
                //スタックビューに写真を追加
                stackViewHorizon2.addArrangedSubview(imageView)
            
        default:
            break
        }
    }
    private func imageCount4(imageRef:StorageReference,imageView:UIImageView,index:Int,stackViewHorizon1:UIStackView,stackViewHorizon2:UIStackView){
        switch index {
            case 1,2:
                self.imageCount2(imageRef: imageRef, imageView: imageView, index: index, stackViewHorizon1: stackViewHorizon1)
            case 3:
                //x軸方向並び
                stackViewHorizon2.axis = .horizontal
                //translatesAutoresizingMaskIntoConstraintsの文言が必要
                stackViewHorizon2.translatesAutoresizingMaskIntoConstraints = false
                //すべて同じ幅
                stackViewHorizon2.distribution = .fillEqually
                
                stackViewHorizon2.topAnchor.constraint(equalTo: self.diaryText.bottomAnchor,constant: 180).isActive = true
                stackViewHorizon2.trailingAnchor.constraint(equalTo: self.diaryText.trailingAnchor).isActive = true
                stackViewHorizon2.leadingAnchor.constraint(equalTo: self.diaryText.leadingAnchor).isActive = true
                stackViewHorizon2.heightAnchor.constraint(equalToConstant: 130 ).isActive = true
                
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.sd_setImage(with: imageRef)
                //スタックビューに写真を追加
                stackViewHorizon2.addArrangedSubview(imageView)
            case 4:
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.sd_setImage(with: imageRef)
                //スタックビューに写真を追加
                stackViewHorizon2.addArrangedSubview(imageView)
            
        default:
            break
        }
    }
    
    
    private func setupNotification() {
        //キーボードが出てくる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //キーボードが隠れる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func keyboardWillShow(notification:NSNotification){
        guard let userInfo =  notification.userInfo else {return}
        if let keyboadFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue{
            let bottom = keyboadFrame.height
            //スクロールビューをキーボードの分高さを上にあげる
            let contentInset = UIEdgeInsets(top:0,left:0,bottom:bottom,right: 0)
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }
    }
    @objc func keyboardWillHide(){
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = indicateInset
    }
    
    //テーブルビューの表示
    private func tableViewSet(accountDeleteArray:[String]){
        guard let postDataId = postData?.id else { return }
        Firestore.firestore().collection(Const.PostPath).document(postDataId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if err != nil {
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let comment = CommentData(document:dic)
                    //ユーザが削除されていた場合の対応としてユーザ名が取得できないものはunknowと表示する
                    comment.userName = Const.Unknown
                    //ユーザ名を取得
                    let commentUserRef = Firestore.firestore().collection(Const.Users).document(comment.uid)
                    commentUserRef.getDocument{
                        (querySnapshot,error) in
                        if let error  = error {
                            print("DEBUG: snapshotの取得が失敗しました。\(error)")
                            return
                        }else {
                            guard let document = querySnapshot!.data() else {return}
                            //ユーザ名取得
                            let userName = document["userName"] as? String ?? ""
                            //ユーザ名をcommentDataに追加
                            comment.userName =  userName
                            //配列に追加
                            self.commentData.append(comment)
                            //ソート
                            self.commentData.sort { (m1, m2) -> Bool in
                                let m1Date = m1.createdAt.dateValue()
                                let m2Date = m2.createdAt.dateValue()
                                return m1Date < m2Date
                            }
                            
                            //削除ステータスが0より大きいユーザはユーザ名とメッセージを以下の文言とする
                            for (index,comment) in self.commentData.enumerated(){
                                if accountDeleteArray.firstIndex(of: comment.uid) != nil{
                                    self.commentData[index].message = "NoMessage"
                                    self.commentData[index].userName = Const.Unknown
                                }
                            }
                            //画面更新
                            self.tableView.reloadData()
                            
                            if self.scrollFlg {//scrollFlg がtrue（コメントボタン押下時の遷移）
                                //コメントボタンを押下し、遷移した場合
                                self.tableView.scrollToRow(at: IndexPath(row:self.commentData.count - 1 , section: 0), at:.bottom, animated: true)
                            }
                        }
                    }
                    
                case .modified, .removed:
                    print(".modified, .removed:")
                }
            })
            
        }
    }
    
    //画面項目の設定
    private func contentSet(post:PostData,accountDeleteArray:[String]){
        //ユーザ名
        self.userName.text = post.documentUserName ?? ""
        // いいねボタンの表示
        if post.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
            
        //いいね数の表示
        let likeNumber = post.likes.count
        self.likeUserButton.setTitle(likeNumber.description, for: .normal)  //文字列変換
        likeUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)//フォントサイズ
        likeUserButton.setTitleColor(.black, for: .normal)
        
        // 日時の表示
        self.diaryDate.text = ""
        if let selectDate = post.selectDate {
            self.diaryDate.text = selectDate
        }
        // コンテントの表示
        self.diaryText.text = ""
        if let content = post.content{
            self.diaryText.text! = content
        }
        //選択された写真の枚数
        let imageMaxNumber  = post.contentImageMaxNumber
        let postDocumentId = post.id
        
        //投稿写真の枚数分ループする (1,2,3,4)
        //投稿された写真の表示
        if imageMaxNumber > 0{
            //外枠のStackViewの生成
            let stackView = UIStackView()
            //y軸方向並び
            stackView.axis = .vertical
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            //外枠のスタックビューをビューに設定
            self.containerView1.addSubview(stackView)
            //制約
            stackView.topAnchor.constraint(equalTo: self.diaryText.bottomAnchor,constant: self.constantValue2).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.diaryText.trailingAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.diaryText.leadingAnchor).isActive = true
            if imageMaxNumber <= 3{
                //1〜3枚の場合
                stackView.heightAnchor.constraint(equalToConstant: 300 ).isActive = true
            } else {
                //4枚の場合
                stackView.heightAnchor.constraint(equalToConstant: 260 ).isActive = true
            }
            //内側のスタックビュー1を生成
            let stackViewHorizon1 = UIStackView()
            //内側のスタックビューを外枠のスタックビューに設定
            stackView.addArrangedSubview(stackViewHorizon1)
            
            //内側のスタックビュー2を生成
            let stackViewHorizon2 = UIStackView()
            //内側のスタックビューを外枠のスタックビューに設定
            stackView.addArrangedSubview(stackViewHorizon2)
            
            for i in 1...imageMaxNumber{
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postDocumentId + "\(i)\(Const.Jpg)")
                imageSet(imageRef:imageRef ,index: i, maxCount: imageMaxNumber,stackViewHorizon1:stackViewHorizon1,stackViewHorizon2:stackViewHorizon2)
            }
        }
        
        //プロフィール写真を設定
        setPostImage(uid:post.uid)
        //背景色を設定
        setBackgroundColor(colorIndex:post.backgroundColorIndex)
    }
    private func reloadLikeShow(accountDeleteArray:[String],postId:String){
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
        
        postRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                guard let likes = document["likes"] as? [String] else {return}
                
                guard let myid = Auth.auth().currentUser?.uid else {return}
                // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
                if likes.firstIndex(of: myid) != nil {
                    // myidがあれば、いいねを押していると認識する。
                    let buttonImage = UIImage(named: "like_exist")
                    self.likeButton.setImage(buttonImage, for: .normal)
                    //変数に設定
                    self.postData?.isLiked = true
                }else {
                    //いいねを押していない
                    let buttonImage = UIImage(named: "like_none")
                    self.likeButton.setImage(buttonImage, for: .normal)
                    //変数に設定
                    self.postData?.isLiked = false
                }
                
                
                //変数にもlikesを設定
                self.postData?.likes = likes
                //いいね数の表示
                let likeNumber = likes.count
                self.likeUserButton.setTitle(likeNumber.description, for: .normal)  //文字列変換
                self.likeUserButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)//フォントサイズ
                self.likeUserButton.setTitleColor(.black, for: .normal)
                
            }
        }
    }
    private func setPostImage(uid:String){
        let userRef = Firestore.firestore().collection(Const.Users).document(uid)
        
        userRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                if let document = querySnapshot!.data(){
                    let imageName = document["myImageName"] as? String ?? ""
                    //画像の取得
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + Const.Jpg)
                    //画像がなければデフォルトの画像表示
                    if imageName == "" {
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
    }
    //背景色設定
    private func setBackgroundColor(colorIndex:Int){
        //背景色を変更する
        let color = Const.BackGroundColor[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ?? UIColor.white.cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        
        if self.containerView1.layer.sublayers![0] is CAGradientLayer {
            self.containerView1.layer.sublayers![0].removeFromSuperlayer()
            self.containerView1.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.containerView1.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    @objc func postDelete(_ sender:UIButton){
        guard let post = postData else {return}
        //確認メッセージ出力
        let alert : UIAlertController = UIAlertController(title: Const.Message31, message :nil, preferredStyle: UIAlertController.Style.alert)
        var count = 0
        //OKボタン押下時
        let defaultAction :UIAlertAction = UIAlertAction(title: Const.Ok, style: UIAlertAction.Style.default, handler: {
            (action :UIAlertAction! ) -> Void in
            //以下OKボタンが押された時の動作
            //・firestoreからドキュメントを削除
            let postsRef = Firestore.firestore().collection(Const.PostPath).document(post.id)
            postsRef.delete()
            //写真の枚数
            let imageMaxNumber  = post.contentImageMaxNumber
            if imageMaxNumber == 0{
                //写真の枚数が0枚だったら一つ前の画面に戻る
                self.navigationController?.popToRootViewController(animated: true)
            }else {                
                for i in 1...imageMaxNumber{
                    //・firestorageから写真を削除
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(post.id + "\(i).jpg")
                    imageRef.delete{ error in
                        if let error = error {
                            print("DEBUG: \(error)")
                        } else {
                            //for文のiだとdeleteの中では1から順にならないことがあるためcount変数を用意
                            count = count + 1
                            if count == imageMaxNumber {
                                //最後の写真を削除し終わったら、一つ前の画面に戻る
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        })
        
        //キャンセルボタン押下時 → 何もしない
        let cancelAction : UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:nil)
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        //Alertを表示
        present(alert,animated: true)
        
    }
    // いいねボタンがタップされた時に呼ばれるメソッド
    @objc func likeButton(_ sender: UIButton, forEvent event: UIEvent) {
        guard let postData = postData else{ return }
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
            
            //削除ステータスのユーザを除外し、いいねの再表示
            self.accountDeleteStateGet(postId:postData.id)
        }
    }
    //likeUserButton押下時
    @objc func likeUserShow(_:UIButton) {
        //画面遷移
        let likeUserListTableViewController = storyboard?.instantiateViewController(withIdentifier: "LikeUserListTableViewController") as! LikeUserListTableViewController
        let likeUserArray :[String] = self.postData?.likes ?? []
        var userPostArray :[UserPostData] = []
        var index = 0
        //likeUserArrayからuserPostArrayを作成
        for likeUserUid in likeUserArray{
            let postRef = Firestore.firestore().collection(Const.Users).document(likeUserUid)
            postRef.getDocument{
                (document ,error) in
                if error != nil {
                    print("DEBUG: snapshotの取得が失敗しました。")
                    return
                }
                //userNameとuserImageViewを設定
                guard let document = document else {return}
                userPostArray.append(UserPostData(document:document))
                
                index = index + 1
                //
                if index == likeUserArray.count {
                    likeUserListTableViewController.userPostArray = userPostArray
                    self.present(likeUserListTableViewController, animated: true, completion: nil)
                }                
            }
        }
        
    }
    
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(postId:String){
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
                //いいねの表示を再描画する
                self.reloadLikeShow(accountDeleteArray:accountDeleteArray,postId:postId)
                
                
            }
        }
        
    }
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(post:PostData){
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
                
                //コンテンツ描画
                self.contentSet(post: post,accountDeleteArray:accountDeleteArray)
                //コメント表示
                self.tableViewSet(accountDeleteArray: accountDeleteArray)
            }
        }
    }
}
//作成したデリゲートを使用する
extension DitailViewController :InputTextViewDelegate{
    //InputTextViewのsubmitButtonが押された時に実行される処理
    func tapSubmitButton(text: String) {
        guard let postDataId = postData?.id else {return }
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let messageId = randomString(length: 20)
        
        let docData = [
            "uid": myUid,
            "createdAt": Timestamp(),
            "message": text,
            ] as [String : Any]
        //入力欄をクリア
        self.inputTextView.textClear()
        
        Firestore.firestore().collection(Const.PostPath).document(postDataId).collection("messages").document(messageId).setData(docData) {(err) in
            if let err = err {
                print("DEBUG:\(err)")
                return
            }
            
            //postDataにもコメントデータを追加
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postDataId)
            //コメントしたユーザのuidを追加する
            var updateValueUid: FieldValue
            updateValueUid = FieldValue.arrayUnion([myUid])
            postRef.updateData(["comments":updateValueUid])
            //コメントのIDを追加する
            var updateValueId:FieldValue
            updateValueId = FieldValue.arrayUnion([messageId])
            postRef.updateData(["commentsId":updateValueId])
            
        }
        
        
    }
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    
}

extension DitailViewController :UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //高さの最低基準
        self.tableView.estimatedRowHeight = cellHeight
        //高さをコメントに合わせる
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.translatesAutoresizingMaskIntoConstraints = false
        //Cell に値を設定する
        cell.setCommentData(commentData[indexPath.row])
        return cell
    }
}
