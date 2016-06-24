//
//  MenuViewController
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

var thisCharacter:ThisCharacter!
var levelHandler:LevelHandler!

class MenuViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsButton.tintColor = ColorScheme.strokeColor
        
        thisCharacter = SaveData.currentSave.character
        levelHandler = SaveData.currentSave.levelHandler
    }
  
    @IBAction func exitToMainMenu(segue: UIStoryboardSegue) {

    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
