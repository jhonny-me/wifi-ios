//
//  ViewController.swift
//  SaveWifi
//
//  Created by Johnny Gu on 30/03/2017.
//  Copyright © 2017 Johnny Gu. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class ViewController: UIViewController {
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        textfield.text = AppDelegate.ssid
        infoLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(refreshWifiInfo))
        infoLabel.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshWifiInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshWifiInfo() {
        infoLabel.text = WifiManager.default.getInterfaces()?.description
        if WifiManager.default.isPortableWifi {
            infoLabel.backgroundColor = UIColor.red
        }
    }

    @IBAction func addLocation(_ sender: Any) {
        LocationManager.default.startOneUpdate { location in
            AppDelegate.locations.append(location)
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        AppDelegate.ssid = textField.text
        return true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = AppDelegate.locations[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AppDelegate.locations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

final class WifiManager {
    static let `default` = WifiManager()
    
    func getInterfaces() -> [String: Any]? {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            print("this must be a simulator, no interfaces found")
            return nil
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            print("System error: did not come back as array of Strings")
            return nil
        }
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                print("System error: \(interface) has no information")
                return nil
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: Any] else {
                print("System error: interface information is not a string-keyed dictionary")
                return nil
            }
            return SSIDDict
        }
        return nil
    }
    
    func getSSID() -> String? {
        return getInterfaces()?["SSID"] as? String
    }
    
    var isPortableWifi: Bool {
        get {
            return getSSID() == AppDelegate.ssid
        }
    }
}

extension CLLocationCoordinate2D {
    var description: String {
        return "\(latitude),\(longitude)"
    }
    
    init?(with json: [String: CLLocationDegrees]) {
        guard
            let latitude = json["latitude"],
            let longitude = json["longitude"] else { return nil }
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func archive() -> [String: CLLocationDegrees] {
        return ["latitude": latitude, "longitude": longitude]
    }
}
