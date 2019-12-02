//
//  CrimeMarkerView.swift
//  SafetyBuddy
//
//  Created by Shane Blair on 11/17/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//

import Foundation
import MapKit

class CrimeMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let crime = newValue as? Crime else {return }
            markerTintColor = crime.markerColor
            glyphText = String(crime.Category.first!)
        }
    }
}
