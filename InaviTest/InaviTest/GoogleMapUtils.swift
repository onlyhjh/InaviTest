//
//  GoogleMapUtils.swift
//  InaviTest
//
//  Created by Home on 2020/02/02.
//  Copyright © 2020 Inavi. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapUtils {
    
    /************************************************************************************
     getAddress()
     
     위치에서 주소를 얻어 label 에 넣어준다.
     ************************************************************************************/
    static func getAddress(coordinate: CLLocationCoordinate2D, label: UILabel) {
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { response, error in
            if let addressArr = response?.firstResult() {
                let aroundAddress = getAroundAddress(fullAddress: addressArr.lines![0])
                
                label.text = aroundAddress
            }
        }
    }
    
    /************************************************************************************
     getAroundAddress()
     
     전체 주소에서 '~시~구~동 일대'로 리턴
     ************************************************************************************/
    static func getAroundAddress(fullAddress : String) -> String {
        
        var aroundAddress = ""
        let fullAddressArray = fullAddress.components(separatedBy: " ")
        
        
        if fullAddressArray.count > 3 {
            
            for i in 0 ..< fullAddressArray.count {
                // 대한민국 제거, 번호제거
                if i == 0 || i == fullAddressArray.count - 1  {
                    continue
                } else {
                    aroundAddress += " " + fullAddressArray[i]
                }
            }
            aroundAddress += " 일대"
        }
        
        return aroundAddress
    }
    
    /************************************************************************************
     setMarker()
     
     지도에 마커를 표시함
     ************************************************************************************/
    static func setMarker(coordinate: CLLocationCoordinate2D, range: Double, mapView: GMSMapView){
        mapView.clear()
        
        let marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(named: "point.png")
        //marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        marker.map = mapView
        
        if range > 0 {
            let circ = GMSCircle(position: coordinate, radius: range)
            circ.strokeWidth = 4
            circ.fillColor = getColor(hex: "#5587ce").withAlphaComponent(0.2)
            circ.strokeColor = getColor(hex: "#5587ce").withAlphaComponent(0.5)
            circ.map = mapView
        }
    }
    
    /************************************************************************************
     getColor
     Hex Code RGB 를 RGB Color로 환산하여 UIColor로 리턴
     ************************************************************************************/
    static func getColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let r = ((cString as NSString).substring(to: 2) as NSString).floatValue
        let g = (((cString as NSString).substring(from: 2) as NSString).substring(to: 2) as NSString).floatValue
        let b = (((cString as NSString).substring(from: 4) as NSString).substring(to: 2) as NSString).floatValue
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(1))
    }
    
    /************************************************************************************
     setInitLocationInMap()
     
     지도에서 위치로 이동
     ************************************************************************************/
    static func setInitLocationInMap(location : CLLocation, range: Double, mapView: GMSMapView) {
        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: GoogleMapUtils.getZoom(range: range ))
    }
    
    /************************************************************************************
     getMapViewWithKoreaLocation
     
     최초 지도 한국위치로
     ************************************************************************************/
    static func getMapViewWithKoreaLocation() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 37.56, longitude: 126.97, zoom: 5.7)
        return GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    }
    
    /************************************************************************************
     getMapViewWithLocation
     
     최초 지도 한국위치로
     ************************************************************************************/
    static func getMapViewWithLocation(coordinate : CLLocationCoordinate2D, zoom: Float) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoom)
        return GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    }
    
    /************************************************************************************
     getZoom
     
     지도 영역 반경에 따른 zoom 값 리턴
     ************************************************************************************/
    static func getZoom(range: Double) -> Float  {
        var zoom :Float = 0.0
        
        zoom = Float( (15 + 2 / 3) - (range / 750 ))
        
        let b : Float  = (13.8 - (13*1250/2000))*2000/750
        let a : Float = (13-b)/2000
        
        zoom = a * Float(range) + b
        //print("Zoom: \(zoom)")
        
        return zoom
    }
}
