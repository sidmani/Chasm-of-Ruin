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

    private var currentItemView:UIImageView = UIImageView()
    private var currentContainer:ItemContainer?
    private var currentIndex:Int = -1
    
    var inventory:Inventory!

    var groundBag:ItemBag?
    var dropLoc:CGPoint!
    
    private var leftScrollBound:CGFloat!
    private var rightScrollBound:CGFloat!
    
    private var previousSelectedContainer:ItemContainer? = nil
    private var selectedPath:NSIndexPath?

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
        
        inventoryCollection.setContentOffset(CGPointMake(leftScrollBound,0), animated: false)
        
        currentItemView.contentMode = .ScaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
        selectCenterCell()
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
        containerA.setItemTo(inventory.getItem(containerA.correspondsToInventoryIndex))
        containerB.setItemTo(inventory.getItem(containerB.correspondsToInventoryIndex))

         //   containerSelected(containerB)
        updateInfoDisplay()
     //   }
    }
    func itemDropped(containerA:ItemContainer, indexB:Int) {
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
        print("swapping \(containerA.correspondsToInventoryIndex), \(indexB)")
        inventory.swapItems(containerA.correspondsToInventoryIndex, atIndexB: indexB)
        containerA.setItemTo(inventory.getItem(containerA.correspondsToInventoryIndex))
        //}
        //containerA.swapItemWith(containerB)
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
      
        if (indexPath.item != currentIndex) {
            cell.resetItemView()
        }
        else {
            cell.itemView.hidden = true
        }
        cell.setItemTo(inventory.getItem(indexPath.item))
        cell.setSelectedTo(false)
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        selectCenterCell()
    }

    
    func selectCenterCell() {
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection)), container = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
            selectedPath = path
            previousSelectedContainer?.setSelectedTo(false)
            container.setSelectedTo(true)
            previousSelectedContainer = container
        }
    }

    @IBAction func handleLongPress(recognizer:UILongPressGestureRecognizer) {
        let loc = recognizer.locationInView(self.inventoryCollection)
        let newLoc = recognizer.locationInView(self.view)
        if (recognizer.state == .Began) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc)
            {
                currentContainer = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer)
                if (currentContainer?.item == nil) {
                    currentContainer = nil
                    return
                }
                
                currentIndex = currentContainer!.correspondsToInventoryIndex
                currentItemView.image = currentContainer!.itemView.image
                let bounds = currentContainer!.itemView.bounds
                currentItemView.bounds = CGRectMake(bounds.minX, bounds.minY, bounds.width*1.5, bounds.height*1.5)
                currentItemView.center = newLoc
                
                currentContainer!.itemView.hidden = true
        
                self.view.addSubview(currentItemView)
            }
            
        }
        else if (recognizer.state == .Changed) {
            if (currentItemView.image != nil) {
                currentItemView.center = newLoc
                if (screenSize.width - newLoc.x < 0.2*screenSize.width || newLoc.x < screenSize.width*0.2) {
                    let offsetX = constrain((currentItemView.center.x-inventoryCollection.center.x)/7+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                    inventoryCollection.setContentOffset(CGPoint(x: offsetX, y:0), animated: false)
                }
            }
        }
        else if (recognizer.state == .Ended) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc), containerA = inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer  {
                inventory.swapItems(containerA.correspondsToInventoryIndex, atIndexB: currentIndex)
                currentIndex = -1
                inventoryCollection.reloadItemsAtIndexPaths(inventoryCollection.indexPathsForVisibleItems())
                selectCenterCell()
                updateInfoDisplay()
            }
            else {
                currentIndex = -1
                currentContainer?.resetItemView()
            }
            currentItemView.removeFromSuperview()
            currentItemView.image = nil

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