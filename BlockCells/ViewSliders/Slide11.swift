//
//  Slide11.swift
//  BlockCells
//
//  Created by Anderson Rocha on 29/11/2017.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit

class Slide11: UIViewController {

    @IBAction func iniciarApp(_ sender: Any) {
        let skipChoice = UserDefaults.standard
        skipChoice.setValue(true, forKey:"skipApresentacao")
        skipChoice.synchronize()
        
        let autenticaView: NavAutenticaViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavAutenticaViewController") as! NavAutenticaViewController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window!.rootViewController = autenticaView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
