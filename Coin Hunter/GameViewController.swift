//
//  GameViewController.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-23.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene = GameScene(size: CGSize(width: 1024, height: 768))
    
    @IBOutlet weak var refreshGameButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
 
        refreshGameButton.isHidden = true
        
        let view = self.view as! SKView
        view.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        scene.gameViewControllerBridge = self

        view.presentScene(self.scene)
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        
        refreshGameButton.isHidden = true

        scene.reloadGame()
    }
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
