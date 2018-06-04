//
//  View+Ext.swift
//  BinarySwipe
//
//  Created by Macostik on 5/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import UIKit

extension UIGestureRecognizer {
    
    func addTo(view: UIView) -> Self {
        view.addGestureRecognizer(self)
        return self
    }
    
    func remove() {
        view?.removeGestureRecognizer(self)
    }
}

extension UIView {
    
    @discardableResult func tapped(closure: @escaping ((TapGesture) -> ())) -> TapGesture {
        return TapGesture(closure: closure).addTo(view: self)
    }
    
    @discardableResult func panned(closure: @escaping ((PanGesture) -> ())) -> PanGesture {
        return PanGesture(closure: closure).addTo(view: self)
    }
    
    @discardableResult func swiped(direction: UISwipeGestureRecognizerDirection, closure: @escaping ((SwipeGesture) -> ())) -> SwipeGesture {
        return SwipeGesture(direction: direction, closure: closure).addTo(view: self)
    }
}

final class TapGesture: UITapGestureRecognizer {
    
    convenience init(closure: @escaping (TapGesture) -> ()) {
        self.init()
        addTarget(self, action: #selector(action(sender:)))
        actionClosure = closure
    }
    
    var actionClosure: ((TapGesture) -> ())?
    
    func action(sender: TapGesture) {
        actionClosure?(self)
    }
}

final class PanGesture: UIPanGestureRecognizer {
    
    convenience init(closure: @escaping (PanGesture) -> ()) {
        self.init()
        addTarget(self, action: #selector(self.action(sender:)))
        actionClosure = closure
    }
    
    var actionClosure: ((PanGesture) -> ())?
    
    func action(sender: PanGesture) {
        actionClosure?(sender)
    }
}

final class SwipeGesture: UISwipeGestureRecognizer, UIGestureRecognizerDelegate {
    
    convenience init(direction: UISwipeGestureRecognizerDirection, closure: @escaping (SwipeGesture) -> ()) {
        self.init()
        self.direction = direction
        addTarget(self, action: #selector(self.action(sender:)))
        actionClosure = closure
    }
    
    var actionClosure: ((SwipeGesture) -> ())?
    
    func action(sender: SwipeGesture) {
        actionClosure?(sender)
    }
    
    var shouldBegin: (() -> Bool)? {
        willSet {
            self.delegate = self
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldBegin?() ?? true
    }
}
