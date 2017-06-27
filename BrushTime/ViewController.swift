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
    @IBOutlet weak var progressView: UIView!
    
    var timerStarted = false
    let times = ["1:30", "2:00", "2:30", "3:00"]
    let seconds = [9.0, 120.0, 150.0, 180.0]
    var currentTime = 0
    
    enum AnimationMode {
        case upper, lower, upperBack, lowerBack, front, moveOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeButton.setTitle(times[currentTime], for: .normal)
        toothBrushView.isHidden = true
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
        progressView.layer.removeAllAnimations()
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
        //switchToAnimation(mode: .lower)
        switchToAnimation(mode: .upperBack)
        
        progressView.frame.size.width = 1.0
        fillProgressBar(in: seconds[currentTime])
    }
    
    func fillProgressBar(in seconds: Double) {
        UIView.animate(withDuration: seconds, delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: {
            self.progressView.frame.size.width = self.view.frame.size.width;
        }, completion: {
            _ in
            self.stopTimer(self.startButton)
        })
    }
    
    func originForAnimation(mode:AnimationMode) -> CGPoint {
        switch mode {
        case .lower:
            return CGPoint(x: self.mouthImageView.center.x + 15, y: self.mouthImageView.center.y + 4)
        case .upper:
            return CGPoint(x: self.mouthImageView.center.x + 15, y: self.mouthImageView.center.y - 64)
        case .upperBack:
            return CGPoint(x: self.mouthImageView.center.x + 15, y: self.mouthImageView.center.y - 120)
        case .lowerBack:
            return CGPoint(x: self.mouthImageView.center.x + 15, y: self.mouthImageView.center.y + 54)
        case .front:
            return CGPoint(x: self.mouthImageView.center.x - 136, y: self.mouthImageView.center.y - 100)
        default:
            return CGPoint.zero
        }
    }
    
    func imageForAnimation(mode: AnimationMode) -> UIImage? {
        switch mode {
        case .lower:
            return #imageLiteral(resourceName: "toothbrush-down")
        case .upper:
            return #imageLiteral(resourceName: "toothbrush-up")
        case .front, .upperBack, .lowerBack:
            return #imageLiteral(resourceName: "toothbrush-in")
        case .moveOut:
            return nil
        }
    }
    
    func switchToAnimation(mode: AnimationMode) {
        
        let origin :CGPoint = originForAnimation(mode: mode)
        
        // Reset animations and set up toothbrush
        if mode != .moveOut {
            toothBrushView.layer.removeAllAnimations()
            toothBrushView.transform = CGAffineTransform.identity
            toothBrushView.frame.origin = origin
            toothBrushView.image = imageForAnimation(mode: mode)
        }
        
        // Close mouth if brushing front of teeth
        self.mouthImageView.isHighlighted = (mode == .front)
        self.teethImageView.isHighlighted = (mode == .front)
        
        switch mode {
        case .front:
            self.view.bringSubview(toFront: toothBrushView)
            // Move out of the screen
            self.toothBrushView.frame.origin.x = origin.x + 360
            // Move in place and wait
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.toothBrushView.frame.origin.x = origin.x
            }, completion: {
                _ in
                // Brush animation
                UIView.animate(withDuration: 0.5, delay: 0.3, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    self.toothBrushView.transform = CGAffineTransform(translationX: 0, y: 128)
                }, completion: nil)
                UIView.animate(withDuration: 6, delay: 0.3, options: [.repeat, .autoreverse, .curveLinear], animations: {
                    self.toothBrushView.frame.origin.x += 148
                }, completion: nil)
            })
        case .lower, .upper, .lowerBack, .upperBack:
            self.view.bringSubview(toFront: teethImageView)
            // Move out of the screen
            self.toothBrushView.frame.origin.x = origin.x + 200
            // Move in place and wait
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.toothBrushView.frame.origin.x = origin.x
            }, completion: {
                _ in
                // Brush animation
                UIView.animate(withDuration: 0.5, delay: 0.3, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    self.toothBrushView.transform = CGAffineTransform(translationX: -160, y: 0)
                }, completion: nil)
            })
        case .moveOut:
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
                self.toothBrushView.transform = CGAffineTransform(translationX: 300, y: 0)
                self.timeButton.alpha = 1.0
            }, completion: nil)
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
