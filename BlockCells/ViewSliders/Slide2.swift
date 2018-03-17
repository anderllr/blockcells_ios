//
//  Slide2.swift
//  BlockCells
//
//  Created by Anderson Rocha on 29/11/2017.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class Slide2: UIViewController {
    
    var playerViewController = AVPlayerViewController()
    var player = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func viewDidAppear(_ animated: Bool) {
        /*
        let fileURL = NSURL(fileURLWithPath: )

        player = AVPlayer(url: fileURL as URL)
            playerViewController.player = player
            
            self.present(playerViewController, animated: true) {
                self.playerViewController.player?.play()
            }
        */
        playVideo(from: "blockcells_ios.m4v")
    }
    override func viewDidDisappear(_ animated: Bool) {
        player.pause()
    }

    private func playVideo(from file:String) {
        let file = file.components(separatedBy: ".")
        
        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
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
