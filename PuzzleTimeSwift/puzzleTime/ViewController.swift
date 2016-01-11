//
//  ViewController.swift
//  puzzleTime
//
//  Created by Wei Shan on 1/8/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {

    var allImgViews = [UIImageView]()
    var allCenters = [CGPoint]()
    var originCenters = [CGPoint]()
    var emptySpot = CGPoint()
    let numberOfimages = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        var xCenter:CGFloat = 96
        var yCenter:CGFloat = 196
        
        for v in 0...Int(sqrt(Double(numberOfimages)))-1 {
            for h in 0...Int(sqrt(Double(numberOfimages)))-1 {
                let myImgView = UIImageView.init(frame: CGRectMake(96, 196, 100, 100))
                let curCen = CGPointMake(xCenter, yCenter)
                
                allCenters.append(curCen)
                
                myImgView.center = curCen
                myImgView.image = UIImage.init(named: "number" + String(h + v * Int(sqrt(Double(numberOfimages)))) + ".jpg")
                myImgView.userInteractionEnabled = true
                allImgViews.append(myImgView)
                self.view.addSubview(myImgView)
                
                xCenter += 108
            }
            xCenter = 96
            yCenter += 108
        }
        
        allImgViews[numberOfimages - 1].removeFromSuperview()
        allImgViews.removeLast()
        originCenters = allCenters
        
        self.randomizeBlocks()
    }
    
    func randomizeBlocks() {
        var randLocInt = 0
        var randLocCGP = CGPoint()
        var centerCopy = allCenters
        
        for image in allImgViews {
            randLocInt = Int(arc4random()) % centerCopy.count
            randLocCGP = centerCopy[randLocInt]
            
            image.center = randLocCGP
            centerCopy.removeAtIndex(randLocInt)
        }
        emptySpot = centerCopy.first!
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let myTouch = touches.first
        let tapCen = myTouch?.view?.center
        var leftCen, rightCen, topCen, bottomCen : CGPoint
        
        if myTouch?.view != self.view {
            leftCen = CGPointMake(tapCen!.x - 108, tapCen!.y)
            rightCen = CGPointMake(tapCen!.x + 108, tapCen!.y)
            topCen = CGPointMake(tapCen!.x, tapCen!.y + 108)
            bottomCen = CGPointMake(tapCen!.x, tapCen!.y - 108)
            
            if leftCen == emptySpot {
                swapImage(myTouch!, tapCen: tapCen!)
            }
            if rightCen == emptySpot {
                swapImage(myTouch!, tapCen: tapCen!)
            }
            if topCen == emptySpot {
                swapImage(myTouch!, tapCen: tapCen!)
            }
            if bottomCen == emptySpot {
                swapImage(myTouch!, tapCen: tapCen!)
            }
            
        }
        
    }
    
    func swapImage(myTouch: UITouch, tapCen: CGPoint) {
        //UIView.beginAnimations(nil, context: nil)
        //UIView.setAnimationDuration(0.15)
        UIView.animateWithDuration(0.15) { () -> Void in
            myTouch.view?.center = self.emptySpot
        }
        
        //UIView.commitAnimations()
        emptySpot = tapCen
        
        if checkStatus() {
            let alert = UIAlertController(title: "Bingo",
                message: "You make it!",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func checkStatus() -> Bool {
        for i in 0...numberOfimages-2 {
            if allImgViews[i].center != originCenters[i] {
                return false
            }
        }
        return true
    }

}

