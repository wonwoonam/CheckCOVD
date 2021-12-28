//
//  SearchListView.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/21.
//

import Foundation
import UIKit

class SearchListView : UIView{

    let tableView : UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupViews(){
       
        addSubview(tableView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: tableView)
        addConstraintsWithFormat(format: "V:|-100-[v0]|", views: tableView)
    }
    
}
