//
//  InfoView.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/20.
//

import Foundation
import UIKit
import Charts
import TinyConstraints

class InfoView : UIView, ChartViewDelegate{
    
    
    
    let months = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    
    var days : [String] =  []
    
    
    var yValuesMonths : [ChartDataEntry] = []
    var yValuesDays : [ChartDataEntry] = []
    
    
    lazy var monthChartView: LineChartView = {
        let chartView = LineChartView()
        //chartView.backgroundColor = .black
        //chartView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.enabled = false
        //chartView.leftAxis.setLabelCount(0, force: false)
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.animate(xAxisDuration: 2.5)
        //chartView.setvalue = UIFont(name: "NotoSansKR-Medium", size: 45)!
        return chartView
    }()
    
    
    lazy var weekChartView: LineChartView = {
        let chartView = LineChartView()
        //chartView.backgroundColor = .black
        //chartView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.enabled = false
        //chartView.leftAxis.setLabelCount(0, force: false)
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.animate(xAxisDuration: 2.5)
        //chartView.setvalue = UIFont(name: "NotoSansKR-Medium", size: 45)!
        return chartView
    }()
    
    let mySegmentedControl :UISegmentedControl = {
        let sc = UISegmentedControl (items: ["월별", "일별"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let regionName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "강남구"
        label.font = UIFont(name: "NotoSansKR-Regular", size: 20)
        label.textColor = .black
        //label.backgroundColor = UIColor.red
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
        return view
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        return view
    }()
    
    
    func setupViews(){
        addSubview(regionName)
        addSubview(separatorView)
        addSubview(separatorLine)
        addSubview(mySegmentedControl)
        //addSubview(yestDay)
        //addSubview(thisMnth)
        //addSubview(months)
        //addSubview(numbers)
        addSubview(monthChartView)
        addSubview(weekChartView)
        monthChartView.width(self.frame.width - 20)
        monthChartView.height(210)
        monthChartView.centerX(to: self)
       // weekChartView.frame = CGRect(x: self.frame.width, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        weekChartView.width(self.frame.width - 20)
        weekChartView.height(210)
        //weekChartView.xAxis = 10
        
        setData()
        
        
        self.backgroundColor = UIColor.black
        addConstraintsWithFormat(format: "H:|-20-[v0]", views: regionName)
        addConstraintsWithFormat(format: "H:[v0]-10-|", views: mySegmentedControl)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorLine)
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        //addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: months)
        //addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: numbers)
        //addConstraintsWithFormat(format: "H:[v0]-20-|", views: yestDay)
        //addConstraintsWithFormat(format: "H:[v0]-20-|", views: thisMnth)
        
        addConstraintsWithFormat(format: "V:|-10-[v0]-10-[v1(1)]-0-[v2(5)]", views: regionName, separatorLine, separatorView)
        
        addConstraintsWithFormat(format: "V:[v0]-10-|", views:  monthChartView)
        
        //addConstraintsWithFormat(format: "V:|-10-[v0]-5-[v1]-5-[v2]-10-|", views: yestDay, thisMnth, lineChartView)
        //addConstraintsWithFormat(format: "V:[v0]-10-|", views: lineChartView)
        //addConstraintsWithFormat(format: "V:[v0(20)]-5-[v1(20)]-20-|", views: months, numbers)
        
        mySegmentedControl.centerYAnchor.constraint(equalTo: regionName.centerYAnchor).isActive = true
        
        weekChartView.leadingAnchor.constraint(equalTo: monthChartView.trailingAnchor, constant: 10).isActive = true
        weekChartView.topAnchor.constraint(equalTo: monthChartView.topAnchor).isActive = true
        //separatorView.leadingAnchor.constraint(equalTo: regionName.leadingAnchor).isActive = true
        //separatorView.trailingAnchor.constraint(equalTo: regionName.trailingAnchor).isActive = true
        //addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        //addConstraintsWithFormat(format: "V:[v0(1)]|", views: separatorView)
        //apartment.centerYAnchor.constraint(equalTo: paymentAmout.centerYAnchor).isActive = true
        //firstPhrase.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //secondPhrase.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //thirdPhrase.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //fourthPhrase.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        //secondPhrase.leadingAnchor.constraint(equalTo: firstPhrase.trailingAnchor).isActive = true
        //thirdPhrase.leadingAnchor.constraint(equalTo: secondPhrase.trailingAnchor).isActive = true
        //fourthPhrase.leadingAnchor.constraint(equalTo: thirdPhrase.trailingAnchor).isActive = true
        
        //self.backgroundColor = UIColor.black
//        addConstraintsWithFormat(format: "H:|-[v0(102)]-28-|", views: paymentAmout)
//        addConstraintsWithFormat(format: "H:|[v0(110)]-24-|", views: pickupButton)
//
//        addConstraintsWithFormat(format: "V:|-[v0]-13-[v1(44)]-42-|", views: paymentAmout, pickupButton)
//        addConstraintsWithFormat(format: "H:|-20-[v0]|", views: apartment)
//        addConstraintsWithFormat(format: "H:|-20-[v0]|", views: remainTime)
//        addConstraintsWithFormat(format: "H:|-20-[v0]|", views: trashType)
//        addConstraintsWithFormat(format: "H:|-20-[v0]|", views: dong)
//
//        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)

        
        //self.layer.mask = mask
        //self.layer.addSublayer(mask)
        self.layer.cornerRadius = 15
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 3
        //searchV.layer.shadowOffset = CGSize.zero // Use any CGSize
        //searchV.layer.shadowColor = UIColor.gray.cgColor
        
        //searchV.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        
        self.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 20/255).cgColor
        
        //self.layer.addSublayer(mask)
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!)
    {
        
        if sender.selectedSegmentIndex == 1{
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {

                        self.monthChartView.frame = CGRect(x: -(self.frame.width), y: self.monthChartView.frame.origin.y, width: self.monthChartView.frame.width, height: self.monthChartView.frame.height)
                       }, completion: nil)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {

                        self.weekChartView.frame = CGRect(x: 10, y: self.weekChartView.frame.origin.y, width: self.weekChartView.frame.width, height: self.weekChartView.frame.height)
                       }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: {

                            self.monthChartView.frame = CGRect(x: 10, y: self.monthChartView.frame.origin.y, width: self.monthChartView.frame.width, height: self.monthChartView.frame.height)
                           }, completion: nil)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: {

                            self.weekChartView.frame = CGRect(x: self.frame.width+10, y: self.weekChartView.frame.origin.y, width: self.weekChartView.frame.width, height: self.weekChartView.frame.height)
                           }, completion: nil)
        }
    
    }

    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    
    }
    
    func setData(){
        let set1 = LineChartDataSet(entries: yValuesMonths, label: "확진자")
        //set1.drawCirclesEnabled = false
        set1.valueFont = UIFont.systemFont(ofSize: 10)
        let data = LineChartData(dataSet: set1)
        monthChartView.isUserInteractionEnabled = false
        monthChartView.data = data
        monthChartView.legend.enabled = false
        
        monthChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        monthChartView.xAxis.granularity = 2
        monthChartView.extraLeftOffset = 20
        monthChartView.extraBottomOffset = 20
        monthChartView.extraRightOffset = 20
        
        let set2 = LineChartDataSet(entries: yValuesDays, label: "확진자")
        //set1.drawCirclesEnabled = false
        set2.valueFont = UIFont.systemFont(ofSize: 10)
        let data2 = LineChartData(dataSet: set2)
        weekChartView.isUserInteractionEnabled = false
        weekChartView.data = data2
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data2.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        weekChartView.legend.enabled = false
        weekChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        weekChartView.xAxis.granularity = 2
        weekChartView.extraLeftOffset = 20
        weekChartView.extraBottomOffset = 20
        weekChartView.extraRightOffset = 20
    }
    
   
    
}

