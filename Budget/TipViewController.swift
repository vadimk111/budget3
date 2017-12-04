//
//  TipViewController.swift
//  Budget
//
//  Created by Vadik on 16/11/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class TipViewController: UIViewController {

    class func instantiate() -> TipViewController {
        let vc = TipViewController()
        vc.view.backgroundColor = UIColor.clear
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(createOverlay(frame: view.bounds, xOffset: 20, yOffset: 40, radius: 20))
    }

    func createOverlay(frame : CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.init(red: 42 / 255, green: 42 / 255, blue: 42 / 255, alpha: 0.8)
        
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
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
