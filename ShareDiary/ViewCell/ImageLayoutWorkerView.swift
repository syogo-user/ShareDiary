//
//  ImageLayoutWorkerView.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2021/01/08.
//  Copyright © 2021 syogo-user. All rights reserved.
//


import UIKit
import FirebaseUI
import Firebase
protocol ImageLayoutWorkerViewCellDelegate {
    func imageTransition(_ sender:UITapGestureRecognizer)
}
class ImageLayoutWorkerView: UIView {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    @IBOutlet weak var stackViewTop: UIStackView!
    @IBOutlet weak var stackViewBottom: UIStackView!
    
    @IBOutlet weak var stackViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomHeight: NSLayoutConstraint!
    var imageMaxCount : Int = 0 //写真の枚数
    let cornerRadius1:CGFloat = 20
    let cornerRadius2:CGFloat = 0
    
    let noneHeight:CGFloat = 0.0
    let height1:CGFloat = 250.0
    let height2:CGFloat = 150.0
    let height3:CGFloat = 130.0
    let height3_2:CGFloat = 170.0
    let height4:CGFloat = 130.0
    //デリゲート
    var imageLayoutWorkerViewCellDelegate :ImageLayoutWorkerViewCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    private func loadNib() {
        if let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self)?.first as? UIView {
            view.frame = self.bounds
            view.layer.cornerRadius = cornerRadius1
            view.backgroundColor = UIColor.clear
            self.addSubview(view)
        }
    }
    //画像の配置（タイムラインと詳細画面の処理）
    func imageSet(imageMaxCount:Int,imageName:String){
        //プロパティのimageMaxCountに設定
        self.imageMaxCount = imageMaxCount
        
        if imageMaxCount > 0{
            for i in 1...imageMaxCount{
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + "\(i)\(Const.Jpg)")
                imageSetLayout(imageRef:imageRef ,index: i, imageMaxCount: imageMaxCount)
            }
        }else{
            //写真が0枚の場合
            self.stackViewTopHeight.constant = 0.0
            self.stackViewBottomHeight.constant = 0.0
        }
    }
    //画像の配置（投稿画面からの処理）
    func imageSet(imageView:UIImage,imageMaxCount:Int,index:Int){
        switch index{
        case 1 :
            self.image1.image = imageView
        case 2 :
            self.image2.image = imageView
        case 3 :
            self.image3.image = imageView
        case 4 :
            self.image4.image = imageView
        default:
            break
        }
        self.imageLayout(imageMaxCount: imageMaxCount)
    }
    
    func imageSetLayout(imageRef:StorageReference ,index: Int, imageMaxCount: Int){
        print("DEBUG:imageSetLayout　　\(imageMaxCount)枚")
        switch index {
        case 1:
            self.image1.sd_setImage(with: imageRef)
            //非表示　存在しないこととしてstackViewに自動レイアウトしてもらう。
        case 2:
            self.image2.sd_setImage(with: imageRef)
        case 3:
            self.image3.sd_setImage(with: imageRef)
        case 4:
            self.image4.sd_setImage(with: imageRef)
        default:
            print("default")
        }
        
        //写真のレイアウト
        self.imageLayout(imageMaxCount: imageMaxCount)
        //タップイベント追加
        self.addTapEvent()
        

    }
    private func imageLayout(imageMaxCount:Int){
        switch imageMaxCount{
        case 1:
            //非表示　存在しないこととしてstackViewに自動レイアウトしてもらう。
            self.image1.isHidden = false //表示
            self.image2.isHidden  = true //非表示
            self.image3.isHidden  = true //非表示
            self.image4.isHidden  = true //非表示
                    
            self.stackViewTopHeight.constant = height1
            self.stackViewBottomHeight.constant = noneHeight
            
            //角丸
            self.image1.layer.cornerRadius = cornerRadius1
            self.stackViewTop.layer.cornerRadius = cornerRadius1
            self.stackViewBottom.layer.cornerRadius = cornerRadius2
            self.layer.cornerRadius = cornerRadius1
            //image1 左上 右上 左下 右下
            self.image1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            //stackView 左上 右上 左下 右下
            self.stackViewTop.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            //layer 左上 右上 左下 右下
            self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            
        case 2:
            self.image1.isHidden = false //表示
            self.image2.isHidden = false //表示
            self.image3.isHidden  = true //非表示
            self.image4.isHidden  = true //非表示
            
            self.stackViewTopHeight.constant = height2
            self.stackViewBottomHeight.constant = noneHeight
            
            //角丸
            self.image1.layer.cornerRadius = cornerRadius1
            self.image2.layer.cornerRadius = cornerRadius1
            self.stackViewTop.layer.cornerRadius = cornerRadius1
            self.stackViewBottom.layer.cornerRadius = cornerRadius2
            self.layer.cornerRadius = cornerRadius1
            //image1 左上 左下
            self.image1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
            //image2 右上 右下
            self.image2.layer.maskedCorners =  [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
            //stackView 左上 右上
            self.stackViewTop.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            //layer 左上 右上 左下 右下
            self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                                
        case 3:
            self.image1.isHidden = false //表示
            self.image2.isHidden = false //表示
            self.image3.isHidden = false //表示
            self.image4.isHidden  = true //非表示
            
            self.stackViewTopHeight.constant = height3
            self.stackViewBottomHeight.constant = height3_2
            
            //角丸
            self.image1.layer.cornerRadius = cornerRadius1
            self.image2.layer.cornerRadius = cornerRadius1
            self.image3.layer.cornerRadius = cornerRadius1
            self.stackViewTop.layer.cornerRadius = cornerRadius1
            self.stackViewBottom.layer.cornerRadius = cornerRadius1
            self.layer.cornerRadius = cornerRadius1
            //image1 左上
            self.image1.layer.maskedCorners = [.layerMinXMinYCorner]
            //image2 右上
            self.image2.layer.maskedCorners =  [.layerMaxXMinYCorner]
            //image3 左下 右下
            self.image3.layer.maskedCorners =  [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            //stackView 左上 右上
            self.stackViewTop.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            //stackView 左下 右下
            self.stackViewBottom.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            //layer 左上 右上 左下 右下
            self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            
        case 4:
            self.image1.isHidden = false //表示
            self.image2.isHidden = false //表示
            self.image3.isHidden = false //表示
            self.image4.isHidden  = false //表示
            
            self.stackViewTopHeight.constant = height4
            self.stackViewBottomHeight.constant = height4
            
            //角丸
            self.image1.layer.cornerRadius = cornerRadius1
            self.image2.layer.cornerRadius = cornerRadius1
            self.image3.layer.cornerRadius = cornerRadius1
            self.image4.layer.cornerRadius = cornerRadius1
            self.stackViewTop.layer.cornerRadius = cornerRadius1
            self.stackViewBottom.layer.cornerRadius = cornerRadius1
            self.layer.cornerRadius = cornerRadius1
            //image1 左上
            self.image1.layer.maskedCorners = [.layerMinXMinYCorner]
            //image2 右上
            self.image2.layer.maskedCorners =  [.layerMaxXMinYCorner]
            //image3 左下
            self.image3.layer.maskedCorners =  [.layerMinXMaxYCorner]
            //image4 右下
            self.image4.layer.maskedCorners =  [.layerMaxXMaxYCorner]
            //stackView 左上 右上
            self.stackViewTop.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            //stackView 左下 右下
            self.stackViewBottom.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            //layer 左上 右上 左下 右下
            self.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]

        default:
            print("DEBUG:default")
        }
    }
    
    private func addTapEvent(){
        //image1
        image1.isUserInteractionEnabled = true
        image1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        //image2
        image2.isUserInteractionEnabled = true
        image2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        //image3
        image3.isUserInteractionEnabled = true
        image3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
        //image4
        image4.isUserInteractionEnabled = true
        image4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTransition(_:))))
    }
    
    
    //フルサイズの写真をモーダルで表示
    @objc func imageTransition(_ sender:UITapGestureRecognizer){
        imageLayoutWorkerViewCellDelegate?.imageTransition(sender)
    }

}
