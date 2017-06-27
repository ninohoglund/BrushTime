//
//  ViewController.swift
//  BrushTime
//
//  Created by Nino Höglund on 2017-06-24.
//  Copyright © 2017 Babel Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum AnimationMode {
        case upper, lower, upperBack, lowerBack, front, moveOut
    }
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var mouthImageView: UIImageView!
    @IBOutlet weak var teethImageView: UIImageView!
    @IBOutlet weak var toothBrushView: UIImageView!
    @IBOutlet weak var progressView: UIView!
    
    var timerStarted = false
    let times = ["1:30", "2:00", "2:30", "3:00"]
    let seconds = [20.0, 120.0, 150.0, 180.0]
    let brushDelay = 0.7
    let brushSpeed = 0.3 // Lower = faster
    let animationPhases: [AnimationMode] = [.upper, .lower, .lowerBack, .upperBack, .front, .front]
    var currentTime = 0, currentPhase = 0
    
    
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
        
        progressView.frame.size.width = 1.0
        fillProgressBar(in: seconds[currentTime] + brushDelay)
        
        currentPhase = 0
        moveToNextAnimationPhase(startFromTheBeginning: true)
    }
    
    func fillProgressBar(in seconds: Double) {
        UIView.animate(withDuration: seconds, delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: {
            self.progressView.frame.size.width = self.view.frame.size.width;
        }, completion: nil)
    }
    
    func originForAnimation(mode:AnimationMode) -> CGPoint {
        let x = self.mouthImageView.center.x
        let y = self.mouthImageView.center.y
        
        switch mode {
        case .lower:
            return CGPoint(x: x + 15, y: y + 4)
        case .upper:
            return CGPoint(x: x + 15, y: y - 64)
        case .upperBack:
            return CGPoint(x: x + 15, y: y - 120)
        case .lowerBack:
            return CGPoint(x: x + 15, y: y + 54)
        case .front:
            return CGPoint(x: x - 136, y: y - 100)
        case .moveOut:
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
    
    func moveToNextAnimationPhase(startFromTheBeginning: Bool) {
        currentPhase = startFromTheBeginning ? 0 : currentPhase + 1
        if currentPhase < animationPhases.count {
            switchToAnimation(mode: animationPhases[currentPhase])
        }
        else if currentPhase == animationPhases.count {
            switchToAnimation(mode: .moveOut)
        } else {
            stopTimer(self)
            return
        }
        
        let dispatchTime = DispatchTime.now() + (seconds[currentTime] - brushSpeed) / Double(animationPhases.count)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.moveToNextAnimationPhase(startFromTheBeginning: false)
        }
        
    }
    
    func switchToAnimation(mode: AnimationMode) {
        
        let origin :CGPoint = originForAnimation(mode: mode)
        
        // Reset animations and set up toothbrush (unless moving out)
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
            UIView.animate(withDuration: self.brushSpeed, delay: 0, options: .curveEaseInOut, animations: {
                self.toothBrushView.frame.origin.x = origin.x
            }, completion: {
                _ in
                // Brush animation
                UIView.animate(withDuration: self.brushSpeed, delay: self.brushDelay, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    self.toothBrushView.transform = CGAffineTransform(translationX: 0, y: 128)
                }, completion: nil)
                UIView.animate(withDuration: self.brushSpeed * 12, delay: self.brushDelay, options: [.repeat, .autoreverse, .curveLinear], animations: {
                    self.toothBrushView.frame.origin.x += 148
                }, completion: nil)
            })
        case .lower, .upper, .lowerBack, .upperBack:
            self.view.bringSubview(toFront: teethImageView)
            // Move out of the screen
            self.toothBrushView.frame.origin.x = origin.x + 200
            // Move in place and wait
            UIView.animate(withDuration: self.brushSpeed, delay: 0, options: .curveEaseInOut, animations: {
                self.toothBrushView.frame.origin.x = origin.x
            }, completion: {
                _ in
                // Brush animation
                UIView.animate(withDuration: self.brushSpeed, delay: self.brushDelay, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    self.toothBrushView.transform = CGAffineTransform(translationX: -160, y: 0)
                }, completion: nil)
            })
        case .moveOut:
            UIView.animate(withDuration: self.brushSpeed, delay: 0, options: .beginFromCurrentState, animations: {
                self.toothBrushView.transform = CGAffineTransform(translationX: 300, y: 0)
                self.timeButton.alpha = 1.0
            }, completion: nil)
        }
    }
}

