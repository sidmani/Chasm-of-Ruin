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
    
    @IBOutlet weak var GroundContainer: ItemContainer!
    
    var containers:[ItemContainer] = []

    override func viewDidLoad() {
        containers = [Container1, Container2, Container3, Container4, Container5, Container6, Container7, Container8]
        containers.append(WeaponContainer)
        containers.append(ShieldContainer)
        containers.append(SkillContainer)
        containers.append(EnhancerContainer)
        
       
        super.viewDidLoad()
        var selected = false
       // for (var i = 0; i < containers.count; i += 1) {
        for i in 0..<containers.count {
            containers[i].setItem(thisCharacter.inventory.getItem(i))
            if (!selected && containers[i].item != nil) {
                containerSelected(containers[i])
                selected = true
            }
            containers[i].addTarget(self, action: #selector(InventoryViewController.itemDropped(_:)), forControlEvents: .ApplicationReserved)
            containers[i].addTarget(self, action: #selector(InventoryViewController.containerSelected(_:)), forControlEvents: .TouchUpInside)
            containers[i].correspondsToInventoryIndex = i
        }
        //if (!(GameLogic.currentInteractiveObject is ItemBag)) {
            //GroundContainer.hidden = true
        //}
        //else {
            GroundContainer.setItem((GameLogic.currentInteractiveObject as? ItemBag)?.item)
            GroundContainer.addTarget(self, action: #selector(InventoryViewController.itemDropped(_:)), forControlEvents: .ApplicationReserved)
            GroundContainer.addTarget(self, action: #selector(InventoryViewController.containerSelected(_:)), forControlEvents: .TouchUpInside)
            containers.append(GroundContainer)
        //}
        WeaponContainer.itemTypeRestriction = Weapon.self
        ShieldContainer.itemTypeRestriction = Shield.self
        SkillContainer.itemTypeRestriction = Skill.self
        EnhancerContainer.itemTypeRestriction = Enhancer.self
    }
    
    @IBAction func itemDropped(containerA:ItemContainer) {
        for containerB in self.containers {
            if (CGRectContainsPoint(containerB.frame, containerA.droppedAt)) {
                if (containerA.swappableWith(containerB)) {
                    if (containerA == GroundContainer) {
                        let temp = (GameLogic.currentInteractiveObject as! ItemBag).item
                 
                        (GameLogic.currentInteractiveObject as! ItemBag).setItem(thisCharacter.inventory.getItem(containerB.correspondsToInventoryIndex))
                        containerA.setItem(thisCharacter.inventory.getItem(containerB.correspondsToInventoryIndex))

                        thisCharacter.inventory.setItem(containerB.correspondsToInventoryIndex, toItem: temp)
                        containerB.setItem(temp)
                        
                        
                    }
                    else if (containerB == GroundContainer) {
                        if (!(GameLogic.currentInteractiveObject is ItemBag)) {
                            let newBag = ItemBag(withItem: containerA.item!, loc: thisCharacter.position)
                            GroundContainer.setItem(containerA.item)
                            
                            containerSelected(GroundContainer)
                            
                            containerA.setItem(nil)
                            thisCharacter.inventory.setItem(containerA.correspondsToInventoryIndex, toItem: nil)
                            
                            GameLogic.isWithinDistanceOf(newBag)
                            GameLogic.addObject(newBag)
                        }
                        else {
                        let temp = (GameLogic.currentInteractiveObject as! ItemBag).item
                        
                        (GameLogic.currentInteractiveObject as! ItemBag).setItem(thisCharacter.inventory.getItem(containerA.correspondsToInventoryIndex))
                        containerB.setItem(thisCharacter.inventory.getItem(containerA.correspondsToInventoryIndex))
                        
                        thisCharacter.inventory.setItem(containerA.correspondsToInventoryIndex, toItem: temp)
                        containerA.setItem(temp)
                        }
                        
                    }
                    else {
                        thisCharacter.inventory.swapItems(containerA.correspondsToInventoryIndex, atIndexB: containerB.correspondsToInventoryIndex)
                        containerA.swapItemWith(containerB)
                    }
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