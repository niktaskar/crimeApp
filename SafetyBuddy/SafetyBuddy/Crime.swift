//
//  Crime.swift
//  SafetyBuddy
//
//  Created by Shane Blair on 11/17/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class Crime: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var Complaint: String
    var DateOccur: String
    var Description: String
    var ILEADSAddress: String
    var ILEADSStreet: String
    var Category: String
    var XCoord: String
    var YCoord: String
    
    var title: String? {
        return "\(ILEADSAddress) \(ILEADSStreet)"
    }
    
    var subtitle: String? {
        return Description
    }
    
    var markerColor: UIColor {
        switch Category {
        case "Burglary":
            return .red
        case "Larceny":
            return .orange
        case "Assault":
            return .yellow
        case "Vandalism":
            return .green
        case "Auto Theft":
            return .cyan
        default:
            return .blue
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "Complaint": Complaint,
            "DateOccur": DateOccur,
            "Description": Description,
            "ILEADSAddress": ILEADSAddress,
            "ILEADSStreet": ILEADSStreet,
            "Type": Category,
            "XCoord": XCoord,
            "YCoord": YCoord
        ]
    }
    
    init(Complaint: String, DateOccur: String, Description: String, ILEADSAddress: String, ILEADSStreet: String, Category: String, XCoord: String, YCoord: String) {
        self.Complaint = Complaint
        self.DateOccur = DateOccur
        self.Description = Description
        self.ILEADSAddress = ILEADSAddress
        self.ILEADSStreet = ILEADSStreet
        self.Category = Category
        self.XCoord = XCoord
        self.YCoord = YCoord
        self.coordinate = CLLocationCoordinate2DMake(Double(XCoord)!, Double(YCoord)!)
        
        super.init()
    }
    
    convenience init?(dictionary: [String: Any]) {
        guard let Complaint = dictionary["Complaint"] as? String,
            let DateOccur = dictionary["DateOccur"] as? String,
            let Description = dictionary["Description"] as? String,
            let ILEADSAddress = dictionary["ILEADSAddress"] as? String,
            let ILEADSStreet = dictionary["ILEADSStreet"] as? String,
            let Category = dictionary["Type"] as? String,
            let XCoord = dictionary["XCoord"] as? String,
            let YCoord = dictionary["YCoord"] as? String
            else { return nil }
        
        self.init(Complaint: Complaint, DateOccur: DateOccur, Description: Description, ILEADSAddress: ILEADSAddress, ILEADSStreet: ILEADSStreet, Category: Category, XCoord: XCoord, YCoord: YCoord)
    }
}
