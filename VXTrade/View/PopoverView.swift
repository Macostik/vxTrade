//
//  PopoverView.swift
//  VXTrade
//
//  Created by Yura Granchenko on 3/7/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class PopoverView: UIView {

    internal let contentView = UIView()
    internal let containerDataView = DataContainerView()
    internal let triangleView = TriangleView()
    var selectedItemBlock: ((String)->Void)?
    
    var contentData = [String]() {
        willSet {
            containerDataView.contentData = newValue
            containerDataView.expireRuleStreamView?.reload()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(white: 0, alpha: 0.75)
        contentView.backgroundColor = UIColor.clear
        triangleView.backgroundColor =  UIColor.gray
        triangleView.contentMode = .top
        containerDataView.backgroundColor = triangleView.backgroundColor
        containerDataView.cornerRadius = 5.0
        containerDataView.clipsToBounds = true
        
        
        tapped(closure: { [weak self] tapGesture in
            guard let `self` = self else { return }
            let point = tapGesture.location(in: self)
            if self.contentView.frame.contains(point) == false {
                self.hide()
            }
        })
        
        setupSubViews()
    }
    
    func setupSubViews() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showInView(_ view: UIView, sourceView: UIView, success: Block? = nil, cancel: Block? = nil) {
        frame = view.frame
        view.addSubview(self)
        add(contentView) { (make) in
            make.trailing.equalTo(sourceView)
            make.top.equalTo(sourceView.snp.bottom)
        }
        
        contentView.add(triangleView) {
            $0.trailing.equalTo(contentView).inset(20)
            $0.top.equalTo(contentView)
            $0.size.equalTo(CGSize(width: 16, height: 8))
        }
        
        contentView.add(containerDataView) {
            $0.top.equalTo(triangleView.snp.bottom).inset(1)
            $0.leading.bottom.trailing.equalTo(contentView)
            $0.width.equalTo(120)
            $0.height.equalTo(150)
        }
        
        layoutIfNeeded()
        containerDataView.setup(selectItem: { [weak self] item in
            self?.selectedItemBlock?(item)
            self?.hide()
        })
        
        backgroundColor = UIColor.clear
        contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        contentView.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn , animations: { _ in
            self.contentView.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn , animations: { () -> Void in
            self.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            self.contentView.alpha = 1.0
        }, completion: nil)
        
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: .curveEaseIn , animations: { _ in
            self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.contentView.alpha = 0.0
            self.backgroundColor = UIColor.clear
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

class DataContainerView: UIView {
    var contentData = [""]
    var expireRuleStreamView: StreamView? = nil
    
    func setup(selectItem: @escaping ((String) -> Void)) {
        expireRuleStreamView = add(StreamView(frame: frame), {
            $0.edges.equalTo(self)
        })
        guard let steamView = expireRuleStreamView else { return }
        steamView.showsVerticalScrollIndicator = false
        steamView.layout = StreamLayout()
        let dataSource = StreamDataSource<[String]>(streamView: steamView)
        let metrics = StreamMetrics<ExpireRuleCell>(size: frame.height/CGFloat(contentData.count))
        metrics.selection = { view in
            guard let item = view.item?.entry as? String else { return }
            selectItem(item)
        }
        dataSource.addMetrics(metrics: metrics)
        dataSource.items = contentData
    }
}

class ExpireRuleCell: EntryStreamReusableView<String> {
    
    let desriptionLabel = specify(UILabel(), {
        $0.font = UIFont.boldSystemFont(ofSize: 17.0)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
    })
    
    override func setup(entry: String)  {
        desriptionLabel.text = entry
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(desriptionLabel,  { (make) in
            make.edges.equalTo(self)
        })
    }
}
