//
//  PostViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/26.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD
import DKImagePickerController


class PostViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imagePictureArray :[UIImage] = []
    //投稿ボタン
    @IBOutlet weak var postButton: UIButton!
    //キャンセルボタン
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageLayoutWorkerView: ImageLayoutWorkerView!
    var backgroundColorArrayIndex = 0
    //入力している文字の色
    var typeingColor = UIColor.black
    //選択された日付（デフォルトは今日）
    var selectDate = Date()
    //写真の配置に使用する変数を定義
    let xPosition :CGFloat  = 30.0 //x
    let yPosition :CGFloat  = 500.0 //y
    let pictureWidth :CGFloat = 828 //幅
    let pictureHeight :CGFloat = 550 //高さ
    let constantValue1 :CGFloat = 20.0 //制約
    let constantValue2 :CGFloat = 50.0 //制約
    let adjustmentValue :CGFloat = 15 //調整
    let cornerRadius1:CGFloat = 20 //角丸

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectDate = Date()
        self.typeingColor = inputTextView.tintColor
        
        //キーボード表示
        self.inputTextView.becomeFirstResponder()
        //ツールバーのインスタンスを作成
        let toolBar = UIToolbar()
        //ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        // ボタンのサイズ
        let buttonSize: CGFloat = 24
        
        //写真選択ボタン
        let imageButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        imageButton.setBackgroundImage(UIImage(named: "gallery"), for: UIControl.State())
        imageButton.addTarget(self, action: #selector(tapImageButton(_:)), for: .touchUpInside)
        let imageButtonItem = UIBarButtonItem(customView: imageButton)
        //カラー選択ボタン
        let colorButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        colorButton.setBackgroundImage(UIImage(named: "color"), for: UIControl.State())
        colorButton.addTarget(self, action: #selector(tapColorButton(_:)), for: .touchUpInside)
        let colorButtonItem = UIBarButtonItem(customView: colorButton)
        //日付選択ボタン
        let dateButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        dateButton.setBackgroundImage(UIImage(named: "calendar"), for: UIControl.State())
        dateButton.addTarget(self, action: #selector(tapDateButton(_:)), for: .touchUpInside)
        let dateButtonItem = UIBarButtonItem(customView: dateButton)
        //アイテムを配置
        toolBar.setItems([imageButtonItem,flexibleItem,dateButtonItem,flexibleItem,colorButtonItem],animated: true)
        //ツールバーのサイズを指定
        toolBar.sizeToFit()
        //デリゲートを設定
        self.inputTextView.delegate = self
        self.inputTextView.inputAccessoryView = toolBar
        self.postButton.addTarget(self, action: #selector(tapPostButton(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(tapCancelButton(_:)), for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //投稿ボタンを非活性
        if inputTextView.text == ""{
            postButton.isEnabled = false
        }
        //選択された日付をラベルに表示(初期表示は本日)
        self.dateLabel.text = CommonDate.dateFormat(date:selectDate)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        //遷移前の画面から受け取ったIndexで色を決定する
        let color = Const.BackGroundColor[backgroundColorArrayIndex]
        let color1 = color["startColor"] ?? UIColor().cgColor
        let color2 = color["endColor"] ?? UIColor().cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        //サブレイヤーがある場合は削除してからinsertSublayerする
        if self.view.layer.sublayers![0] is CAGradientLayer{
            self.view.layer.sublayers![0].removeFromSuperlayer()
            self.view.layer.insertSublayer(gradientLayer, at: 0)
        }else {
            self.view.layer.insertSublayer(gradientLayer, at:0)
        }        
        //文字の色変化
        self.typeingColor  = UIColor.black
        self.inputTextView.textColor = typeingColor
        //テキストにフォーカスを当てる
        self.inputTextView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
    
    @objc func tapCancelButton(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func tapImageButton(_ sender:UIButton){
        
        let pickerController = ImageSelectViewController()
        //imagePictureArray配列を初期化
        self.imagePictureArray = []

        pickerController.didSelectAssets = {
            [unowned self] (assets:[DKAsset])in
                        
            var index = 1
            //選択した画像を取得
            for asset in assets{
                asset.fetchFullScreenImage(completeBlock: {(image,info) in
                    //写真を配列に追加
                    guard let image = image else{return}
                    self.imagePictureArray.append(image)
                    //写真をレイアウト
                    self.imageLayoutWorkerView.imageSet(imageView: image, imageMaxCount: assets.count, index: index)
                    index = index + 1
                })                
            }
        }
        self.present(pickerController, animated: true) {}
    }


    @objc func tapColorButton(_ sender:UIButton){
        let colorChoiceViewController = self.storyboard?.instantiateViewController(withIdentifier: "ColorChoiceViewController")
        colorChoiceViewController?.modalPresentationStyle = .fullScreen
        self.present(colorChoiceViewController!, animated: true, completion: nil)
    }
    
    @objc func tapDateButton(_ sender:UIButton){
        let dateSelectViewController = self.storyboard?.instantiateViewController(withIdentifier:"DateSelectViewController")
        dateSelectViewController?.modalPresentationStyle = .fullScreen
        self.present(dateSelectViewController!,animated: true,completion:nil)
    }
    
    //投稿ボタン押下時
    @objc func tapPostButton(_ sender:UIButton){
        //連續タップ防止のために一度ボタンを非活性とする
        postButton.isEnabled = false
        //テキストが空の時は投稿できないようにする
        guard self.inputTextView.text != "" else {return}
        //HUD
        SVProgressHUD.show()
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        guard let myUid = Auth.auth().currentUser?.uid else {
            return
        }
        let documentUserName = Auth.auth().currentUser?.displayName
        let strDate = CommonDate.dateFormat(date:selectDate)
        
        //投稿するデータをまとめる
        let postDic = [
            "uid":myUid,
            "documentUserName": documentUserName!,
            "content": self.inputTextView.text!,
            "selectDate":strDate,
            "date": FieldValue.serverTimestamp(),
            "backgroundColorIndex":self.backgroundColorArrayIndex,
            "contentImageMaxNumber":imagePictureArray.count,
            ] as [String : Any]
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if imagePictureArray.count > 0 {
            var fileNumber = 1
            //投稿する写真を選択している場合
            for imagePicture in imagePictureArray.enumerated() {
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + "\(fileNumber).jpg")
                // 画像をJPEG形式に変換する
                let imageData = imagePicture.element.jpegData(compressionQuality: 0.75)
                if let imageData = imageData {
                    imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            // 画像のアップロード失敗
                            SVProgressHUD.showError(withStatus: "画像のアップロードが\n失敗しました")
                            // 投稿処理をキャンセルし、先頭画面に戻る
                            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                            return
                        }else {
                            //写真のアップロード成功
                            // FireStoreに投稿データを保存する
                            postRef.setData(postDic)
                                                        
                            //配列の最後になったら
                            if imagePicture.offset == self.imagePictureArray.count - 1 {
                                SVProgressHUD.dismiss()
                                //先頭画面に戻る
                                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
                fileNumber  = fileNumber + 1
            }
        }else{
            // FireStoreに投稿データを保存する
            //写真を投稿しない場合
            postRef.setData(postDic)
            SVProgressHUD.dismiss()
            //先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)            
        }
    }
    

    //テキストを入力すると呼び出される
    func textViewDidChange(_ textView: UITextView) {
        //テキストが空の時は投稿ボタンを非活性とする
        if inputTextView.text == "" {
            postButton.isEnabled = false
        }else{
            postButton.isEnabled = true
        }
    }

}


