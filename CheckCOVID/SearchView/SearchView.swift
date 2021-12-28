//
//  SearchView.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/20.
//

import Foundation
import UIKit

class SearchView: UIView{
    
    
    let searchView: TextField = {
        let searchV = TextField()
        searchV.placeholder = "검색"
        searchV.layer.cornerRadius = 6
        searchV.clearButtonMode = .whileEditing
        searchV.backgroundColor = .white
        searchV.layer.shadowOpacity = 1
        searchV.layer.shadowRadius = 3
        //searchV.layer.shadowOffset = CGSize.zero // Use any CGSize
        //searchV.layer.shadowColor = UIColor.gray.cgColor
        
        //searchV.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        searchV.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchV.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 100/255).cgColor
        
        return searchV
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    
    func setupViews(){
        addSubview(searchView)
        searchView.centerInSuperview()
        searchView.width(self.frame.width-40)
        searchView.height(40)
        //self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
