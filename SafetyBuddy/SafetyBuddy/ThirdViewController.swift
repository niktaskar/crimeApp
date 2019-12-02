//
//  ThirdViewController.swift
//  SafetyBuddy
//
//  Created by Nikash Taskar on 11/18/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//
import Firebase
import MapKit
import Foundation
import UIKit
import FirebaseMessaging

class ThirdViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {

  
    @IBOutlet weak var streetNumber: UITextField!
    @IBOutlet weak var streetName: UITextField!
    @IBOutlet weak var crimePicker: UIPickerView!
    
    @IBOutlet weak var crimeDescription: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref = Database.database().reference()
    var pickerData = [String]()
    var coordinates: CLLocationCoordinate2D!
    var streetNameData: String?
    var streetNumberData: String?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        streetName.placeholder = "Pennsylvania Ave"
        streetNumber.placeholder = "2000"
        crimeDescription.placeholder = "The crime was bad!"
        
        if streetNameData != nil {
            streetName.text = streetNameData
        }
        if streetNumberData != nil {
            streetNumber.text = streetNumberData
        }
        
        crimePicker.delegate = self
        crimePicker.dataSource = self
        
        streetName.delegate = self
        streetNumber.delegate = self
        crimeDescription.delegate = self
        
        pickerData = ["Larceny", "Other Offenses", "Vandalism", "Auto Theft", "Burglary", "Other Assault", "Assault", "Robbery", "Drug Abuse", "Fraud", "Weapons", "Disorderly Conduct", "Vagrancy", "Stolen Property", "Arson", "Forgery", "Homicide", "DUI", "Embezzlement", "Neglect", "Prostitution"]
        
        
        ref = Database.database().reference(withPath: "\(Int.random(in: 10000...100000000))")
        scrollView.keyboardDismissMode = .interactive
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm self reporting crime.", message: "You must press 'Yes' if you would like to submit this crime in our database.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            var currentDate = Date()
            let format = DateFormatter()
            
            format.timeZone = .current
            format.dateFormat = "MM/dd/yyyy HH:mm"
            let dateString = format.string(from: currentDate)
            
            let row = self.crimePicker.selectedRow(inComponent: 0)
            
            let newCrime = Crime(Complaint: "\(Int.random(in: 10000...1000000))", DateOccur: "\(dateString)", Description: "\(self.crimeDescription.text!)", ILEADSAddress: self.streetNumber.text!, ILEADSStreet: "\(self.streetName.text!)", Category: "\(self.pickerData[row])", XCoord: "\(self.coordinates.latitude)", YCoord: "\(self.coordinates.longitude)")
            
            let crimeRef = self.ref

            crimeRef.setValue(newCrime.toAnyObject())
            print(newCrime.toAnyObject())
            
            self.resetFields()
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.selectedIndex = 0
            let mapViewController = self.tabBarController?.selectedViewController?.children[0].children[0] as! FirstViewController
            mapViewController.crimeMap.addAnnotation(newCrime)
            mapViewController.crimeMap.setCenter(self.coordinates, animated: true)
            let moveRegion = MKCoordinateRegion(center: self.coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
            mapViewController.crimeMap.setRegion(moveRegion, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {action in
            self.resetFields()
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true)
    }
    
    func resetFields(){
        streetName.text = ""
        streetNumber.text = ""
        crimeDescription.text = ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

}
