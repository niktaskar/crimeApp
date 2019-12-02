//
//  SecondViewController.swift
//  SafetyBuddy
//
//  Created by Nikash Taskar on 11/8/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    private var campusPolice = "tel://2056171164"
    private var realPolice = "tel://7034015090"
    private var onCampus = false
    
    @IBOutlet weak var callCampusPolice: UIButton!
    @IBOutlet weak var campusField: UITextField!
    @IBOutlet weak var changeCampusButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeGesture.direction = UISwipeGestureRecognizer.Direction.up
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        callCampusPolice.addGestureRecognizer(longGesture)
        view.addGestureRecognizer(swipeGesture)
        view.addGestureRecognizer(tapGesture)
        
        callCampusPolice.setTitle("Call Local Police", for: UIControl.State.normal)
        campusField.placeholder = "Change Campus Police number"
        
    }

    @IBAction func changedNumber(_ sender: Any) {
        guard let campusPoliceNew = campusField.text else {
            let alert = UIAlertController(title: "No number entered", message: "Please enter a new number for Campus Police", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

            self.present(alert, animated: true)
            return
        }
        if campusPoliceNew == ""{
            let alert = UIAlertController(title: "No number entered", message: "Please enter a new number for Campus Police", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

            self.present(alert, animated: true)
            return
        }
        self.campusPolice = "tel://\(campusPoliceNew)"
        
        campusField.resignFirstResponder()
        campusField.text = ""
    }
    
    @objc func tap(_ sender: Any){
        self.campusField.resignFirstResponder()
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            var url:URL!
            if onCampus {
                url = URL(string: campusPolice)!
            } else {
                url = URL(string: realPolice)!
            }
            UIApplication.shared.open(url)
        }
    }
    
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer){
        print("Swiped Up")
        if sender.direction == .up {
            onCampus = !onCampus
            if onCampus {
                callCampusPolice.setTitle("Call Campus Police", for: UIControl.State.normal)
            } else {
                callCampusPolice.setTitle("Call Local Police", for: UIControl.State.normal)
            }
        }
    }
}

