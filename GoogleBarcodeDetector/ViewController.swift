//
//  ViewController.swift
//  GoogleBarcodeDetector
//
//  Created by Shuvo on 8/11/17.
//  Copyright © 2017 SHUVO. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileVision

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}

