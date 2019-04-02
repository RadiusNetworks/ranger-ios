//
//  ViewController.swift
//  Ranger
//
//  Created by Michael Harper on 4/1/19.
//  Copyright © 2019 Radius Networks, Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

  @IBOutlet weak var uuidTextField: UITextField!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  var locationManager: CLLocationManager!
  var beaconRegion: CLBeaconRegion {
    return CLBeaconRegion(proximityUUID: UUID(uuidString: uuidTextField.text!)!, identifier: "Beacon Region")
  }
  var rangingBeacons = false {
    didSet {
      let buttonTitle = "\(rangingBeacons ? "Stop" : "Start") Ranging Beacons"
      startStopButton.setTitle(buttonTitle, for: .normal)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureKeyboard()
    locationManager = CLLocationManager()
    locationManager.delegate = self
  }

  @IBAction func startStopAction(_ sender: Any) {
    if rangingBeacons {
      stopRangingBeacons()
    }
    else {
      startRangingBeacons()
    }
  }
}

extension ViewController : CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      requestLocationAuthorization()
      
    case .authorizedAlways, .authorizedWhenInUse:
      startStopButton.isEnabled = true
      
    default: ()
      startStopButton.isEnabled = false
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    beacons.forEach { (beacon) in
      NSLog("Major: \(beacon.major), Minor: \(beacon.minor)")
    }
  }
  
  func requestLocationAuthorization() {
    locationManager.requestAlwaysAuthorization()
  }
  
  func startRangingBeacons() {
    rangingBeacons = true
    locationManager.startRangingBeacons(in: beaconRegion)
  }
  
  func stopRangingBeacons() {
    rangingBeacons = false
    locationManager.stopRangingBeacons(in: beaconRegion)
  }
}

extension ViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath)
    return cell
  }
}


extension ViewController : UIGestureRecognizerDelegate {
  func configureKeyboard() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapInView))
    tap.cancelsTouchesInView = false
    tap.delegate = self
    self.view.addGestureRecognizer(tap)
  }
  
  @objc func handleTapInView() {
    self.view.endEditing(true)
  }
}
