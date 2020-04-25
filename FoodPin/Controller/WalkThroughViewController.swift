//
//  WalkThroughViewController.swift
//  FoodPin
//
//  Created by wyn on 2020/4/22.
//  Copyright © 2020 Wyn. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController, WalkThroughPageViewControllerDelegate {

    var walkThroughPageViewController: WalkThroughPageViewController?
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    
    @IBAction func skipButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        if let index = walkThroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkThroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkThrough")
                dismiss(animated: true, completion: nil)
            default: break
            }
        }
        
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkThroughPageViewController {
            walkThroughPageViewController = pageViewController
            walkThroughPageViewController?.walkThroughDelegate = self
        }
    }
    
    func updateUI() {
        if let index = walkThroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle(NSLocalizedString("NEXT", comment: "NEXT"),for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle(NSLocalizedString("GET START", comment: "GET START"), for: .normal)
                skipButton.isHidden = true
            default: break
            }
            
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
