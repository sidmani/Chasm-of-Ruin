//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
class InventoryViewController: UIViewController {

    @IBOutlet weak var Container1: ItemContainer!
    @IBOutlet weak var Container2: ItemContainer!
    @IBOutlet weak var Container3: ItemContainer!
    @IBOutlet weak var Container4: ItemContainer!
    @IBOutlet weak var Container5: ItemContainer!
    @IBOutlet weak var Container6: ItemContainer!
    @IBOutlet weak var Container7: ItemContainer!
    @IBOutlet weak var Container8: ItemContainer!
    @IBOutlet weak var WeaponContainer: ItemContainer!
    @IBOutlet weak var ShieldContainer: ItemContainer!
    @IBOutlet weak var SkillContainer: ItemContainer!
    @IBOutlet weak var EnhancerContainer: ItemContainer!
    var containers:[ItemContainer] = []

    override func viewDidLoad() {
        containers = [Container1, Container2, Container3, Container4, Container5, Container6, Container7, Container8]
        super.viewDidLoad()
        for (var i = 0; i < 8; i++) {
            containers[i].setItem(thisCharacter.getInventory().getItem(i))
            containers[i].addTarget(self, action: "itemDropped:", forControlEvents: UIControlEvents.ApplicationReserved)
            containers[i].correspondsToInventoryIndex = i
            containers[i].itemTypeRestriction = .None
        }
        WeaponContainer.setItem(thisCharacter.getInventory().getEquip(.Weapon))
        ShieldContainer.setItem(thisCharacter.getInventory().getEquip(.Shield))
        SkillContainer.setItem(thisCharacter.getInventory().getEquip(.Skill))
        EnhancerContainer.setItem(thisCharacter.getInventory().getEquip(.Enhancer))
        
        WeaponContainer.itemTypeRestriction = .Weapon
        ShieldContainer.itemTypeRestriction = .Shield
        SkillContainer.itemTypeRestriction = .Skill
        EnhancerContainer.itemTypeRestriction = .Enhancer
        
    }
    func loadInventory() {
        for (var i = 0; i < 8; i++) {
            containers[i].setItem(thisCharacter.getInventory().getItem(i))
        }
        
    }
    @IBAction func itemDropped(containerA:ItemContainer) {
        print("itemDropped called")
        for containerB in self.containers {
            if (CGRectContainsPoint(containerB.frame, containerA.droppedAt)) {
                if (containerA.correspondsToInventoryIndex < 8 && containerB.correspondsToInventoryIndex < 8) {
                containerA.swapItemWith(containerB)
                thisCharacter.getInventory().swapItems(containerA.correspondsToInventoryIndex, atIndexB: containerB.correspondsToInventoryIndex)
                print("container \(containerA.correspondsToInventoryIndex) swapped with container \(containerB.correspondsToInventoryIndex)")
                }
                
            }
        }
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
            return .Landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}