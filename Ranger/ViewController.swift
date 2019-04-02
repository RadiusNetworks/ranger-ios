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
  
  let uuidDefaultsKey = "uuid"
  
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
  
  struct Beacon : Equatable {
    let major: NSNumber
    let minor: NSNumber
    
    static func == (lhs: Beacon, rhs: Beacon) -> Bool {
      return
        lhs.major == rhs.major &&
          lhs.minor == rhs.minor
    }
    
    init(major: NSNumber, minor: NSNumber) {
      self.major = major
      self.minor = minor
    }
    
    init(beacon: CLBeacon) {
      major = beacon.major
      minor = beacon.minor
    }
  }
  
  var rangedBeacons: [(beacon: Beacon, lastSeen: Date)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureKeyboard()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    if let storedUUID = UserDefaults.standard.string(forKey: uuidDefaultsKey) {
      uuidTextField.text = storedUUID
    }
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
      if let entryIndex = rangedBeacons.firstIndex(where: { (entry) -> Bool in
        return entry.beacon == Beacon(beacon: beacon)
      }) {
        rangedBeacons[entryIndex].lastSeen = Date()
        tableView.reloadRows(at: [IndexPath(row: entryIndex, section: 0)], with: .fade)
      }
      else {
        tableView.beginUpdates()
        let rangedBeaconCount = rangedBeacons.count
        rangedBeacons.append((beacon: Beacon(major: beacon.major, minor: beacon.minor), lastSeen: Date()))
        tableView.insertRows(at: [IndexPath(row: rangedBeaconCount, section: 0)], with: .bottom)
        tableView.endUpdates()
      }
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
    return rangedBeacons.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath)
    let entry = rangedBeacons[indexPath.row]
    cell.textLabel?.text = "Major: \(entry.beacon.major), Minor:\(entry.beacon.minor)"
    cell.detailTextLabel?.text = entry.lastSeen.debugDescription
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

extension ViewController : UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    UserDefaults.standard.set(uuidTextField.text, forKey: uuidDefaultsKey)
  }
}
