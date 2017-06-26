//
//  ViewController.swift
//  BrushTime
//
//  Created by Nino Höglund on 2017-06-24.
//  Copyright © 2017 Babel Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var mouthImageView: UIImageView!
    @IBOutlet weak var teethImageView: UIImageView!
    @IBOutlet weak var toothBrushView: UIImageView!
    
    var timerStarted = false
    let times = ["1:30", "2:00", "2:30", "3:00"]
    var currentTime = 0
    
    enum AnimationMode {
        case moveIn
        case upper
        case lower
        case upperBack
        case lowerBack
        case front
        case moveOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeButton.setTitle(times[currentTime], for: .normal)
        toothBrushView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func startTimer(_ sender: Any) {
        stopButton.alpha = 1.0
        startButton.alpha = 0.0
        
        chew(completion: {
            self.startBrushing()
        })
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        stopButton.alpha = 0.0
        startButton.alpha = 1.0
        
        switchToAnimation(mode: .moveOut)
        
        /*chew(completion: {
            self.timeButton.alpha = 1.0
        })*/
    }
    
    @IBAction func toggleTime(_ sender: Any) {
        currentTime += 1
        if currentTime >= times.count {
            currentTime = 0
        }
        self.timeButton.setTitle(times[currentTime], for: .normal)
        chew(completion: {
            self.timeButton.alpha = 1.0
        })
    }
    
    func chew(completion: @escaping () -> Void) {
        self.timeButton.alpha = 0.0
        // Close mouth
        mouthImageView.isHighlighted = true
        teethImageView.isHighlighted = true
        
        let dispatchTime = DispatchTime.now() + 0.15
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            // Open mouth
            self.mouthImageView.isHighlighted = false
            self.teethImageView.isHighlighted = false
            completion()
        }
    }
    
    func startBrushing() {
        toothBrushView.isHidden = false
        switchToAnimation(mode: .lower)
    }
    
    func switchToAnimation(mode: AnimationMode) {
        
        let origin :CGPoint = originForAnimation(mode: mode)
        
        if mode != .moveOut {
            clearTootbrushAnimations()
            self.toothBrushView.frame.origin = origin
        }
        
        switch mode {
        case .moveOut:
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                self.toothBrushView.transform = CGAffineTransform(translationX: 300, y: 0)
                self.timeButton.alpha = 1.0
            }, completion: nil)
        case .lower:
            self.toothBrushView.frame.origin.x = origin.x + 200
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.toothBrushView.frame.origin.x = origin.x
            }, completion: {
                _ in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    self.toothBrushView.transform = CGAffineTransform(translationX: -160, y: 0)
                }, completion: nil)
            })
        default:
            //toothBrushView.frame.origin.x = 0
            //toothBrushView.frame.origin.y = 0
            NSLog("Default")
        }
    }
    
    func clearTootbrushAnimations() {
        toothBrushView.layer.removeAllAnimations()
        toothBrushView.transform = CGAffineTransform.identity
    }
    
    func originForAnimation(mode:AnimationMode) -> CGPoint {
        switch mode {
        case .lower:
            return CGPoint(x: self.mouthImageView.center.x + 15, y: self.mouthImageView.center.y + 4)
        default:
            return CGPoint.zero
        }
    }
}



/*UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
 UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
 self.toothBrushView.transform = CGAffineTransform(translationX: -50, y: 0)
 })
 UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
 self.toothBrushView.transform = CGAffineTransform(translationX: 50, y: 0)
 })
 }, completion: nil)*/
