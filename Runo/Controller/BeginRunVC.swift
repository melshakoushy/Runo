//
//  FirstViewController.swift
//  Runo
//
//  Created by Mahmoud Elshakoushy on 7/19/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class BeginRunVC: LocationVC {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastPaceLbl: UILabel!
    @IBOutlet weak var lastDistanceLbl: UILabel!
    @IBOutlet weak var lastRunStack: UIStackView!
    @IBOutlet weak var lastRunViewCloseBtn: UIButton!
    @IBOutlet weak var lastRunView: UIView!
    @IBOutlet weak var lastDurationLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
            lastRunView.isHidden = false
            lastRunStack.isHidden = false
            lastRunViewCloseBtn.isHidden = false
        } else {
            lastRunView.isHidden = true
            lastRunStack.isHidden = true
            lastRunViewCloseBtn.isHidden = true
            centerMapOnUserLocation()
        }
        
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
        lastPaceLbl.text = lastRun.pace.formateTimeDurationToString()
        lastDistanceLbl.text = "\(lastRun.distance.metersToMiles(places: 2)) mi"
        lastDurationLbl.text = lastRun.duration.formateTimeDurationToString()
        
        var coordinate = [CLLocationCoordinate2D]()
        for location in lastRun.locations {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        mapView.userTrackingMode = .none
        mapView.setRegion(centerMapOnPrevRoute(locations: lastRun.locations), animated: true)
        return MKPolyline(coordinates: coordinate, count: lastRun.locations.count)
    }
    
    func centerMapOnUserLocation() {
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPrevRoute(locations: List<Location>) -> MKCoordinateRegion {
        guard let initialLoc = locations.first else { return MKCoordinateRegion() }
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2), span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.4, longitudeDelta: (maxLng - minLng)*1.4))
    }
    

    @IBAction func centerLocationBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunView.isHidden = true
        lastRunStack.isHidden = true
        lastRunViewCloseBtn.isHidden = true
        centerMapOnUserLocation()
    }
    
    
}

extension BeginRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        renderer.lineWidth = 4
        return renderer
    }
}
