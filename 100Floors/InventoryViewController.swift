//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
//    @IBOutlet weak var Container1: ItemContainer!
//    @IBOutlet weak var Container2: ItemContainer!
//    @IBOutlet weak var Container3: ItemContainer!
//    @IBOutlet weak var Container4: ItemContainer!
//    @IBOutlet weak var Container5: ItemContainer!
//    @IBOutlet weak var Container6: ItemContainer!
//    @IBOutlet weak var Container7: ItemContainer!
//    @IBOutlet weak var Container8: ItemContainer!
    
    @IBOutlet weak var inventoryCollection: UICollectionView!
//    @IBOutlet weak var WeaponContainer: ItemContainer!
//    @IBOutlet weak var ShieldContainer: ItemContainer!
//    @IBOutlet weak var SkillContainer: ItemContainer!
//    @IBOutlet weak var EnhancerContainer: ItemContainer!
    
  //  @IBOutlet weak var GroundContainer: ItemContainer!
    
    private var containers:[ItemContainer] = []
    
    private var currentItemView:UIView?
    private var currentContainer:ItemContainer?
    
    var groundBag:ItemBag?
    var inventory:Inventory!
    var dropLoc:CGPoint!
    
    private var previousSelectedContainer:ItemContainer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

       // containers = [Container1, Container2, Container3, Container4, Container5, Container6, Container7, Container8]
   //     containers = []
  //      containers.append(WeaponContainer)
 ///       containers.append(ShieldContainer)
 //       containers.append(SkillContainer)
 //       containers.append(EnhancerContainer)
//        containers.append(GroundContainer)

     
/*        if (GroundContainer.item != nil) {
            containerSelected(GroundContainer)
        }
        else {
            
        }*/

 //       WeaponContainer.itemTypeRestriction = Weapon.self
 //       ShieldContainer.itemTypeRestriction = Shield.self
 //       SkillContainer.itemTypeRestriction = Skill.self
 //       EnhancerContainer.itemTypeRestriction = Enhancer.self
    }
    
    func itemDropped(containerA:ItemContainer, containerB:ItemContainer) {
     //   if (containerA.swappableWith(containerB)) {
        /*    if (containerA == GroundContainer) {
                inventory.setItem(containerB.correspondsToInventoryIndex, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                if (containerB.item != nil) {
                    let newBag = ItemBag(withItem: containerB.item!, loc: dropLoc)
                    groundBag = newBag
                    GameLogic.addObject(newBag)
                }
                else {
                    groundBag = nil
                }
            }
            else if (containerB == GroundContainer) {
                inventory.setItem(containerA.correspondsToInventoryIndex, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                if (containerA.item != nil) {
                    let newBag = ItemBag(withItem: containerA.item!, loc: dropLoc)
                    groundBag = newBag
                    GameLogic.addObject(newBag)
                }
                else {
                    groundBag = nil
                }
            }
            else {*/
                inventory.swapItems(containerA.correspondsToInventoryIndex, atIndexB: containerB.correspondsToInventoryIndex)
            //}
            containerA.swapItemWith(containerB)
            containerSelected(containerB)
     //   }
    }
    func containerSelected(sender:ItemContainer) {
        if (sender.item != nil) {
            previousSelectedContainer?.setSelectedTo(false)
            sender.setSelectedTo(true)
            previousSelectedContainer = sender
            //NameLabel.text = sender.item?.name
            //DescriptionLabel.text = sender.item?.description
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ItemContainer
        cell.correspondsToInventoryIndex = indexPath.item
        cell.setItemTo(inventory.getItem(indexPath.item))
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ItemContainer
        containerSelected(cell)
    }
    
    //gesture recognizer
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let loc = recognizer.locationInView(self.inventoryCollection)
        if (recognizer.state == .Began) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc)
            {
                currentContainer = (inventoryCollection.cellForItemAtIndexPath(path) as! ItemContainer)
                currentItemView = currentContainer!.itemView
                currentItemView?.center = self.view.convertPoint(loc, fromView: inventoryCollection)
                self.view.addSubview(currentItemView!)
            }
            
        }
        else if (recognizer.state == .Changed) {
            currentItemView?.center = self.view.convertPoint(loc, fromView: inventoryCollection)

        }
        else if (recognizer.state == .Ended) {
            currentItemView?.removeFromSuperview()
            currentItemView = nil
            currentContainer?.resetItemView()
            
            if let path = inventoryCollection.indexPathForItemAtPoint(loc) {
                if let containerA = currentContainer {
                    let containerB = inventoryCollection.cellForItemAtIndexPath(path) as! ItemContainer
                    itemDropped(containerA, containerB: containerB)
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