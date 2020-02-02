//
//  MainViewController.swift
//  InaviTest
//
//  Created by Home on 2020/02/01.
//  Copyright © 2020 Inavi. All rights reserved.
//

import UIKit
import GoogleMaps

/************************************************************************************
MainViewController

아이나비 구글지도 영역 설정 VC
************************************************************************************/
class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    static let ID = "InaviMapViewController"
    
    // Body
    var mMapView : GMSMapView!
    var mLocationManager: CLLocationManager!

    @IBOutlet weak var mRangeSlider : UISlider!
    @IBOutlet weak var mMapFrameView: UIView!
    @IBOutlet weak var mRangeLabel: UILabel!
    @IBOutlet weak var mAddressLabel: UILabel!
    
    var mSelectedLocation = CLLocationCoordinate2D()
    var mRange: Double = 0
    
    /************************************************************************************
     viewDidLoad
     ************************************************************************************/
    override func viewDidLoad()   {
        super.viewDidLoad()
        print("\n> VIEW : " + MainViewController.ID)

        mMapView = GoogleMapUtils.getMapViewWithKoreaLocation()
        
        mLocationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            mLocationManager.delegate = self
            mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            mLocationManager.requestAlwaysAuthorization()
            mLocationManager.startUpdatingLocation()
        }
        
        // 최소 최대 범위 설정
        if mRange < 500 {
            mRange = 500
        }
        else if mRange > 2000 {
            mRange = 2000
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedRangeSlider(gestureRecognizer:)))
        mRangeSlider.addGestureRecognizer(tapGestureRecognizer)

        mMapView.delegate = self
        self.mMapFrameView.addSubview(mMapView)
        mMapView.matchParentView()
        
        setBottomFrame()
    }

    /************************************************************************************
     setBottomFrame
     ************************************************************************************/
    func setBottomFrame() {
        
        let rangeValue = Float( (mRange - 500) / 1500)
        mRangeSlider.setValue(rangeValue, animated: false)
        
        setRangeFrame()
        setAddressFrame()
    }
    
    func setRangeFrame() {
        
        if mRange < 1000 {
            mRangeLabel.text = "반경 \(Int(mRange))m"
        }
        else {
            mRangeLabel.text = String(format: "반경 %.2fkm", mRange/1000)
        }
    }
    
    func setAddressFrame() {
        
        if mSelectedLocation.latitude == 0 {
            mAddressLabel.isHidden = true
        }
        else {
            mAddressLabel.isHidden = false
            GoogleMapUtils.getAddress(coordinate: CLLocationCoordinate2D(latitude: mSelectedLocation.latitude, longitude: mSelectedLocation.longitude), label: mAddressLabel)
        }
    }
    
    /************************************************************************************
     locationManager()
     
     CLLocationManagerDelegate 를 통해 나의 위치값을 지도에 설정
     ************************************************************************************/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        GoogleMapUtils.setInitLocationInMap(location: locations.last!, range: mRange, mapView: mMapView)
        mLocationManager.stopUpdatingLocation()
    }
    
    /************************************************************************************
     mapView()
     
     지도 위치 선택 이벤트 핸들러
     Marker를 표시한다
     ************************************************************************************/
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        mMapView.clear()
        
        mSelectedLocation = coordinate

        GoogleMapUtils.setMarker(coordinate: coordinate, range: mRange, mapView: mMapView)
        
        let coordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        GoogleMapUtils.setInitLocationInMap(location: coordinate, range: mRange, mapView: mMapView)
        
        setAddressFrame()
    }
    

    
    /************************************************************************************
     Buttons
     ************************************************************************************/
    @IBAction func onClickRefreshButton(_ sender: AnyObject) {
        if mLocationManager != nil {
            mLocationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func onClickOkButton(_ sender: Any) {
        if mSelectedLocation.latitude == 0 {
            let alert = UIAlertController(title: "영역 설정 안내", message: "지도에서 위치를 설정하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "영역 설정 완료", message: "지도에서 다음 영역이 설정되었습니다.\n" + mAddressLabel.text! + "\n" + mRangeLabel.text!, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func valueChangedReangeSlider(_ sender: AnyObject) {
        
        mRange = Double((mRangeSlider.value * 1500) + 500)
        setRangeFrame()
        
        if mSelectedLocation.latitude != 0 {
            let pin  = mSelectedLocation
            mapView(mMapView, didTapAt: pin)
        }
    }
    
    @objc func tappedRangeSlider(gestureRecognizer: UIGestureRecognizer) {
        
        if let slider = gestureRecognizer.view as? UISlider {
            
            let point = gestureRecognizer.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: true)
            valueChangedReangeSlider(self)
        }
    }
    
    
}
