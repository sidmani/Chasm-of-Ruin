//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
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
    private var leftScrollBound:CGFloat!
    private var rightScrollBound:CGFloat!
    
    private var previousSelectedContainer:ItemContainer? = nil
    
  //  private var previousSelectedIndex = -10
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        let lpgr = UILongPressGestureRecognizer()
        inventoryCollection.addGestureRecognizer(lpgr)
        lpgr.addTarget(self, action: #selector(handleLongPress))
        
        inventoryCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        inventoryCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        leftScrollBound = -inventoryCollection.contentInset.left
        rightScrollBound = inventoryCollection.collectionViewLayout.collectionViewContentSize().width - screenSize.width/2 - layout.itemSize.width/2
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
         //   containerSelected(containerB)
            updateInfoDisplay()
     //   }
    }
    
    func updateInfoDisplay() {
        //NameLabel.text = sender.item?.name
        //DescriptionLabel.text = sender.item?.description
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventory_size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ItemContainer
        cell.correspondsToInventoryIndex = indexPath.item
        cell.setItemTo(inventory.getItem(indexPath.item))
        cell.setSelectedTo(false)
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (currentItemView != nil) { return }
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection))
        {
            let container = (inventoryCollection.cellForItemAtIndexPath(path) as! ItemContainer)
            previousSelectedContainer?.setSelectedTo(false)
            container.setSelectedTo(true)
            previousSelectedContainer = container
        }
    }

    @IBAction func handleLongPress(recognizer:UILongPressGestureRecognizer) {
        let loc = recognizer.locationInView(self.inventoryCollection)
        let newLoc = self.view.convertPoint(loc, fromView: inventoryCollection)
        if (recognizer.state == .Began) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc)
            {
                currentContainer = (inventoryCollection.cellForItemAtIndexPath(path) as! ItemContainer)
                currentItemView = currentContainer!.itemView
                currentItemView?.center = newLoc
                self.view.addSubview(currentItemView!)
            }
            
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
        //else if (recognizer.state == .Changed) {
        else {
            if let itemView = currentItemView {
                if (screenSize.width - newLoc.x < 0.2*screenSize.width || newLoc.x < screenSize.width*0.2) {
                    let offsetX = constrain((itemView.center.x-inventoryCollection.center.x)/10+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                    inventoryCollection.setContentOffset(CGPoint(x: offsetX, y:0), animated: false)
                }
                itemView.center = newLoc
            }
        }
    }
    private func constrain(x:CGFloat, lower:CGFloat, upper:CGFloat) -> CGFloat{
        return max(lower, min(x,upper))
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