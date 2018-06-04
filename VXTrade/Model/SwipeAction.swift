//
//  SwipeAction.swift
//  VXTrade
//
//  Created by Yuriy on 1/23/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import SnapKit

enum Action {
    case sell, rollover, riskFree
}

private final class SwipeActioView: ShapeView {
    override func defineShapePath(path: UIBezierPath, contentMode: UIViewContentMode) {
        let h = bounds.height
        let w = bounds.width
        if contentMode == .left {
            path.move(0 ^ 0).line(0 ^ h).line(w ^ h).line(w ^ 0).line(0 ^ 0)
        } else if (contentMode == .right) {
            path.move(w ^ 0).line(w ^ h).line(0 ^ h).line(0 ^ 0).line(w ^ 0)
        }
    }
}

private final class SwipeActionView: UIView {
    
    let shape = SwipeActioView()
    var didPerformAction: ((Action) -> (Void))?
    let costView = specify(UIView(), {
        $0.backgroundColor = Color.caral
    })
    let costLabel = Label(icon: "v", size: 32.0)
    let dollarLabel = specify(UILabel(), {
        $0.text = "$"
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 15.0)
    })
    let sellButton = specify(Button(), {
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21.0)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
    })
    let rolloverButton = specify(Button(icon: "u", size: 44.0), {
        $0.backgroundColor = Color.gray
    })
    let riskFreeButton = specify(Button(icon: "t", size: 44.0), {
      $0.backgroundColor = Color.darkGray
    })
    
    convenience init(entry: Position?, isRight: Bool) {
    
        self.init()
        shape.contentMode = isRight ? .right : .left
        shape.clipsToBounds = true
        let payoutValue = 2 << (entry?.payoutValue() ?? "")
        sellButton.setTitle(payoutValue, for: .normal)
        
        if isRight {
            add(shape, {
                $0.leading.top.equalTo(self)
                $0.bottom.equalTo(self).inset(1)
            })
            add(costView, {
                $0.leading.top.bottom.equalTo(shape)
            })
            costView.add(costLabel, {
                $0.leading.equalTo(costView).offset(12)
                $0.centerY.equalTo(costView)
            })
            costView.add(dollarLabel, {
                $0.centerY.equalTo(costView).offset(-5)
                $0.leading.equalTo(costLabel.snp.trailing).offset(7)
            })
            costView.add(sellButton, {
                $0.centerY.equalTo(costView)
                $0.leading.equalTo(dollarLabel.snp.trailing).inset(3)
                $0.trailing.equalTo(costView).inset(12)
            })
            add(rolloverButton, {
                $0.top.bottom.equalTo(shape)
                $0.leading.equalTo(costView.snp.trailing)
                $0.width.equalTo(75)
            })
            add(riskFreeButton, {
                $0.top.bottom.equalTo(shape)
                $0.leading.equalTo(rolloverButton.snp.trailing)
                $0.width.equalTo(rolloverButton)
            })
        } else {
            add(shape, {
                $0.trailing.top.equalTo(self)
                $0.bottom.equalTo(self).inset(1)
            })
            add(costView, {
                $0.edges.equalTo(shape)
            })
            costView.add(costLabel, {
                $0.trailing.equalTo(costView).offset(-12)
                $0.centerY.equalTo(costView)
            })
            costView.add(dollarLabel, {
                $0.centerY.equalTo(costView).offset(-5)
                $0.trailing.equalTo(costLabel.snp.leading).offset(-7)
            })
            costView.add(sellButton, {
                $0.centerY.equalTo(costView)
                $0.trailing.equalTo(dollarLabel.snp.leading).inset(3)
                $0.leading.equalTo(costView).inset(12)
            })
            add(rolloverButton, {
                $0.top.bottom.equalTo(shape)
                $0.trailing.equalTo(costView.snp.leading)
                $0.width.equalTo(75)
            })
            add(riskFreeButton, {
                $0.top.bottom.equalTo(shape)
                $0.trailing.equalTo(rolloverButton.snp.leading)
                $0.width.equalTo(rolloverButton)
            })
        }
        sellButton.click {[weak self] sender in
            self?.didPerformAction?(.sell)
        }
        rolloverButton.click {[weak self] sender in
            self?.didPerformAction?(.rollover)
        }
        riskFreeButton.click { [weak self] sender in
            self?.didPerformAction?(.riskFree)
        }
    }
}

var SwipeActionWidth: CGFloat = CustomToken.currentToken?.riskFreeCredit == 0 ? 200 : 250

enum SwipeActionDirection: Int {
    case unknown, right, left, both
}

final class SwipeAction: NSObject {
    
    var direction: SwipeActionDirection = .unknown
    
    var shouldBeginPanning: ((SwipeAction) -> SwipeActionDirection)?
    
    var didBeginPanning: ((SwipeAction) -> Void)?
    
    var didEndPanning: ((SwipeAction, Bool) -> Void)?
    
    var didPerformAction: ((Action) -> (Void))?
    
    private var actionView: SwipeActionView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let actionView = actionView {
                actionView.didPerformAction = didPerformAction
                containerView.addSubview(actionView)
                for subview in actionView.subviews {
                    subview.layoutIfNeeded()
                }
            }
        }
    }
    
    internal weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    private weak var movingView: UIView!
    private weak var containerView: UIView!
    private var entry: Position?
    internal var isShow = false
    
    private var translation: CGFloat = 0 {
        didSet {
            guard let actionView = actionView else { return }
            actionView.transform = CGAffineTransform(translationX: translation, y: 0)
            if isShow == true {
                movingView.x = 0
                return
            }
            if direction == .right {
                movingView.x = actionView.x - actionView.width
            } else {
                movingView.x = actionView.width - abs(actionView.x)
            }
        }
    }
    
    init(containerView: UIView, movingView: UIView, entry: Position?) {
        super.init()
        self.movingView = movingView
        self.containerView = containerView
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panning(sender:)))
        recognizer.delegate = self
        movingView.addGestureRecognizer(recognizer)
        panGestureRecognizer = recognizer
        self.entry = entry
    }
    
    func panning(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            if isShow == false {
                didBeginPanning?(self)
                if direction == .right {
                    let actionView = SwipeActionView(entry: entry, isRight: true)
                    actionView.frame = movingView.bounds.offsetBy(dx: movingView.width, dy: 0)
                    self.actionView = actionView
                } else if direction == .left {
                    let actionView = SwipeActionView(entry: entry, isRight: false)
                    actionView.frame = movingView.bounds.offsetBy(dx: -movingView.width, dy: 0)
                    self.actionView = actionView
                }
            }
            break
        case .changed:
            var translation = sender.translation(in: movingView.superview).x
            if isShow == false {
                if direction == .right {
                    translation = max(-SwipeActionWidth, min(0, translation))
                } else if direction == .left {
                    translation = min(SwipeActionWidth, max(0, translation))
                }
                self.translation = translation
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
                    translation = max(0, min(self.movingView.x, translation))
                    self.translation = translation
                }, completion: nil)
            }
            break
        case .ended, .cancelled:
            if isShow == false {
                let performedAction = abs(translation) >= self.movingView.width/2
                didEndPanning?(self, performedAction)
                if performedAction {
                    performAction()
                } else if translation != 0 {
                    cancelAction()
                }
                isShow = true
            } else {
                isShow = false
                reset()
            }
            break
        default: break
        }
    }
    
    func performAction() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
            self.translation = (self.direction == .right) ?  -SwipeActionWidth : SwipeActionWidth
        }, completion: nil)
    }
    
    func cancelAction() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
            self.translation = 0
        }, completion: { _ in
            self.reset()
        })
    }
    
    func reset() {
        actionView = nil
    }
}

extension SwipeAction: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGestureRecognizer == gestureRecognizer {
            if isShow == true { return true }
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            let shouldBegin = abs(velocity.x) > abs(velocity.y)
            direction = velocity.x < 0 ? .right : .left
            if (shouldBegin) {
                guard let  preferedDirection = shouldBeginPanning?(self) else { return false }
                switch preferedDirection {
                case .both:
                    return true
                case .right, .left:
                    return  direction == preferedDirection
                case .unknown:
                    return false
                }
            }
            return shouldBegin
        }
        return true
    }
}
