//
//  SearchResultCell.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/21.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    
    
    var admCd : String?
    var rnMgtSn : String?
    var udrtYn : String?
    var buldMnnm : String?
    var buldSlno : String?
    var regionName: String?
    var xCoodr : Double?
    var yCoodr : Double?
    
    
    let nameView: UILabel = {
        let tv = UILabel()
        //tv.textAlignment = NSTextAlignment.center
        
        tv.font = UIFont(name: "NotoSansKR-Regular", size: 15)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "요청내역"
        tv.textColor = UIColor.black
        //tv.backgroundColor = UIColor.white
       
        //tv.font = UIFont(name: "System Bold", size: 40)
        return tv
    }()
    
    let addressView: UILabel = {
        let tv = UILabel()
        //tv.textAlignment = NSTextAlignment.center
        
        tv.font = UIFont(name: "NotoSansKR-Regular", size: 15)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "요청내역"
        tv.textColor = UIColor.gray
        //tv.backgroundColor = UIColor.white
       
        //tv.font = UIFont(name: "System Bold", size: 40)
        return tv
    }()
    
    let roadAddrView: UILabel = {
        let tv = UILabel()
        //tv.textAlignment = NSTextAlignment.center
        
        tv.font = UIFont(name: "NotoSansKR-Regular", size: 15)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "요청내역"
        tv.textColor = UIColor.black
        //tv.backgroundColor = UIColor.white
       
        //tv.font = UIFont(name: "System Bold", size: 40)
        return tv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
     }
    
    func setupViews() {
        contentView.backgroundColor = UIColor.white
       
        addSubview(nameView)
        //nameView.width(self.frame.width-40)
        addSubview(addressView)
        //addressView.width(self.frame.width-40)
        addSubview(roadAddrView)
        //roadAddrView.width(self.frame.width-40)
        
        //textView.centerInSuperview()
        addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: nameView)
        addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: addressView)
        addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: roadAddrView)
        
        addConstraintsWithFormat(format: "V:|-10-[v0]-5-[v1]-0-[v2]", views: nameView, roadAddrView, addressView)
        
    }
    
    

     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}
