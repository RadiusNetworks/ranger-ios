//
//  BeaconCell.swift
//  Ranger
//
//  Created by Michael Harper on 4/2/19.
//  Copyright © 2019 Radius Networks, Inc. All rights reserved.
//

import UIKit

class BeaconCell: UITableViewCell {
  static let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    return formatter
  }()

  @IBOutlet weak var beaconLabel: UILabel!
  @IBOutlet weak var firstSeenLabel: UILabel!
  @IBOutlet weak var lastSeenLabel: UILabel!

  var beaconEntry: BeaconEntry? {
    didSet {
      if let beaconEntry = beaconEntry {
        beaconLabel.text = "Major: \(beaconEntry.beacon.major), Minor:\(beaconEntry.beacon.minor)"
        firstSeenLabel.text = "First Seen: \(BeaconCell.dateTimeFormatter.string(for: beaconEntry.firstSeen)!)"
        lastSeenLabel.text = "Last Seen: \(BeaconCell.dateTimeFormatter.string(for: beaconEntry.lastSeen)!)"
      }
      else {
        beaconLabel.text = ""
        firstSeenLabel.text = ""
        lastSeenLabel.text = ""
      }
    }
  }
}
