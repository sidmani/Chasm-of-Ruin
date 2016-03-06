//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
class InventoryViewController: UIViewController {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
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
            containers[i].addTarget(self, action: "itemDropped:", forControlEvents: .ApplicationReserved)
            containers[i].addTarget(self, action: "containerSelected:", forControlEvents: .TouchUpInside)
            containers[i].correspondsToInventoryIndex = i
        }
        WeaponContainer.addTarget(self, action: "itemDropped:", forControlEvents: .ApplicationReserved)
        ShieldContainer.addTarget(self, action: "itemDropped:", forControlEvents: .ApplicationReserved)
        SkillContainer.addTarget(self, action: "itemDropped:", forControlEvents: .ApplicationReserved)
        EnhancerContainer.addTarget(self, action: "itemDropped:", forControlEvents: .ApplicationReserved)
       
        WeaponContainer.addTarget(self, action: "containerSelected:", forControlEvents: .TouchUpInside)
        ShieldContainer.addTarget(self, action: "containerSelected:", forControlEvents: .TouchUpInside)
        SkillContainer.addTarget(self, action: "containerSelected:", forControlEvents: .TouchUpInside)
        EnhancerContainer.addTarget(self, action: "containerSelected:", forControlEvents: .TouchUpInside)

        WeaponContainer.setItem(thisCharacter.getInventory().getItem(Inventory.EquippedItems.weaponIndex))
        ShieldContainer.setItem(thisCharacter.getInventory().getItem(Inventory.EquippedItems.shieldIndex))
        SkillContainer.setItem(thisCharacter.getInventory().getItem(Inventory.EquippedItems.skillIndex))
        EnhancerContainer.setItem(thisCharacter.getInventory().getItem(Inventory.EquippedItems.enhancerIndex))
        
        WeaponContainer.itemTypeRestriction = .Weapon
        ShieldContainer.itemTypeRestriction = .Shield
        SkillContainer.itemTypeRestriction = .Skill
        EnhancerContainer.itemTypeRestriction = .Enhancer
        
        WeaponContainer.correspondsToInventoryIndex = Inventory.EquippedItems.weaponIndex
        ShieldContainer.correspondsToInventoryIndex = Inventory.EquippedItems.shieldIndex
        SkillContainer.correspondsToInventoryIndex = Inventory.EquippedItems.skillIndex
        EnhancerContainer.correspondsToInventoryIndex = Inventory.EquippedItems.enhancerIndex
      
        containers.append(WeaponContainer)
        containers.append(ShieldContainer)
        containers.append(SkillContainer)
        containers.append(EnhancerContainer)
        
        containers[0].setSelectedTo(true)
    }
    
    @IBAction func itemDropped(containerA:ItemContainer) {
        for containerB in self.containers {
            if (CGRectContainsPoint(containerB.frame, containerA.droppedAt)) {
                if (containerA.swappableWith(containerB)) {
                        thisCharacter.getInventory().swapItems(containerA.correspondsToInventoryIndex, atIndexB: containerB.correspondsToInventoryIndex)
                        containerA.swapItemWith(containerB)
                        containerSelected(containerB)
                }
                return
            }
        }
    }
    @IBAction func containerSelected(sender:ItemContainer) {
        for container in containers {
            container.setSelectedTo(false)
        }
        sender.setSelectedTo(true)
    //    NameLabel.text = sender.item!.name
    //    DescriptionLabel.text = sender.item!.description
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