//
//  OnRunVC.swift
//  Runo
//
//  Created by Mahmoud Elshakoushy on 9/20/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class OnRunVC: LocationVC {

    @IBOutlet weak var sliderBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var distanceLbl: UILabel!
    
    fileprivate var startLocation: CLLocation!
    fileprivate var lastLocation: CLLocation!
    fileprivate var timer = Timer()
    fileprivate var coordinateLocations = List<Location>()
    
    fileprivate var runDistance: Double = 0.0
    fileprivate var counter = 0
    fileprivate var pace = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwipped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self as? UIGestureRecognizerDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10
        startRun()
    }
    
    func startRun() {
        manager?.startUpdatingLocation()
        startTimer()
        pauseBtn.setImage(UIImage(named: "pauseButton"), for: .normal)
    }
    
    func endRun() {
        manager?.stopUpdatingLocation()
        Run.addRunToRealm(pace: pace, distance: runDistance, duration: counter, locations: coordinateLocations)
    }
    
    func pauseRun() {
        startLocation = nil
        lastLocation = nil
        timer.invalidate()
        manager?.stopUpdatingLocation()
        pauseBtn.setImage(UIImage(named: "resumeButton"), for: .normal)
    }
    
    func startTimer() {
        durationLbl.text = counter.formateTimeDurationToString()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        counter += 1
        durationLbl.text = counter.formateTimeDurationToString()
    }
    
    func calculatePace(second: Int , miles: Double) -> String {
        pace = Int(Double(second) / miles)
        return pace.formateTimeDurationToString()
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid {
           pauseRun()
        } else {
            startRun()
        }
    }
    
    
    @objc func endRunSwipped(sender: UIPanGestureRecognizer) {
        let minAdjust: CGFloat = 80
        let maxAdjust: CGFloat = 130
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizer.State.began || sender.state == UIGestureRecognizer.State.changed {
                let translation = sender.translation(in: self.view)
                if sliderView.center.x >= (sliderBGImageView.center.x - minAdjust) && sliderView.center.x <= (sliderBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if sliderView.center.x >= (sliderBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = sliderBGImageView.center.x + maxAdjust
                    endRun()
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = sliderBGImageView.center.x - minAdjust
                }
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == UIGestureRecognizer.State.ended {
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.sliderBGImageView.center.x - minAdjust
                }
            }
        }
    }
}

extension OnRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            runDistance += lastLocation.distance(from: location)
            let newLocation = Location(longitude: Double(lastLocation.coordinate.longitude), latitude: lastLocation.coordinate.latitude)
            coordinateLocations.insert(newLocation, at: 0)
            distanceLbl.text = "\(runDistance.metersToMiles(places: 2))"
            if counter > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(second: counter, miles: runDistance.metersToMiles(places: 2))
            }
        }
        lastLocation = locations.last
    }
}
