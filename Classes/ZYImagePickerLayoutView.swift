//
//  ZYImagePickerLayoutView.swift
//  ZYImagePickerAndBrower
//
//  Created by Nvr on 2018/8/20.
//  Copyright © 2018年 ZY. All rights reserved.
//

import UIKit

public typealias CallBack = ()->()
public typealias DeleteCallBack = (_ deleteIndex:Int)->()
public typealias IndexCallBack = (_ selectRow:Int)->()

public struct ItemSize {
    var width:CGFloat = 70
    var height:CGFloat = 70
    var minimumInteritemSpacing:CGFloat = 10
    var minimumLineSpacing:CGFloat = 10
}

public class ZYImagePickerLayoutView: UIView {
    
    let cellIdentifier = "ImagePickerLayoutCollectionViewCellId"
    public var itemSize:ItemSize!
    public var space:CGFloat = 10
    public var datasourceHeight:CGFloat = 0
    
    private lazy var imageCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        let pathName = "/Frameworks/ZYImagePickerLayoutView.framework"
        let fullImagePath = Bundle.main.resourcePath?.appending(pathName)
        collectionView.register(UINib.init(nibName: "ImagePickerLayoutCollectionViewCell", bundle: Bundle.init(path: fullImagePath!)), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UINib.init(nibName: "PlusCollectionViewCell", bundle: Bundle.init(path: fullImagePath!)), forCellWithReuseIdentifier: "PlusCollectionViewCellId")
        return collectionView
    }()
    
    //添加回调
    public var addCallBack:CallBack?
    //点击回调
    public var tapCellCallBack:IndexCallBack?
    //删除回调
    public var deletePhotoCallBack:DeleteCallBack?
    //image个数
    public var dataSource:[UIImage]?
    //是否需要加号
    public var hiddenPlus = false{
        didSet{
            if hiddenPlus == true{
                neeHiddenPlus = false
            }
        }
    }
    //当需要加号的时候是否隐藏加号
    var neeHiddenPlus = false
    //一行个数
    public var numberOfLine = 4 {
        didSet{
            
        }
    }
    //最大几个数
    public var maxNumber = 9
    public var hiddenDelete = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
}

//MARK:- UI
extension ZYImagePickerLayoutView{
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        for constanst in  self.constraints {
            var lineNumber:Float = 0.0
            if neeHiddenPlus == true{
                lineNumber  = ceilf(Float(CGFloat(dataSource?.count ?? 0)/CGFloat(numberOfLine)))
            }else{
                lineNumber  = ceilf(Float(CGFloat((dataSource?.count ?? 0)+1)/CGFloat(numberOfLine)))
            }
            print(lineNumber)
            constanst.constant = CGFloat(lineNumber) * (itemSize.width + 10.0)
            imageCollectionView.frame.size.width = self.frame.width
            imageCollectionView.frame.size.height = constanst.constant
        }
    }
    
    func setupView(){
        //初始化Collectview
        self.addSubview(imageCollectionView)
        itemSize = ItemSize()
    }
    
    func updateCollectionView(){
        
    }
    
    public func reloadView(){
        checkHiddenPlus()
        
        let spaceNumber = CGFloat(numberOfLine) - 1
        let width =  (self.frame.size.width - (space * spaceNumber))/CGFloat(numberOfLine)
        itemSize = ItemSize.init(width:width , height: width, minimumInteritemSpacing: space, minimumLineSpacing: space)
        self.layoutSubviews()
        imageCollectionView.reloadData()
    }
    
    func checkHiddenPlus(){
        
        if dataSource == nil{
            neeHiddenPlus = false
            return
        }
        //显示加号且不是最大的时候
        if maxNumber > (dataSource?.count)! && hiddenPlus == false{
            neeHiddenPlus = false
        }else{
            neeHiddenPlus = true
        }
    }
}

//MARK:- UICollectionViewDelegate
extension ZYImagePickerLayoutView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if neeHiddenPlus == true{
            return dataSource?.count ?? 0
        }else{
            return (dataSource?.count ?? 0) + 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= dataSource?.count ?? 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PlusCollectionViewCellId", for: indexPath) as? PlusCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier, for: indexPath) as? ImagePickerLayoutCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.imageView.image = dataSource![indexPath.row]
            cell.deleteBtn.isHidden = hiddenDelete
            cell.deleteCallBack = { () in
                self.dataSource?.remove(at: indexPath.row)
                self.imageCollectionView.reloadData()
                self.checkHiddenPlus()
                self.deletePhotoCallBack!(indexPath.row)
            }
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= dataSource?.count ?? 0 { //加号按钮
            if let callback = addCallBack{
                callback()
            }
        }else{
            if let callback = tapCellCallBack {
                callback(indexPath.row)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSize.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSize.minimumInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:itemSize.width, height: itemSize.height)
    }
}


