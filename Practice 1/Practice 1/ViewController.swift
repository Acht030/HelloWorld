//
//  ViewController.swift
//  Practice 1
//
//  Created by Marcus Paze on 8/10/16.
//  Copyright © 2016 Marcus Paze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBAction func leftAction(sender: AnyObject) {
        print("click left")
        view1.frame.origin.x -= 10
    }
    @IBAction func upAction(sender: AnyObject) {
        print("click up")
        view1.frame.origin.y -= 10
    }
    @IBAction func downAction(sender: AnyObject) {
        print("click down")
        view1.frame.origin.y += 10
    }
    @IBAction func rightAction(sender: AnyObject) {
        
        print("click right")
        view1.frame.origin.x += 10
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.redColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

