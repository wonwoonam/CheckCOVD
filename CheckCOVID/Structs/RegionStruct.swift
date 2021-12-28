//
//  RegionStruct.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/18.
//

import Foundation

struct Region {
    var regionName : String?
    var lng : Double?
    var lat : Double?
    var monthly : [Int:Int] = [:]
    var weekly : [Int:NSMutableDictionary] = [:]
    
    init() {
        monthly[1] = 0
        monthly[2] = 0
        monthly[3] = 0
        monthly[4] = 0
        monthly[5] = 0
        monthly[6] = 0
        monthly[7] = 0
        monthly[8] = 0
        monthly[9] = 0
        monthly[10] = 0
        monthly[11] = 0
        monthly[12] = 0
        
        weekly[1] = ["Date": "", "Day" : "", "Number": 0]
        weekly[2] = ["Date": "", "Day" : "", "Number": 0]
        weekly[3] = ["Date": "", "Day" : "", "Number": 0]
        weekly[4] = ["Date": "", "Day" : "", "Number": 0]
        weekly[5] = ["Date": "", "Day" : "", "Number": 0]
        weekly[6] = ["Date": "", "Day" : "", "Number": 0]
        weekly[7] = ["Date": "", "Day" : "", "Number": 0]
        
    }
}
