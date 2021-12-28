//
//  ViewController.swift
//  CheckCOVID
//
//  Created by Won Woo Nam on 2020/12/14.
//

import UIKit
import Foundation
import Alamofire
import SwiftyXMLParser
import NMapsMap
import Charts
import TinyConstraints

class ViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewTouchDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let guList = ["종로구", "중구", "용산구", "성동구", "광진구", "동대문구", "중랑구", "성북구", "강북구", "도봉구", "노원구", "은평구", "서대문구", "마포구", "양천구", "강서구", "구로구", "금원구", "영등포구", "동작구", "관악구", "서초구", "강남구", "송파구", "강동구"]
    
    let months = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    
    var fill = [1: ["Date":"", "Day":""],
                2: ["Date":"", "Day":""],
                3: ["Date":"", "Day":""],
                4: ["Date":"", "Day":""],
                5: ["Date":"", "Day":""],
                6: ["Date":"", "Day":""],
                7: ["Date":"", "Day":""]]
    
    let seoulCOVIDURL = "http://openapi.seoul.go.kr:8088/"
    let keyStr = "727a6a534869737734304279546758"
    let service = "Corona19Status"
    var startIndex = "1"
    var endIndex = "10"
    var type = "json"
    var responseDict: NSDictionary!
    var rigionalDict: [String : Region] = [:]
    var parameter: [String : String] = [:]
    
    var countETC = 0
    
    var totalCount = 0
    var keepCount = 0
    
    var tempQuery = ""
    
    var indexTuple : [(Int, Int)] = []
    
    var collectionCount = 0
    
    //var yesterDay = ""
    
    let mapView = NMFNaverMapView(frame: .zero)
    
    var currLoc = CLLocationCoordinate2D()
    
    var locationManager = CLLocationManager()
    
    let locationMnger = NMFLocationManager()
    var locationOverlay : NMFLocationOverlay!
    
    var regionalArrayInfo  = [Any]()
    
    var lnglatArray =  [NMGLatLng]()
    
    var poly = NMGPolygon<AnyObject>()
    var polygonOverlay = NMFPolygonOverlay()
    
    var searchListVw = SearchListView()
    
    var searchResultList : [NSDictionary] = []
    
    var searchV : SearchView?
    
    let searchMkr = LocationMkr()
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    let xaxis:XAxis = XAxis()
    
    override func viewWillAppear(_ animated: Bool) {
        print("hrheh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fillWeekDayInfo()
        
        searchListVw.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        searchListVw.tableView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height-100)
        
        searchListVw.isHidden = true
        searchListVw.tableView.register(SearchResultCell.self, forCellReuseIdentifier: "contactCell")
        searchListVw.tableView.dataSource = self
        searchListVw.tableView.delegate = self
      
        let fileName = "regionCoord"
        let fileType = "geojson"
        let jsonPath = Bundle.main.path(forResource: fileName, ofType: fileType)
        DispatchQueue.global(qos: .background).async {
            
            if self.regionalArrayInfo.count == 0{
                if let data = try? String(contentsOfFile: jsonPath!).data(using: .utf8) {

                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    guard let tempJson = json?["features"] as? Array<Any>
                    else{
                        //WarningView
                        return
                    }
                    
                    self.regionalArrayInfo = tempJson
                }
            }
            
        }

//        let date = Date.yesterday
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM.dd."
//        let result = dateFormatter.string(from: date)
//        print(result)
//
//
//        yesterDay = result
        
        parameter = ["KEY": keyStr, "TYPE": "json", "SERVICE": service, "START_INDEX": startIndex, "END_INDEX": endIndex]
        
        locationOverlay = mapView.mapView.locationOverlay
        if (CLLocationManager.locationServicesEnabled())
                {
                    locationManager = CLLocationManager()
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                }
        
        
        
        locationOverlay.hidden = false
        
        locationOverlay.location = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
        mapView.frame = view.frame
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .direction
        mapView.mapView.touchDelegate = self
        
        mapView.showZoomControls = true
        view.addSubview(mapView)
        
        
        mapView.addSubview(searchListVw)
        
        searchV = SearchView(frame: CGRect(x: 0, y:50, width: view.frame.width, height: 50))
        mapView.addSubview(searchV!)
        
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                         target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        searchV!.searchView.inputAccessoryView = toolbar
        searchV!.searchView.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        searchV!.searchView.addTarget(self, action: #selector(ViewController.textFieldDidBegin(_:)), for: .editingDidBegin)
        
        getTotalCount {
            
            guard let parse1 = self.responseDict["Corona19Status"] as? NSDictionary,
                  let totalCnt = parse1["list_total_count"] as? Int
            else{
                //WarningView
                return
            }
            self.totalCount = totalCnt
            self.getIndexTupule()
            self.runIndexTupule()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResultList.count == 0{
            tableView.isHidden = true
        }
        
        
        return searchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! SearchResultCell
        let tempResult = searchResultList[indexPath.row]
        
        
        guard let placeName = tempResult["place_name"] as? String,
              let x = tempResult["x"] as? String,
              let y = tempResult["y"] as? String
        else{
            //WarningView must be included
      
            return cell
        }
        
        let addressName = tempResult["address_name"] as? String
        let roadName = tempResult["road_address_name"] as? String
  
        cell.nameView.text = placeName
        cell.addressView.text = addressName
        cell.roadAddrView.text = roadName
        cell.xCoodr = Double(x)
        cell.yCoodr = Double(y)
        cell.regionName = ""
        for region in guList{
            if (cell.addressView.text)!.contains(region){
                cell.regionName = region
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath) as! SearchResultCell
        //clickedCell.width(view.frame.width)
        guard let (lat, lng) = (clickedCell.yCoodr, clickedCell.xCoodr) as? (Double, Double)
        else{
            //WarningView
      
            return
        }
        view.endEditing(true)
        searchListVw.isHidden = true
        tableView.isHidden = true
        searchV!.searchView.text = clickedCell.nameView.text
        
        //tableView.deleteSections(indexPath.section, with: .automatic)
        //tableView.frame = .zero
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        mapView.mapView.moveCamera(cameraUpdate)
    
        searchMkr.position = NMGLatLng(lat: lat , lng: lng)
        searchMkr.mapView = self.mapView.mapView
        searchMkr.iconImage = NMF_MARKER_IMAGE_LIGHTBLUE
      
        self.lnglatArray = []
        self.polygonOverlay.mapView = nil
        
        guard let regionName = clickedCell.regionName as? String
        else{
            //WarningView
            return
        }
        
        drawRegion(regionName: regionName)
        displayInfo(area: regionName)
        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    @objc func doneButtonTapped() {
        if searchV?.searchView.text == ""{
            searchListVw.isHidden = true
            searchListVw.tableView.isHidden = true
        }
        searchMkr.mapView = nil
        view.endEditing(true)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        getSearchResult(text: textField.text!)
        searchListVw.isHidden = false
        searchListVw.tableView.isHidden = false
        searchListVw.tableView.reloadData()
        
    }
    
    
    
    @objc func textFieldDidBegin(_ textField: UITextField) {
     
        searchListVw.isHidden = false
        
        getSearchResult(text: textField.text!)
        searchListVw.tableView.isHidden = false
        searchListVw.tableView.reloadData()
        //searchListVw.tableView.prepare
        
        lnglatArray = []
        polygonOverlay.mapView = nil
        searchListVw.backgroundColor = .white
        
        for sub in mapView.subviews{
            
            
            if sub.isKind(of: InfoView.self){
                 sub.removeFromSuperview()
            }
                
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currLoc =  manager.location!.coordinate
        locationOverlay.location = NMGLatLng(lat: currLoc.latitude, lng: currLoc.longitude)
    }
    
    func runIndexTupule(){
        //indexTuple = [(1,10)]
        for (s, e) in indexTuple{
           
            getData(start: s, end: e, completionHandler: {
                self.getRigionalDict()
                    
            })
        }
        return
    }
    
    func fillWeekDayInfo(){
        
        let date = (Date.yesterday).dayBefore
        let dateFormatterM = DateFormatter()
        dateFormatterM.dateFormat = "MM.dd."
        let finalDate = dateFormatterM.string(from: date)
        
        let dateFormatterD = DateFormatter()
        dateFormatterD.dateFormat = "EEEE"
        let finalDay = dateFormatterD.string(from: date)
        
        fill[7]!["Date"] = finalDate
        fill[7]!["Day"] = finalDay
        var changingDate = date.dayBefore
        for i in stride(from: 6, through: 1, by: -1) {
            
            fill[i]!["Date"] = dateFormatterM.string(from: changingDate)
            fill[i]!["Day"] = dateFormatterD.string(from: changingDate)
            changingDate = changingDate.dayBefore
        }
        
  
    
        
    }
    
    func getRigionalDict(){
        
        guard let parse1 = responseDict["Corona19Status"] as? NSDictionary, let parse2 = parse1["row"] as? NSArray else{
            //WarningView
            return
        }
     
     
        var tempMonth = 0
        var tempArea = ""
        
        for info in parse2{
            guard let tempDict = info as? NSDictionary,
                  let area = tempDict["CORONA19_AREA"] as? String,
                  let tempDate = tempDict["CORONA19_DATE"] as? String,
                  let tempID = tempDict["CORONA19_ID"] as? String,
                  let checkID = Int(tempID) as? Int
            else{
                //WarningView
                return
            }
            tempArea = (area).replacingOccurrences(of: " ", with: "")
            
            
            
            //타시도 등 서울 구 이름이 아닌 데이터 필터
            if !guList.contains(tempArea){
                continue
            }
        
            if tempDate.count < 6 {
                guard let toInt = Int(tempDate.prefix(1)) as? Int
                else{
                    //WarningView
                    return
                }
                tempMonth = toInt
            }else{
                guard let toInt = Int(tempDate.prefix(2)) as? Int
                else{
                    //WarningView
                    return
                }
                tempMonth = toInt
            }
            
            
            //2020년 0월과 2021년 0월을 나누기 위함
            /*
            if (checkID > 15000) && (tempMonth < 6){
                tempMonth = String(Int(tempMonth)! + 12)
            }
            */
            
            //처음 00구가 사전에 등록될때
            if rigionalDict[tempArea] == nil{
                var region = Region()
                region.regionName = tempArea
             
                region.monthly[tempMonth] = 1
                rigionalDict[tempArea] = region
                tempQuery = tempArea
                
                
                getCoord()
                
                
                
                for tD in fill {
                    
                    if tempDate == (tD.value)["Date"]{
                        guard let week = rigionalDict[tempArea]?.weekly[tD.key] as? NSMutableDictionary
                        else{
                            //WarningView
                            return
                        }
                        week["Date"] = (tD.value)["Date"]
                        week["Day"] = (tD.value)["Day"]
                        week["Number"] = 1
                        break
                    }
                    
                }
                
                
                
                
                
                guard let tempDict = rigionalDict[tempQuery] as? Region,
                      let tempLat = tempDict.lat,
                      let tempLng = tempDict.lng
                else{
                    //WarningView
                    return
                }
                
                let marker = NMFMarker()
                marker.iconImage = NMF_MARKER_IMAGE_BLACK
                marker.captionText = tempQuery
                marker.touchHandler = { (overlay) in
                    self.markerTouchHndler(marker: marker)
                    
                }

                marker.position = NMGLatLng(lat: tempLat , lng: tempLng)
                marker.mapView = mapView.mapView
         
            }else{
                //print((rigionalDict[tempArea])!.monthly)
                
                for tD in fill {
                    
                    if tempDate == (tD.value)["Date"]{
                        guard let week = rigionalDict[tempArea]?.weekly[tD.key] as? NSMutableDictionary
                        else{
                            //WarningView
                            return
                        }
                        
                        if (week["Date"] as! String == "" || week["Day"] as! String == "") {
                            week["Date"] = (tD.value)["Date"]
                            week["Day"] = (tD.value)["Day"]
                        }
                        
                        week["Number"] = week["Number"] as! Int + 1
                    }
                    
                }
                
                ((rigionalDict[tempArea])!.monthly)[tempMonth]! += 1
                
                
            }
        }
    }
    
    
    func markerTouchHndler(marker: NMFMarker)->Bool{
        
        guard let tempDict = rigionalDict[marker.captionText],
              let tempLat = tempDict.lat,
              let tempLng = tempDict.lng
        else{
            //WarningView
            return true
        }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: tempLat , lng: tempLng))
   
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        
        mapView.mapView.moveCamera(cameraUpdate)
        
        searchMkr.mapView = nil
        searchV?.searchView.text = ""
        
        lnglatArray = []
        polygonOverlay.mapView = nil

        drawRegion(regionName: marker.captionText)
        
        displayInfo(area: marker.captionText)
        
       
        view.endEditing(true)

        return true
    }

    
    func drawRegion(regionName:String){
       
        var found = false
        
        for feature in self.regionalArrayInfo{
            guard let firstFeat = feature as? NSDictionary,
                  let property = firstFeat["properties"] as? NSDictionary,
                  let name = property["SIG_KOR_NM"] as? String
            else{
                //WarningView
                return
            }
           
            if (regionName == name) {
                guard let feat = feature as? NSDictionary,
                      let geo = feat["geometry"] as? NSDictionary,
                      let coords = geo["coordinates"] as? NSArray,
                      let parse1 = coords[0] as? NSArray,
                      let parse2 = parse1[0] as? NSArray
                else{
                    //WarningView
                    return
                }

                for cor in parse2 {
                    
                    guard let tempCor = cor as? NSArray,
                        let lng = tempCor[0] as? Double,
                        let lat = tempCor[1] as? Double
                    else{
                        //WarningView
                        return
                    }
                    let coordi = NMGLatLng(lat: lat, lng: lng)
                    self.lnglatArray.append(coordi)
                }
                found = true
                break
            }
        }
        
        if !found{
            return
        }
        poly = NMGPolygon(ring: NMGLineString(points: lnglatArray as! [NMGLatLng]))
        polygonOverlay = NMFPolygonOverlay(poly as! NMGPolygon<AnyObject>)!
        polygonOverlay.mapView = mapView.mapView
        
        polygonOverlay.fillColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 100/255)
        polygonOverlay.outlineColor = UIColor.red
        polygonOverlay.outlineWidth = 3
        
    }
    
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
        view.endEditing(true)
        polygonOverlay.mapView = nil
        for sub in (self.mapView).subviews{
            if sub.isKind(of: InfoView.self){
                let screenSize = UIScreen.main.bounds.size
                  UIView.animate(withDuration: 0.5,
                                 delay: 0, usingSpringWithDamping: 1.0,
                                 initialSpringVelocity: 1.0,
                                 options: .curveEaseInOut, animations: {

                                    sub.frame = CGRect(x: 0, y: mapView.frame.height, width: screenSize.width, height: 280)
                                 }, completion: {_ in sub.removeFromSuperview()})
  
            }

        }
        
        searchMkr.mapView = nil
        searchV?.searchView.text = ""
        
    }
    
    
    func getSearchResult(text:String){
        
        searchResultList = []
        
        let url = "https://dapi.kakao.com/v2/local/search/keyword.json"
        var finalUrl = URLComponents(string: url)
        finalUrl?.queryItems = [URLQueryItem(name: "query", value: text),URLQueryItem(name: "radius", value: "20000"),URLQueryItem(name: "x", value: String(mapView.mapView.longitude)),URLQueryItem(name: "y", value: String(mapView.mapView.latitude)), URLQueryItem(name: "page", value: "1"),URLQueryItem(name: "size", value: "7")]
        
        var request = URLRequest(url: (finalUrl?.url)!)
        
        
        
        request.httpMethod = "GET"

        request.addValue("KakaoAK 020ccad15afdd27532b4a1357e55e76d",forHTTPHeaderField: "Authorization")
        
        let group = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                group.signal()
                //WarningView
                return
            }
            let tempData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
         
            guard let tD = tempData!["documents"] as? [NSDictionary]
            else{
                group.signal()
                //WarningView
                return
            }
            self.searchResultList = tD
            group.signal()
            
        }
        task.resume()
        
        _ = group.wait(wallTimeout: .distantFuture)
        
    }
    
    
    func getCoord(){
 
        let url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
        let param = ["query" : tempQuery]
        var finalUrl = URLComponents(string: url)
        finalUrl?.queryItems = [URLQueryItem(name: "query", value: tempQuery)]
        
        var request = URLRequest(url: (finalUrl?.url)!)
        request.httpMethod = "GET"
        request.addValue("377jyw1em6",forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue("wFbnTa3dNsWZGzuVPPojjFmmgukd3EaITaHfAbTv",forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        let group = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                //WarningView
                group.signal()
                return
            }
            let tempData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?

            guard let addss = (tempData!["addresses"]) as? NSArray
            else{
                //WarningView
                group.signal()
                return
            }
            if addss.count == 0{
                //WarningView
                group.signal()
                return
            }
            
            guard let add = addss[0] as? NSDictionary,
                  let lngtude = add["x"] as? NSString,
                  let latude = add["y"] as? NSString
            else{
                //WarningView
                group.signal()
                return
            }
           
            self.rigionalDict[self.tempQuery]?.lng = lngtude.doubleValue
            self.rigionalDict[self.tempQuery]?.lat = latude.doubleValue
 
        
            group.signal()
            
        }
        task.resume()
        
        _ = group.wait(wallTimeout: .distantFuture)
        
    }
    
 
    func getTotalCount(completionHandler:  @escaping () -> ()){
        
        let url = seoulCOVIDURL+keyStr+"/"+type+"/"+service+"/"+startIndex+"/"+endIndex
        AF.request(url, method: .get, parameters: parameter)
            .responseData { (response) in
                switch response.result {
                case .success(let result):
                    
                    self.responseDict = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:AnyObject] as NSDictionary?
                    
                case .failure(let error):
                    print(error.localizedDescription, error)
                }
                completionHandler()
        }
    }
    
    func getIndexTupule(){
        if totalCount<999{
            indexTuple.append((1,totalCount))
            return
        }
        var tempTotal = totalCount
        var sIndex = 1
        var eIndex = 0
        var count = 1
        while true{
            eIndex = count*999
            if eIndex > totalCount {
                indexTuple.append((sIndex, totalCount))
                break
            }else{
                indexTuple.append((sIndex, eIndex))
            }
            count+=1
            sIndex = eIndex+1
        }
        return
    }
    
    func displayInfo(area: String){
        
        
        
        for sub in mapView.subviews{
            if sub.isKind(of: InfoView.self){
                 sub.removeFromSuperview()
            }
        }
    
        let screenSize = UIScreen.main.bounds.size
        let newView = InfoView(frame: CGRect(x: 0, y: mapView.mapView.frame.height, width: mapView.frame.width, height: 280))
        newView.backgroundColor = .white
        newView.regionName.text = area
     
        var tempYValMonth :[ChartDataEntry] =  []
        var tempYValDay :[ChartDataEntry] =  []
      
        guard let regionStruct = rigionalDict[area] as? Region,
              let monthly = regionStruct.monthly as? [Int:Int],
              let daily = regionStruct.weekly as? [Int:NSMutableDictionary]
        else{
            //WarningView
            return
        }
        
        //axisFormatDelegate = IAxisValueFormatter()
        for month in 1...monthly.count{
            tempYValMonth.append(ChartDataEntry(x: Double(month-1), y: Double(monthly[month]!)))
            
         
        }

        newView.yValuesMonths = tempYValMonth
        
        
        
        for i in 1...7{
            let number = daily[i]!["Number"] as! Int
            let date = daily[i]!["Date"] as! String
            newView.days.append(date)
            tempYValDay.append(ChartDataEntry(x: Double(i-1), y: Double(number)))
            
        }
        newView.yValuesDays = tempYValDay
        
        newView.setData()
        //newView.monthChartView.xAxis.valueFormatter = xaxis.valueFormatter
        
        mapView.addSubview(newView)
        UIView.animate(withDuration: 0.5,
                         delay: 0, usingSpringWithDamping: 1.0,
                         initialSpringVelocity: 1.0,
                         options: .curveEaseInOut, animations: {
                            newView.frame = CGRect(x: 0, y: self.mapView.mapView.frame.height - 280, width: screenSize.width, height: 280)
          }, completion: nil)
        
        
        
        
    }
    
    
    public func stringForValue(value: Double, axis: AxisBase?) -> String
    {
        return months[Int(value)]
    }
    
    func getData(start:Int, end:Int, completionHandler:  @escaping () -> ()) {
        
        let url = seoulCOVIDURL+keyStr+"/"+type+"/"+service+"/"+String(start)+"/"+String(end)
      
        AF.request(url, method: .get, parameters: parameter)
            .responseData { (response) in
                switch response.result {
                case .success(let result):
                    
                   
                    self.responseDict = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:AnyObject] as NSDictionary?
             
                case .failure(let error):
                    print(error.localizedDescription, error)
                }
                completionHandler()
        }
        
    }
}



enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}
